import 'package:flutter_test/flutter_test.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';

void main() {
  test(
    'Вопросы для тем с одинаковыми названиями в разных раундах не пересекаются',
    () {
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

      // Список всех тем и вопросов
      // final themes = [theme1, theme2];
      final questions = [question1, question2];

      // Фильтруем вопросы для каждой темы по themeId
      final theme1Questions =
          questions.where((q) => q.themeId == theme1.id).toList();
      final theme2Questions =
          questions.where((q) => q.themeId == theme2.id).toList();

      expect(theme1Questions.length, 1);
      expect(theme2Questions.length, 1);
      expect(theme1Questions.first.id, 'q1');
      expect(theme2Questions.first.id, 'q2');
      expect(theme1Questions.first.id != theme2Questions.first.id, true);
    },
  );
}
