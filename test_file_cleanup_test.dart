import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/utils/file_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileUtils Tests', () {
    test('should copy file to app directory with correct type', () async {
      // Создаем временный тестовый файл
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/test_image.jpg');
      await testFile.writeAsString('test content');

      // Копируем файл
      final copiedPath = await FileUtils.copyFileToAppDirectory(
        testFile.path,
        fileType: AppFileType.image,
      );

      // Проверяем, что файл скопирован
      expect(copiedPath, isNotNull);
      expect(File(copiedPath!).existsSync(), isTrue);

      // Проверяем, что файл находится в правильной папке
      expect(copiedPath.contains('/images/'), isTrue);

      // Очищаем
      await testFile.delete();
      await File(copiedPath).delete();
    });

    test('should delete file successfully', () async {
      // Создаем временный тестовый файл
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/test_delete.txt');
      await testFile.writeAsString('test content');

      // Проверяем, что файл существует
      expect(testFile.existsSync(), isTrue);

      // Удаляем файл
      final result = await FileUtils.deleteFile(testFile.path);

      // Проверяем результат
      expect(result, isTrue);
      expect(testFile.existsSync(), isFalse);
    });

    test('should handle non-existent file deletion gracefully', () async {
      final nonExistentPath = '/path/to/non/existent/file.txt';

      // Пытаемся удалить несуществующий файл
      final result = await FileUtils.deleteFile(nonExistentPath);

      // Проверяем, что функция не выбросила исключение
      expect(result, isFalse);
    });

    test(
      'should determine file type by extension when not specified',
      () async {
        // Создаем временные тестовые файлы
        final tempDir = await getTemporaryDirectory();
        final imageFile = File('${tempDir.path}/test.jpg');
        final videoFile = File('${tempDir.path}/test.mp4');
        final audioFile = File('${tempDir.path}/test.mp3');

        await imageFile.writeAsString('test');
        await videoFile.writeAsString('test');
        await audioFile.writeAsString('test');

        // Копируем файлы без указания типа
        final imagePath = await FileUtils.copyFileToAppDirectory(
          imageFile.path,
        );
        final videoPath = await FileUtils.copyFileToAppDirectory(
          videoFile.path,
        );
        final audioPath = await FileUtils.copyFileToAppDirectory(
          audioFile.path,
        );

        // Проверяем, что файлы попали в правильные папки
        expect(imagePath!.contains('/images/'), isTrue);
        expect(videoPath!.contains('/videos/'), isTrue);
        expect(audioPath!.contains('/audio/'), isTrue);

        // Очищаем
        await imageFile.delete();
        await videoFile.delete();
        await audioFile.delete();
        await File(imagePath).delete();
        await File(videoPath).delete();
        await File(audioPath).delete();
      },
    );
  });
}
