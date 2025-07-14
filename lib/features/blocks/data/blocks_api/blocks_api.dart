import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import 'package:smartest_man/features/blocks/data/blocks_api/models/block_model.dart';
import 'package:smartest_man/features/blocks/data/blocks_api/models/question_model.dart';

abstract class PacksApi {
  void saveBlocks(String blockName, List<BlockModel> blockModel);
  List<BlockModel> getBlocks(String parentName);

  void saveQuestions(String themeName, List<QuestionModel> questions);
  List<QuestionModel> getQuestions(String themeName);

  void remove(String key);
}

class PacksApiImpl implements PacksApi {
  PacksApiImpl({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  void saveBlocks(String blockName, List<BlockModel> blockModel) {
    final List<String> jsonList = blockModel.map((q) => q.toJson()).toList();
    _prefs.setStringList(blockName, jsonList);
  }

  @override
  List<BlockModel> getBlocks(String parentName) {
    final List<String>? jsonList = _prefs.getStringList(parentName);
    if (jsonList == null) return [];
    return jsonList.map((str) => BlockModel.fromJson(str)).toList();
  }

  @override
  void saveQuestions(String themeName, List<QuestionModel> questions) {
    log('=== DEBUG API SAVE ===');
    log('Saving to key: $themeName');
    log('Questions count: ${questions.length}');

    final List<String> jsonList = questions.map((q) => q.toJson()).toList();

    log('JSON list length: ${jsonList.length}');
    for (int i = 0; i < jsonList.length; i++) {
      log('JSON $i: ${jsonList[i]}');
    }

    _prefs.setStringList(themeName, jsonList);
    log('Saved to SharedPreferences');
  }

  @override
  List<QuestionModel> getQuestions(String themeName) {
    log('=== DEBUG API GET ===');
    log('Getting from key: $themeName');

    final List<String>? jsonList = _prefs.getStringList(themeName);

    if (jsonList == null) {
      log('No data found in SharedPreferences');
      return [];
    }

    log('Retrieved JSON list length: ${jsonList.length}');
    for (int i = 0; i < jsonList.length; i++) {
      log('Retrieved JSON $i: ${jsonList[i]}');
    }

    return jsonList.map((str) => QuestionModel.fromJson(str)).toList();
  }

  @override
  void remove(String key) {
    _prefs.remove(key);
  }
}
