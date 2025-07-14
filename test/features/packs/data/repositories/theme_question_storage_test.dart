import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartest_man/features/blocks/data/blocks_api/blocks_api.dart';
import 'package:smartest_man/features/blocks/data/repositories/blocks_repository.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Вопросы для тем с одинаковыми названиями в разных раундах не пересекаются (storage)',
    () async {
      // Используем in-memory SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final api = PacksApiImpl(prefs: prefs);
      final repo = StructureRepositoryImpl(api: api);

      // Создаём два раунда
      final round1 = RoundEntity(
        id: 'r1',
        blockName: 'Раунд',
        parentName: 'Пак',
      );
      final round2 = RoundEntity(
        id: 'r2',
        blockName: 'Раунд',
        parentName: 'Пак',
      );
      repo.saveRounds([round1, round2]);

      // Создаём две темы с одинаковым названием, но разными id и parentName
      final theme1 = ThemeEntity(
        id: 't1',
        blockName: 'Тема',
        parentName: round1.blockName,
      );
      final theme2 = ThemeEntity(
        id: 't2',
        blockName: 'Тема',
        parentName: round2.blockName,
      );
      repo.saveThemes([theme1, theme2]);

      // Вопросы для каждой темы
      final question1 = QuestionEntity(
        id: 'q1',
        blockName: '100',
        parentName: theme1.blockName,
        cost: 100,
        themeId: theme1.id,
        questionData: null,
      );
      final question2 = QuestionEntity(
        id: 'q2',
        blockName: '100',
        parentName: theme2.blockName,
        cost: 100,
        themeId: theme2.id,
        questionData: null,
      );
      repo.saveQuestions([question1, question2]);

      // Загружаем темы и вопросы из хранилища
      final loadedThemes = repo.getThemes();
      final loadedQuestions = repo.getQuestions();

      // Проверяем, что темы корректно загружены
      expect(loadedThemes.length, 2);
      expect(loadedThemes.map((t) => t.id).toSet(), {'t1', 't2'});

      // Проверяем, что вопросы корректно загружены и не пересекаются
      final theme1Questions =
          loadedQuestions.where((q) => q.themeId == 't1').toList();
      final theme2Questions =
          loadedQuestions.where((q) => q.themeId == 't2').toList();

      expect(theme1Questions.length, 1);
      expect(theme2Questions.length, 1);
      expect(theme1Questions.first.id, 'q1');
      expect(theme2Questions.first.id, 'q2');
      expect(theme1Questions.first.id != theme2Questions.first.id, true);
    },
  );
}
