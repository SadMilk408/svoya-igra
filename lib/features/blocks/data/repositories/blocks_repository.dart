import 'dart:developer';
import 'package:smartest_man/features/blocks/data/blocks_api/models/block_model.dart';
import 'package:smartest_man/features/blocks/data/blocks_api/models/question_model.dart';
import 'package:smartest_man/features/blocks/data/blocks_api/blocks_api.dart';

import 'entities/structure_entity.dart';

abstract class StructureRepository {
  GameStructure getStructure();

  void saveRounds(List<RoundEntity> roundEntity);
  void saveThemes(List<ThemeEntity> themes);
  void saveQuestions(List<QuestionEntity> questions);

  List<RoundEntity> getRounds();
  List<ThemeEntity> getThemes();
  List<QuestionEntity> getQuestions();

  void remove(BlocEntity entity);
}

final mainPack = PackEntity(
  id: 'main_pack',
  parentName: 'Своя игра',
  blockName: 'Основной пак',
);

class StructureRepositoryImpl implements StructureRepository {
  StructureRepositoryImpl({required PacksApi api, this.useMock}) : _api = api;

  final PacksApi _api;
  final bool? useMock;

  @override
  GameStructure getStructure() {
    if (useMock == true) {
      try {
        final pack = mockPack.toEntity() as PackEntity;
        final rounds =
            mockRounds.map((r) => r.toEntity() as RoundEntity).toList();
        final themes =
            mockThemes.map((t) => t.toEntity() as ThemeEntity).toList();
        final questions = mockQuestions.map((q) => q.toEntity()).toList();

        return GameStructure(
          pack: pack,
          rounds: rounds,
          themes: themes,
          questions: questions,
        );
      } catch (e) {
        throw Exception("Doesn't exist element");
      }
    }

    return GameStructure(
      pack: mainPack,
      rounds: getRounds(),
      themes: getThemes(),
      questions: getQuestions(),
    );
  }

  @override
  void saveRounds(List<RoundEntity> roundEntity) {
    _api.saveBlocks(
      '${mainPack.blockName}_rounds',
      roundEntity.map((r) => BlockModel.fromEntity(r)).toList(),
    );
  }

  @override
  void saveThemes(List<BlocEntity> themes) {
    _api.saveBlocks(
      '${mainPack.blockName}_themes',
      themes.map((t) => BlockModel.fromEntity(t)).toList(),
    );
  }

  @override
  void saveQuestions(List<QuestionEntity> questions) {
    log('=== DEBUG REPOSITORY SAVE ===');
    log('Saving ${questions.length} questions');
    for (int i = 0; i < questions.length; i++) {
      log('Question $i: ${questions[i].toMap()}');
    }

    _api.saveQuestions(
      '${mainPack.blockName}_questions',
      questions.map((q) => QuestionModel.fromEntity(q)).toList(),
    );
  }

  @override
  void remove(BlocEntity entity) {
    _api.remove('Раунд 1');
    _api.remove('Раунд 2');
  }

  @override
  List<RoundEntity> getRounds() {
    return _api
        .getBlocks('${mainPack.blockName}_rounds')
        .map((r) => r.toEntity() as RoundEntity)
        .toList();
  }

  @override
  List<ThemeEntity> getThemes() {
    return _api
        .getBlocks('${mainPack.blockName}_themes')
        .map((r) => r.toEntity() as ThemeEntity)
        .toList();
  }

  @override
  List<QuestionEntity> getQuestions() {
    log('=== DEBUG REPOSITORY GET ===');
    final questions =
        _api
            .getQuestions('${mainPack.blockName}_questions')
            .map((r) => r.toEntity())
            .toList();

    log('Retrieved ${questions.length} questions');
    for (int i = 0; i < questions.length; i++) {
      log('Question $i: ${questions[i].toMap()}');
    }

    return questions;
  }
}

final mockPack = BlockModel(
  name: 'Основной пак',
  parentName: 'Своя игра',
  blockType: BlockType.packs,
);

final mockRounds = [
  BlockModel(
    name: 'Раунд 1',
    parentName: 'Основной пак',
    blockType: BlockType.rounds,
  ),
  BlockModel(
    name: 'Раунд 2',
    parentName: 'Основной пак',
    blockType: BlockType.rounds,
  ),
  BlockModel(
    name: 'Раунд 3',
    parentName: 'Основной пак',
    blockType: BlockType.rounds,
  ),
];

final mockThemes = [
  BlockModel(
    name: 'Тема 1',
    parentName: 'Раунд 1',
    blockType: BlockType.themes,
  ),
  BlockModel(
    name: 'Тема 2',
    parentName: 'Раунд 1',
    blockType: BlockType.themes,
  ),
  BlockModel(
    name: 'Тема 3',
    parentName: 'Раунд 1',
    blockType: BlockType.themes,
  ),
];

final mockQuestions = [
  QuestionModel(parentName: 'Тема 1', price: 100, questionData: null),
  QuestionModel(parentName: 'Тема 1', price: 200, questionData: null),
  QuestionModel(parentName: 'Тема 1', price: 300, questionData: null),
  QuestionModel(parentName: 'Тема 1', price: 400, questionData: null),
  QuestionModel(parentName: 'Тема 1', price: 500, questionData: null),
];
