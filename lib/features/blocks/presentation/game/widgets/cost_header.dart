import 'package:flutter/material.dart';

class CostHeader extends StatelessWidget {
  final List<int> costs;
  final double height;
  final double themeFlex;

  const CostHeader({
    super.key,
    required this.costs,
    this.height = 60,
    this.themeFlex = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (costs.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        // Пустая ячейка для выравнивания с темами
        Expanded(
          flex: themeFlex.toInt(),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
        ),
        // Столбцы со стоимостью
        ...costs.map(
          (cost) => Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  cost.toString(),
                  style: const TextStyle(
                    fontSize: 28, // Увеличиваем шрифт для больших ячеек
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
