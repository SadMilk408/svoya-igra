import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'drop_zone.dart';

class CustomImageViewer extends StatefulWidget {
  const CustomImageViewer({super.key});

  @override
  EditQuestionState createState() => EditQuestionState();
}

class EditQuestionState extends State<CustomImageViewer> {
  final ValueNotifier<Uint8List?> imageNotifier = ValueNotifier<Uint8List?>(
    null,
  );
  Offset _offset = const Offset(0, 0);
  double _imageSize = 500;
  bool _imageSelected = false;

  void _centerImage(BoxConstraints constraints) {
    setState(() {
      _offset = Offset(
        (constraints.maxWidth - _imageSize) / 2,
        (constraints.maxHeight - _imageSize) / 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              child: SizedBox(
                child: DropZone(
                  imageNotifier: imageNotifier,
                  onImageDropped: () => _centerImage(constraints),
                ),
              ),
            ),
            Positioned(
              left: _offset.dx,
              top: _offset.dy,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _imageSelected = !_imageSelected;
                      });
                    },
                    child: SizedBox(
                      width: _imageSize,
                      height: _imageSize,
                      child: ImageViewer(imageNotifier: imageNotifier),
                    ),
                  ),

                  if (_imageSelected) ...[
                    // Top-left handle (move picture)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onPanUpdate: (details) {
                          setState(() {
                            _offset = Offset(
                              _offset.dx + details.delta.dx,
                              _offset.dy + details.delta.dy,
                            );
                          });
                        },
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.open_with,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom-right handle (resize square)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onPanUpdate: (details) {
                          setState(() {
                            double delta =
                                details.delta.dx.abs() > details.delta.dy.abs()
                                    ? details.delta.dx
                                    : details.delta.dy;
                            _imageSize += delta;
                            if (_imageSize < 100) _imageSize = 100;
                            if (_imageSize > 500) _imageSize = 500;
                          });
                        },
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.open_in_full,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ImageViewer extends StatelessWidget {
  final ValueNotifier<Uint8List?> imageNotifier;

  const ImageViewer({super.key, required this.imageNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: imageNotifier,
      builder: (context, imageBytes, _) {
        if (imageBytes != null) {
          return Image.memory(
            imageBytes,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
