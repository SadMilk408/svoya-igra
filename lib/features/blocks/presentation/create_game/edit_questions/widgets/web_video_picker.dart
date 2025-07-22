import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebVideoPicker extends StatefulWidget {
  final void Function(String assetPath) onSelected;
  const WebVideoPicker({super.key, required this.onSelected});

  @override
  State<WebVideoPicker> createState() => _WebVideoPickerState();
}

class _WebVideoPickerState extends State<WebVideoPicker> {
  final controller = TextEditingController();
  String? error;

  Future<void> _checkAndSelect() async {
    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      setState(() => error = 'Введите имя файла');
      return;
    }
    final assetPath = 'assets/video/$fileName';
    try {
      await rootBundle.load(assetPath);
      widget.onSelected(assetPath);
      setState(() => error = null);
    } catch (_) {
      setState(() => error = 'Файл не найден: $assetPath');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выбор видеофайла из ассетов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Имя файла',
                hintText: 'например, video.mp4',
                errorText: error,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _checkAndSelect,
                child: const Text('Добавить видео'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
