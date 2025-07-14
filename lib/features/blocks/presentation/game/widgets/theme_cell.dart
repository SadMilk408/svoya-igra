import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/theme/app_theme.dart';

class ThemeCell extends StatelessWidget {
  final ThemeEntity theme;
  final double height;
  final double flex;

  const ThemeCell({
    super.key,
    required this.theme,
    this.height = 80,
    this.flex = 2,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = AppTheme.getCellGradient();
    final borderColor = AppTheme.getBorderColor();

    return Expanded(
      flex: flex.toInt(),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(color: borderColor, width: 4),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildAdaptiveText(constraints);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveText(BoxConstraints constraints) {
    // Начинаем с максимального размера шрифта
    double fontSize = 32;
    const minFontSize = 12.0;

    // Учитываем отступы
    final availableWidth =
        constraints.maxWidth - 16; // 8px padding с каждой стороны
    final availableHeight =
        constraints.maxHeight - 16; // 8px padding с каждой стороны

    // Создаем TextPainter для измерения текста
    final textPainter = TextPainter(
      text: TextSpan(
        text: theme.blockName,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );

    // Уменьшаем размер шрифта, пока текст не поместится
    while (fontSize > minFontSize) {
      textPainter.text = TextSpan(
        text: theme.blockName,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      );

      textPainter.layout(maxWidth: availableWidth);

      if (textPainter.height <= availableHeight) {
        break;
      }

      fontSize -= 1;
    }

    return Text(
      theme.blockName,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1.5,
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }
}
