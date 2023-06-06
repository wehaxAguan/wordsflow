import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:wordflow/converters.dart';

@jsonSerializable
class WordFlowData {
  int? id;
  String? text;
  int? type;
  String? typeString;
  int? status;
  String? statusString;
  Video? video;
  List<Subtitle>? subtitles;
  List<Word>? words;
  List<HighlightWord>? highlightWords;
  Social? social;
  int? langType;
  String? langString;
  String? createTime;
  String? updateTime;
  User? user;
}

@jsonSerializable
class User {
  int? id;
  String? name;
  String? smallAvatar;
  String? mediumAvatar;
  String? avatar;
}

@jsonSerializable
class Social {
  bool? liked;
  int? likeCount;
}

@jsonSerializable
class Video {
  int? id;
  String? url;
  String? fileName;
  int? width;
  int? height;
  String? langString;
  int? langType;
}

@jsonSerializable
class Subtitle {
  int? id;
  String? vttUrl;
  String? url;
  String? langString;
  int? langType;
  String? fileName;
  String? vttFileName;
  List<Line>? lines;
}

@jsonSerializable
class Line {
  int? id;
  String? words;
  int? position;
  String? startString;
  String? endString;
  @JsonProperty(converter: DurationMilliConverter())
  Duration? startMilli;
  @JsonProperty(converter: DurationMilliConverter())
  Duration? endMilli;
  int? status;
  String? statusString;
  int? langType;
  String? langString;
  String? createTime;
}

@jsonSerializable
class Word {
  int? id;
  String? statusString;
  int? status;
  String? wordsStr;
  String? chineseExplain;
  String? shortChineseExplain;
  int? type;
  String? typeString;
  String? pos;
  String? phonetic;
  int? langType;
  String? langString;
  int? lemmaId;
  String? createTime;
  int? classCount;
}

@jsonSerializable
class HighlightWord {
  String? word;
  List<String>? subWords;
}
