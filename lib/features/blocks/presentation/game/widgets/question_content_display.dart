import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/question_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_text_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_image_data.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/widgets/movable_resizable_audio.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/widgets/movable_resizable_video.dart';

class QuestionContentDisplay extends StatelessWidget {
  final QuestionTabData data;

  const QuestionContentDisplay({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Текстовые элементы
        ...data.textItems.map((textData) => _buildTextWidget(textData)),
        // Изображение
        if (data.image != null) _buildImageWidget(data.image!),
        // Видео
        if (data.video != null)
          MovableResizableVideoWidget(data: data.video!, settings: false),
        // Аудио
        if (data.audio != null)
          MovableResizableAudioWidget(data: data.audio!, settings: false),
      ],
    );
  }

  Widget _buildTextWidget(MovableResizableTextData textData) {
    return Positioned(
      left: textData.position.dx,
      top: textData.position.dy,
      child: Container(
        width: textData.width.toDouble(),
        height: textData.height.toDouble(),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Center(
          child: Text(
            textData.text,
            style: TextStyle(
              fontSize: textData.fontSize.toDouble(),
              color: textData.color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: textData.textAlign,
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(MovableResizableImageData imageData) {
    return Positioned(
      left: imageData.position.dx,
      top: imageData.position.dy,
      child: SizedBox(
        width: imageData.size,
        height: imageData.size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(imageData),
        ),
      ),
    );
  }

  Widget _buildImage(MovableResizableImageData imageData) {
    if (imageData.imagePath.isNotEmpty) {
      return Image.file(
        File(imageData.imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget('Ошибка загрузки изображения');
        },
      );
    } else {
      return _buildErrorWidget('Файл изображения не найден');
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
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
