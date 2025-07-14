import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'game_row.dart';
import 'question_cell.dart';
import 'players_panel.dart';

class GameBoardGrid extends StatelessWidget {
  final List<ThemeEntity> themes;
  final List<QuestionEntity> questions;
  final Map<String, QuestionState> questionStates;
  final Function(QuestionEntity)? onQuestionTap;
  final double cellHeight;
  final double themeFlex;

  const GameBoardGrid({
    super.key,
    required this.themes,
    required this.questions,
    required this.questionStates,
    this.onQuestionTap,
    this.cellHeight = 120, // Обновляем размер по умолчанию
    this.themeFlex = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (themes.isEmpty) {
      return _buildEmptyState();
    }

    // Группируем вопросы по темам
    final questionsByTheme = <String, List<QuestionEntity>>{};
    for (final theme in themes) {
      questionsByTheme[theme.id] =
          questions.where((q) => q.themeId == theme.id).toList();
    }

    // Собираем уникальные цены из всех вопросов
    final allCosts = <int>{};
    for (final question in questions) {
      allCosts.add(question.cost);
    }
    final costs = allCosts.toList()..sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Вычисляем доступную высоту для игрового поля (учитываем место для панели игроков)
        final availableHeight =
            constraints.maxHeight -
            16 -
            100; // Учитываем margin и панель игроков
        final calculatedCellHeight = availableHeight / themes.length;

        // Ограничиваем минимальную и максимальную высоту
        final adaptiveCellHeight = calculatedCellHeight.clamp(60.0, cellHeight);

        return Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Игровое поле
              Expanded(
                child: Column(
                  children: List.generate(themes.length, (themeIndex) {
                    final theme = themes[themeIndex];
                    final themeQuestions = questionsByTheme[theme.id] ?? [];

                    return GameRow(
                      theme: theme,
                      questions: themeQuestions,
                      costs: costs,
                      questionStates: questionStates,
                      onQuestionTap: onQuestionTap,
                      height: adaptiveCellHeight,
                      themeFlex: themeFlex,
                    );
                  }),
                ),
              ),
              // Панель игроков
              const PlayersPanel(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_off,
              size: 48,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет тем в этом раунде',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
