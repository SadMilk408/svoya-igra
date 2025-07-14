import '../utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_video_data.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/edit_question_cubit.dart';

class VideoPickerWidget extends StatefulWidget {
  final bool isAnswer;
  final VoidCallback? onVideoAdded;

  const VideoPickerWidget({
    super.key,
    required this.isAnswer,
    this.onVideoAdded,
  });

  @override
  State<VideoPickerWidget> createState() => _VideoPickerWidgetState();
}

class _VideoPickerWidgetState extends State<VideoPickerWidget> {
  String? _fileName;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FileUtils.pickVideoFile();
      if (result == null) return;
      MovableResizableVideoData videoData;

      if (result.containsKey('path')) {
        final copiedPath = await FileUtils.copyFileToAppDirectory(
          result['path'],
          fileType: AppFileType.video,
        );
        if (copiedPath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ошибка при копировании видео файла'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        videoData = MovableResizableVideoData(
          videoPath: copiedPath,
          size: 300,
          position: const Offset(100, 100),
          startPosition: Duration.zero,
          endPosition: const Duration(seconds: 10),
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
        context.read<EditQuestionCubit>().setVideo(
          videoData,
          isAnswer: widget.isAnswer,
        );
        setState(() {
          _fileName = result['name'];
        });
        widget.onVideoAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе видео: $e'),
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
              onPressed: _pickVideo,
              child: const Text('Выбрать видео'),
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
