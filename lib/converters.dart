import 'package:dart_json_mapper/dart_json_mapper.dart';

class DurationMilliConverter implements ICustomConverter<Duration?> {
  const DurationMilliConverter() : super();

  @override
  Duration? fromJSON(dynamic jsonValue, DeserializationContext context) {
    return jsonValue is num
        ? Duration(milliseconds: jsonValue as int)
        : jsonValue;
  }

  @override
  dynamic toJSON(Duration? object, SerializationContext context) {
    return object?.inMilliseconds;
  }
}