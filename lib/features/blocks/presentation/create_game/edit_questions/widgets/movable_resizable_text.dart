import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_text_data.dart';

class MovableResizableTextWidget extends StatefulWidget {
  final MovableResizableTextData data;
  final void Function(MovableResizableTextData data)? onDone;
  final VoidCallback? onDelete;

  const MovableResizableTextWidget({
    super.key,
    required this.data,
    this.onDone,
    this.onDelete,
  });

  @override
  State<MovableResizableTextWidget> createState() =>
      _MovableResizableTextWidgetState();
}

class _MovableResizableTextWidgetState
    extends State<MovableResizableTextWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.data.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MovableResizableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.text != widget.data.text) {
      _controller.text = widget.data.text;
    }
  }

  void _onMoveDrag(DragUpdateDetails details) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    Offset newPos = widget.data.position + details.delta;
    if (widget.data.height < screenH && widget.data.width < screenW) {
      newPos = Offset(
        newPos.dx.clamp(0.0, screenW - widget.data.width),
        newPos.dy.clamp(0.0, screenH - widget.data.height),
      );
    }

    final updatedData = widget.data.copyWith(position: newPos);
    widget.onDone?.call(updatedData);
  }

  void _onResizeDrag(DragUpdateDetails details) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    double newWidth = (widget.data.width + details.delta.dx).clamp(
      60.0,
      double.infinity,
    );
    double newHeight = (widget.data.height + details.delta.dy).clamp(
      30.0,
      double.infinity,
    );
    if (widget.data.position.dx + newWidth > screenW) {
      newWidth = screenW - widget.data.position.dx;
    }
    if (widget.data.position.dy + newHeight > screenH) {
      newHeight = screenH - widget.data.position.dy;
    }

    final updatedData = widget.data.copyWith(
      width: newWidth,
      height: newHeight,
    );
    widget.onDone?.call(updatedData);
  }

  void _onTextChanged(String val) {
    final updatedData = widget.data.copyWith(text: val);
    widget.onDone?.call(updatedData);
  }

  Future<void> _showTextSettingsDialog() async {
    double tempFontSize = widget.data.fontSize;
    TextAlign tempAlign = widget.data.textAlign;
    Color tempColor = widget.data.color;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Настройки текста'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Размер текста
                  Row(
                    children: [
                      const Text('Размер:'),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.blue,
                            inactiveTrackColor: Colors.grey.withValues(
                              alpha: 0.3,
                            ),
                            thumbColor: Colors.blue,
                            overlayColor: Colors.blue.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            min: 12,
                            max: 120,
                            value: tempFontSize,
                            onChanged:
                                (v) => setStateDialog(() => tempFontSize = v),
                          ),
                        ),
                      ),
                      Text(tempFontSize.toInt().toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Выравнивание
                  Row(
                    children: [
                      const Text('Выравнивание:'),
                      const SizedBox(width: 8),
                      ToggleButtons(
                        isSelected: [
                          tempAlign == TextAlign.left,
                          tempAlign == TextAlign.center,
                          tempAlign == TextAlign.right,
                        ],
                        onPressed: (idx) {
                          setStateDialog(() {
                            if (idx == 0) tempAlign = TextAlign.left;
                            if (idx == 1) tempAlign = TextAlign.center;
                            if (idx == 2) tempAlign = TextAlign.right;
                          });
                        },
                        selectedColor: Colors.white,
                        selectedBorderColor: Colors.blue,
                        fillColor: Colors.blue.withValues(alpha: 0.7),
                        color: Colors.grey,
                        borderColor: Colors.grey.withValues(alpha: 0.3),
                        children: const [
                          Icon(Icons.format_align_left),
                          Icon(Icons.format_align_center),
                          Icon(Icons.format_align_right),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Цвет
                  Row(
                    children: [
                      const Text('Цвет:'),
                      const SizedBox(width: 8),
                      ...[
                        Colors.white,
                        Colors.black,
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                      ].map(
                        (c) => GestureDetector(
                          onTap: () => setStateDialog(() => tempColor = c),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    tempColor == c ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final updatedData = widget.data.copyWith(
                  fontSize: tempFontSize,
                  textAlign: tempAlign,
                  color: tempColor,
                );
                widget.onDone?.call(updatedData);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.data.position.dx,
      top: widget.data.position.dy,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: widget.data.width,
            height: widget.data.height,
            child: TextField(
              controller: _controller,
              style: TextStyle(
                fontSize: widget.data.fontSize,
                color: widget.data.color,
              ),
              textAlign: widget.data.textAlign,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: _onTextChanged,
              maxLines: null,
              expands: true,
            ),
          ),
          // Move handle (top-left)
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
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
          // Font size/settings handle (bottom-left)
          Positioned(
            left: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _showTextSettingsDialog,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.format_size, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
