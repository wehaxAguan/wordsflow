import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'model_data.dart';

Future<WordFlowData?> requestWordFlowData() async {
  final String json = await rootBundle.loadString('mock_data/wordflows.json');
  return JsonMapper.deserialize<WordFlowData>(json);
}
