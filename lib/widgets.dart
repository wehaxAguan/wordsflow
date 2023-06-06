import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wordflow/model_data.dart';

class WordFlowPlayerWidget extends StatelessWidget {
  const WordFlowPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final WordFlowData? data = context.watch<WordFlowData?>();
    if (data != null) {
      return VideoWidget(
        url: data.video!.url!,
        englishSubtitle: data.subtitles![0],
        chineseSubtitle: data.subtitles![1],
        word: data.words![0],
        user: data.user!,
        highlightWord: data.highlightWords![0],
      );
    } else {
      return const Center(
        child: Text('load data error'),
      );
    }
  }
}

class VideoWidget extends StatefulWidget {
  final String url;
  final Subtitle englishSubtitle;
  final Subtitle chineseSubtitle;
  final HighlightWord? highlightWord;
  final Word word;
  final User user;

  const VideoWidget({
    super.key,
    required this.url,
    required this.englishSubtitle,
    required this.chineseSubtitle,
    required this.word,
    required this.user,
    this.highlightWord,
  });

  @override
  State<StatefulWidget> createState() {
    return _VideoWidgetState();
  }
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              WordsWidget(word: widget.word),
              Center(
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 45.h, right: 45.w),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: SmallAvatarWidget(
                            avatarUrl: widget.user.smallAvatar!),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SubtitlesWidget(
                    subtitle: widget.englishSubtitle,
                    playerController: _controller,
                    highlightWord: widget.highlightWord,
                  ),
                  SubtitlesWidget(
                    subtitle: widget.chineseSubtitle,
                    playerController: _controller,
                  )
                ],
              ),
            ],
          )
        : Container();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

TextStyle defaultSubtitleStyle = TextStyle(
  color: const Color(0xFF6f6f6f),
  fontSize: 50.sp,
  decoration: TextDecoration.none,
);

final Paint defaultHighlightTextGradient = Paint()
  ..shader = const LinearGradient(
    colors: <Color>[
      Color(0xFF8150f6),
      Color(0xFFa182ff),
      Color(0xFF8150f6),
    ],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 100.0));

class SubtitlesWidget extends StatefulWidget {
  final Subtitle subtitle;
  final HighlightWord? highlightWord;
  final VideoPlayerController playerController;

  const SubtitlesWidget({
    super.key,
    required this.subtitle,
    required this.playerController,
    this.highlightWord,
  });

  @override
  State<StatefulWidget> createState() {
    return _SubtitlesWidgetState();
  }
}

class _SubtitlesWidgetState extends State<SubtitlesWidget> {
  Line? currentLine;

  @override
  void initState() {
    super.initState();
    widget.playerController.addListener(_ctlListener);
  }

  void _ctlListener() {
    Line? newLine = _getLine(widget.playerController.value.position);
    if (newLine != currentLine) {
      setState(() {
        currentLine = newLine;
      });
    }
  }

  Line? _getLine(Duration position) {
    List<Line>? lines = widget.subtitle.lines;
    if (null != lines) {
      for (Line line in lines) {
        if (null != line.startMilli &&
            null != line.endMilli &&
            line.startMilli!.compareTo(position) <= 0 &&
            line.endMilli!.compareTo(position) >= 0) {
          return line;
        }
      }
      return null;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(40.w, 10.h, 40.w, 5.h),
      child: EasyRichText(
        currentLine == null ? '' : currentLine!.words!,
        defaultStyle: defaultSubtitleStyle,
        textAlign: TextAlign.center,
        patternList: _getPatterns(),
      ),
    );
  }

  List<EasyRichTextPattern>? _getPatterns() {
    if (null == widget.highlightWord ||
        null == widget.highlightWord!.subWords) {
      return null;
    } else {
      return List.from(widget.highlightWord!.subWords!
          .map<EasyRichTextPattern>((e) => EasyRichTextPattern(
                targetString: e,
                style: TextStyle(foreground: defaultHighlightTextGradient),
              )));
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.playerController.removeListener(_ctlListener);
  }
}

final TextStyle defaultWordStyle = TextStyle(
  fontSize: 100.sp,
  decoration: TextDecoration.none,
  foreground: defaultHighlightTextGradient,
);
final TextStyle defaultPhoneticStyle = TextStyle(
  fontSize: 40.sp,
  decoration: TextDecoration.none,
  color: const Color(0xFF757575),
);
final TextStyle defaultExplainStyle = TextStyle(
  fontSize: 35.sp,
  decoration: TextDecoration.none,
  color: const Color(0xFF3d3d3d),
);

class WordsWidget extends StatelessWidget {
  final Word word;

  const WordsWidget({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.h,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word.wordsStr!,
            style: defaultWordStyle,
          ),
          Text(
            word.phonetic!,
            style: defaultPhoneticStyle,
          ),
          Text(
            word.chineseExplain!,
            style: defaultExplainStyle,
          ),
        ],
      ),
    );
  }
}

class SmallAvatarWidget extends StatelessWidget {
  final String avatarUrl;

  const SmallAvatarWidget({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110.w,
      height: 110.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ClipOval(
            child: ColoredBox(color: Color(0x20666666)),
          ),
          Padding(
            padding: EdgeInsets.all(6.w),
            child: ClipOval(
              child: Image.network(avatarUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialWidget extends StatelessWidget {
  const SocialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.h,
      child: Padding(
        padding: EdgeInsets.only(left: 40.w,right: 40.w),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.recommend,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.comment,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.mic,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_forward,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
