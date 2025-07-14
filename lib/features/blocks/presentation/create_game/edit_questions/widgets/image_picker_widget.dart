import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_image_data.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/edit_question_cubit.dart';
import '../utils/file_utils.dart';

class ImagePickerWidget extends StatefulWidget {
  final bool isAnswer;
  final VoidCallback? onImageAdded;

  const ImagePickerWidget({
    super.key,
    required this.isAnswer,
    this.onImageAdded,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _fileName;

  Future<void> _pickImage() async {
    try {
      final result = await FileUtils.pickImageFile();
      if (result == null) return;
      MovableResizableImageData imageData;

      if (result.containsKey('path')) {
        final copiedPath = await FileUtils.copyFileToAppDirectory(
          result['path'],
          fileType: AppFileType.image,
        );
        if (copiedPath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ошибка при копировании изображения'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        imageData = MovableResizableImageData(
          imagePath: copiedPath,
          size: 300,
          position: const Offset(100, 100),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Неожиданный формат файла'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        context.read<EditQuestionCubit>().setImage(
          imageData,
          isAnswer: widget.isAnswer,
        );
        setState(() {
          _fileName = result['name'];
        });
        widget.onImageAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Выбрать картинку'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fileName ?? 'Файл не выбран',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
