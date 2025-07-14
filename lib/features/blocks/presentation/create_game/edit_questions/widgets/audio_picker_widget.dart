import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/audio_player_data.dart';
import '../edit_question_cubit.dart';
import '../utils/file_utils.dart';

class AudioPickerWidget extends StatelessWidget {
  final bool isAnswer;
  final VoidCallback onAudioAdded;

  const AudioPickerWidget({
    super.key,
    required this.isAnswer,
    required this.onAudioAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickAudioFile(context),
                  child: const Text(
                    'Выбрать аудио',
                    style: TextStyle(color: Colors.amber),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Выберите аудиофайл для добавления',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAudioFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;

        // Копируем файл в постоянное хранилище приложения
        final copiedPath = await FileUtils.copyFileToAppDirectory(
          originalPath,
          fileType: AppFileType.audio,
        );

        if (copiedPath == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ошибка при копировании аудио файла'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Создаем данные аудио с позицией по умолчанию
        final audioData = AudioPlayerData(
          audioPath: copiedPath,
          startPosition: Duration.zero,
          endPosition: const Duration(minutes: 1), // По умолчанию 1 минута
          position: const Offset(100, 100), // Позиция по умолчанию
        );
        if (context.mounted) {
          // Добавляем аудио в кубит
          context.read<EditQuestionCubit>().setAudio(
            audioData,
            isAnswer: isAnswer,
          );
        }
        // Закрываем пикер
        onAudioAdded();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе аудио: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
