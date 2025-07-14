import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

enum AppFileType { image, video, audio }

class FileUtils {
  /// Универсальный метод для выбора изображения и получения пути (mobile/desktop)
  static Future<Map<String, dynamic>?> pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return null;

    // На mobile/desktop возвращаем путь и имя файла
    final path = result.files.single.path;
    final name = result.files.single.name;
    if (path == null) return null;
    return {'path': path, 'name': name};
  }

  /// Универсальный метод для выбора видео и получения пути (mobile/desktop)
  static Future<Map<String, dynamic>?> pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return null;

    final path = result.files.single.path;
    final name = result.files.single.name;
    if (path == null) return null;
    return {'path': path, 'name': name};
  }

  /// Универсальный метод для выбора аудио и получения пути (mobile/desktop)
  static Future<Map<String, dynamic>?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null) return null;

    final path = result.files.single.path;
    final name = result.files.single.name;
    if (path == null) return null;
    return {'path': path, 'name': name};
  }

  /// Копирует файл в постоянное хранилище приложения
  /// Возвращает новый путь к файлу или null в случае ошибки
  static Future<String?> copyFileToAppDirectory(
    String sourcePath, {
    AppFileType? fileType,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        log('Исходный файл не существует: $sourcePath');
        return null;
      }

      // Получаем директорию документов приложения
      final appDir = await getApplicationDocumentsDirectory();

      // Определяем подпапку в зависимости от типа файла
      String subDir;
      switch (fileType) {
        case AppFileType.image:
          subDir = 'images';
          break;
        case AppFileType.video:
          subDir = 'videos';
          break;
        case AppFileType.audio:
          subDir = 'audio';
          break;
        default:
          // Если тип не указан, пытаемся определить по расширению
          final extension = path.extension(sourcePath).toLowerCase();
          if ([
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.bmp',
            '.webp',
          ].contains(extension)) {
            subDir = 'images';
          } else if ([
            '.mp4',
            '.avi',
            '.mov',
            '.mkv',
            '.wmv',
            '.flv',
          ].contains(extension)) {
            subDir = 'videos';
          } else if ([
            '.mp3',
            '.wav',
            '.aac',
            '.ogg',
            '.m4a',
            '.flac',
          ].contains(extension)) {
            subDir = 'audio';
          } else {
            subDir = 'files';
          }
      }

      final targetDir = Directory('${appDir.path}/$subDir');

      // Создаем директорию, если она не существует
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Генерируем уникальное имя файла
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourcePath)}';
      final destinationPath = '${targetDir.path}/$fileName';

      // Копируем файл
      await sourceFile.copy(destinationPath);

      log('Файл скопирован: $sourcePath -> $destinationPath');
      return destinationPath;
    } catch (e) {
      log('Ошибка копирования файла: $e');
      return null;
    }
  }

  /// Проверяет, существует ли файл и доступен ли он
  static Future<bool> isFileAccessible(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      log('Ошибка проверки файла: $e');
      return false;
    }
  }

  /// Удаляет файл из постоянного хранилища
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        log('Файл удален: $filePath');
        return true;
      }
      log('Файл не найден для удаления: $filePath');
      return false;
    } catch (e) {
      log('Ошибка удаления файла: $e');
      return false;
    }
  }

  /// Очищает все файлы из директории приложения
  static Future<void> clearAllFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final subDirs = ['images', 'videos', 'audio', 'files'];

      for (final subDir in subDirs) {
        final dir = Directory('${appDir.path}/$subDir');
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          log('Директория удалена: ${dir.path}');
        }
      }
    } catch (e) {
      log('Ошибка очистки файлов: $e');
    }
  }
}
