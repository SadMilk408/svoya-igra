import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/theme/app_theme.dart';

enum QuestionState {
  notSelected, // Не выбран - показывается цена
  selected, // Был выбран - пустая ячейка
}

class QuestionCell extends StatelessWidget {
  final QuestionEntity question;
  final int cost;
  final QuestionState state;
  final VoidCallback? onTap;
  final double height;

  const QuestionCell({
    super.key,
    required this.question,
    required this.cost,
    this.state = QuestionState.notSelected,
    this.onTap,
    this.height = 120, // Увеличиваем размер
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppTheme.getBorderColor();
    final priceColor = AppTheme.getPriceTextColor();

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
        child: _buildContent(priceColor),
      ),
    );
  }

  Widget _buildContent(Color priceColor) {
    switch (state) {
      case QuestionState.notSelected:
        return _buildNotSelectedQuestion(priceColor);
      case QuestionState.selected:
        return _buildSelectedQuestion();
    }
  }

  Widget _buildNotSelectedQuestion(Color priceColor) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          cost.toString(),
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: priceColor,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.7),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSelectedQuestion() {
    return GestureDetector(
      onLongPress: onTap, // Долгое нажатие для повторного открытия
      child: Container(
        color: Colors.transparent,

        // Пустой контейнер - цифра исчезла, но ячейка остается кликабельной
      ),
    );
  }
}
