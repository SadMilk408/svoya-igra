import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/theme/app_theme.dart';
import 'theme_cell.dart';
import 'question_cell.dart';

class GameRow extends StatelessWidget {
  final ThemeEntity theme;
  final List<QuestionEntity> questions;
  final List<int> costs;
  final Map<String, QuestionState> questionStates;
  final Function(QuestionEntity)? onQuestionTap;
  final double height;
  final double themeFlex;

  const GameRow({
    super.key,
    required this.theme,
    required this.questions,
    required this.costs,
    required this.questionStates,
    this.onQuestionTap,
    this.height = 120, // Увеличиваем размер
    this.themeFlex = 2,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppTheme.getBorderColor();

    return Row(
      children: [
        // Ячейка темы
        ThemeCell(theme: theme, height: height, flex: themeFlex),
        // Ячейки вопросов
        ...costs.map((cost) {
          // Ищем вопрос с данной ценой
          final question = questions.firstWhere(
            (q) => q.cost == cost && q.themeId == theme.id,
            orElse:
                () => QuestionEntity(
                  id: '',
                  blockName: '',
                  parentName: theme.blockName,
                  cost: cost,
                  themeId: theme.id,
                ),
          );

          // Если вопрос не найден, показываем пустую ячейку
          if (question.blockName.isEmpty) {
            return Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppTheme.getCellGradient(),
                  ),
                  border: Border.all(color: borderColor, width: 4),
                ),
              ),
            );
          }

          // Используем ID вопроса как уникальный ключ
          final state =
              questionStates[question.id] ?? QuestionState.notSelected;

          return QuestionCell(
            question: question,
            cost: question.cost,
            state: state,
            onTap:
                onQuestionTap != null ? () => onQuestionTap!(question) : null,
            height: height,
          );
        }),
      ],
    );
  }
}
