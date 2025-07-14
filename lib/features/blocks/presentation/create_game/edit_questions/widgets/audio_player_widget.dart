import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  String? _filePath;
  Duration? _audioDuration;
  int _selectedMinute = 0;
  int _selectedSecond = 0;
  int _selectedStopMinute = 0;
  int _selectedStopSecond = 0;
  int _maxMinute = 59;
  int _maxSecond = 59;
  int _maxStopMinute = 59;
  int _maxStopSecond = 59;
  bool _isFileChosen = false;
  String? _warning;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _validateWarning() {
    final start = Duration(minutes: _selectedMinute, seconds: _selectedSecond);
    final stop = Duration(
      minutes: _selectedStopMinute,
      seconds: _selectedStopSecond,
    );
    if (stop <= start) {
      _warning = 'Время окончания должно быть больше времени начала!';
    } else {
      _warning = null;
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _isFileChosen = true;
        _filePath = result.files.single.path;
      });
      await _player.setFilePath(_filePath!);
      setState(() {
        _audioDuration = _player.duration;
        _maxMinute = _audioDuration!.inMinutes;
        _maxStopMinute = _audioDuration!.inMinutes;
        _selectedStopMinute = _maxMinute;
        _selectedStopSecond = _audioDuration!.inSeconds % 60;
        _maxStopSecond = _selectedStopSecond;
      });
    }
  }

  Future<void> _play() async {
    if (_filePath == null) return;
    final start = Duration(minutes: _selectedMinute, seconds: _selectedSecond);
    final stop = Duration(
      minutes: _selectedStopMinute,
      seconds: _selectedStopSecond,
    );
    if (start < stop) {
      await _player.seek(start);
      await _player.setClip(start: start, end: stop);
      await _player.play();
    }
  }

  Future<void> _stop() async {
    await _player.stop();
  }

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
                  onPressed: _pickFile,
                  child: const Text(
                    'Выбрать аудио',
                    style: TextStyle(color: Colors.amber),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _filePath != null
                        ? _filePath!.split('/').last
                        : 'Файл не выбран',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_audioDuration != null && _isFileChosen) ...[
              TimePickerRow(
                label: 'Старт:',
                maxMinute: _maxMinute,
                maxSecond: _maxSecond,
                selectedMinute: _selectedMinute,
                selectedSecond: _selectedSecond,
                onMinuteChanged: (index) {
                  setState(() {
                    _selectedMinute = index;
                    if (_selectedMinute == _maxMinute) {
                      _maxSecond = _audioDuration!.inSeconds % 60;
                    } else {
                      _maxSecond = 59;
                    }
                    _validateWarning();
                  });
                },
                onSecondChanged: (index) {
                  setState(() {
                    _selectedSecond = index;
                    _validateWarning();
                  });
                },
                audioDuration: _audioDuration,
              ),
              const SizedBox(height: 16),
              TimePickerRow(
                label: 'Стоп: ',
                maxMinute: _maxStopMinute,
                maxSecond: _maxStopSecond,
                selectedMinute: _selectedStopMinute,
                selectedSecond: _selectedStopSecond,
                onMinuteChanged: (index) {
                  setState(() {
                    _selectedStopMinute = index;
                    if (_selectedStopMinute == _maxStopMinute) {
                      _selectedStopSecond = _maxStopSecond;
                      _maxStopSecond = _audioDuration!.inSeconds % 60;
                    } else {
                      _maxStopSecond = 59;
                    }
                    _validateWarning();
                  });
                },
                onSecondChanged: (index) {
                  setState(() {
                    _selectedStopSecond = index;
                    _validateWarning();
                  });
                },
                audioDuration: _audioDuration,
              ),
              if (_warning != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _warning!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: _play, child: const Text('Play')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _stop, child: const Text('Stop')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TimePickerRow extends StatelessWidget {
  final String label;
  final int maxMinute;
  final int maxSecond;
  final int selectedMinute;
  final int selectedSecond;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<int> onSecondChanged;
  final Duration? audioDuration;

  const TimePickerRow({
    super.key,
    required this.label,
    required this.maxMinute,
    required this.maxSecond,
    required this.selectedMinute,
    required this.selectedSecond,
    required this.onMinuteChanged,
    required this.onSecondChanged,
    this.audioDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedMinute,
                    ),
                    itemExtent: 32,
                    onSelectedItemChanged: onMinuteChanged,
                    children: List.generate(
                      maxMinute + 1,
                      (i) => Center(child: Text(i.toString().padLeft(2, '0'))),
                    ),
                  ),
                ),
                const Text(':'),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedSecond,
                    ),
                    itemExtent: 32,
                    onSelectedItemChanged: onSecondChanged,
                    children: List.generate(
                      maxSecond + 1,
                      (i) => Center(child: Text(i.toString().padLeft(2, '0'))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (audioDuration != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '/ ${audioDuration!.inMinutes.toString().padLeft(2, '0')}:${(audioDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
            ),
          ),
      ],
    );
  }
}
