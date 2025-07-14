import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_image_data.dart';
import 'package:flutter/foundation.dart';

class MovableResizableImageWidget extends StatefulWidget {
  final MovableResizableImageData data;
  final void Function(MovableResizableImageData data)? onDone;
  final VoidCallback? onDelete;

  const MovableResizableImageWidget({
    super.key,
    required this.data,
    this.onDone,
    this.onDelete,
  });

  @override
  State<MovableResizableImageWidget> createState() =>
      _MovableResizableImageWidgetState();
}

class _MovableResizableImageWidgetState
    extends State<MovableResizableImageWidget> {
  void _onMoveDrag(DragUpdateDetails details) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    Offset newPos = widget.data.position + details.delta;
    if (widget.data.size < screenH && widget.data.size < screenW) {
      newPos = Offset(
        newPos.dx.clamp(0.0, screenW - widget.data.size),
        newPos.dy.clamp(0.0, screenH - widget.data.size),
      );
    }

    final updatedData = widget.data.copyWith(position: newPos);
    widget.onDone?.call(updatedData);
  }

  void _onResizeDrag(DragUpdateDetails details) {
    double delta =
        details.delta.dx.abs() > details.delta.dy.abs()
            ? details.delta.dx
            : details.delta.dy;

    double newSize = widget.data.size + delta;
    newSize = newSize.clamp(100.0, 800.0);

    final updatedData = widget.data.copyWith(size: newSize);
    widget.onDone?.call(updatedData);
  }

  Widget _buildImageWidget() {
    try {
      final file = File(widget.data.imagePath);
      if (!file.existsSync()) {
        return _buildErrorWidget('Файл изображения не найден');
      }
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget('Ошибка загрузки изображения');
        },
      );
    } catch (e) {
      return _buildErrorWidget('Ошибка при открытии изображения');
    }
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.3),
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.data.position.dx,
      top: widget.data.position.dy,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            width: widget.data.size,
            height: widget.data.size,
            child: _buildImageWidget(),
          ),
          // Move handle (top-left)
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onPanUpdate: _onMoveDrag,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_with, color: Colors.white),
              ),
            ),
          ),
          // Resize handle (bottom-right)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onPanUpdate: _onResizeDrag,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: const Icon(Icons.open_in_full, color: Colors.white),
                ),
              ),
            ),
          ),
          // Delete handle (top-right)
          if (widget.onDelete != null)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
