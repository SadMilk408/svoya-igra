import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/audio_player_data.dart';
import 'package:flutter/foundation.dart';

class MovableResizableAudioWidget extends StatefulWidget {
  final AudioPlayerData data;
  final void Function(AudioPlayerData data)? onDone;
  final VoidCallback? onDelete;
  final bool settings;

  const MovableResizableAudioWidget({
    super.key,
    required this.data,
    this.onDone,
    this.onDelete,
    this.settings = true,
  });

  @override
  State<MovableResizableAudioWidget> createState() =>
      _MovableResizableAudioWidgetState();
}

class _MovableResizableAudioWidgetState
    extends State<MovableResizableAudioWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  StreamSubscription<Duration>? _positionSub;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.data.audioPath.isNotEmpty) {
        if (kIsWeb && widget.data.audioPath.startsWith('assets/')) {
          await _player.setAsset(widget.data.audioPath);
        } else if (File(widget.data.audioPath).existsSync()) {
          await _player.setFilePath(widget.data.audioPath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке аудио: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onMoveDrag(DragUpdateDetails details) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    Offset newPos = widget.data.position + details.delta;
    newPos = Offset(
      newPos.dx.clamp(0.0, screenW - 200),
      newPos.dy.clamp(0.0, screenH - 100),
    );

    final updatedData = widget.data.copyWith(position: newPos);
    widget.onDone?.call(updatedData);
  }

  Future<void> _play() async {
    if (widget.data.audioPath.isEmpty) return;

    if (_isPlaying) {
      await _player.stop();
      _positionSub?.cancel();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      try {
        await _player.seek(widget.data.startPosition);
        _positionSub?.cancel();
        _positionSub = _player.positionStream.listen((pos) async {
          if (pos >= widget.data.endPosition) {
            await _player.pause();
            await _player.seek(widget.data.startPosition);
            _positionSub?.cancel();
            if (mounted) {
              setState(() {
                _isPlaying = false;
              });
            }
          }
        });
        await _player.play();
      } catch (e) {
        _positionSub?.cancel();
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AudioSettingsDialog(
            data: widget.data,
            onDone: (updatedData) {
              widget.onDone?.call(updatedData);
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.audioPath.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: widget.data.position.dx,
      top: widget.data.position.dy,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            width: 200,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Аудио',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _play,
                      icon: Icon(
                        _isPlaying ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.settings)
                      IconButton(
                        onPressed: _showSettingsDialog,
                        icon: const Icon(Icons.settings, color: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Move handle (top-left)
          if (widget.settings) ...[
            Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
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
          ],
        ],
      ),
    );
  }
}

class AudioSettingsDialog extends StatefulWidget {
  final AudioPlayerData data;
  final void Function(AudioPlayerData data) onDone;

  const AudioSettingsDialog({
    super.key,
    required this.data,
    required this.onDone,
  });

  @override
  State<AudioSettingsDialog> createState() => _AudioSettingsDialogState();
}

class _AudioSettingsDialogState extends State<AudioSettingsDialog> {
  late int _selectedStartMinute;
  late int _selectedStartSecond;
  late int _selectedEndMinute;
  late int _selectedEndSecond;
  Duration? _audioDuration;
  String? _warning;

  @override
  void initState() {
    super.initState();
    _selectedStartMinute = widget.data.startPosition.inMinutes;
    _selectedStartSecond = widget.data.startPosition.inSeconds % 60;
    _selectedEndMinute = widget.data.endPosition.inMinutes;
    _selectedEndSecond = widget.data.endPosition.inSeconds % 60;
    _loadAudioDuration();
  }

  Future<void> _loadAudioDuration() async {
    try {
      if (widget.data.audioPath.isNotEmpty) {
        final player = AudioPlayer();

        if (kIsWeb && widget.data.audioPath.startsWith('assets/')) {
          await player.setAsset(widget.data.audioPath);
        } else if (File(widget.data.audioPath).existsSync()) {
          await player.setFilePath(widget.data.audioPath);
        }

        await player.setAsset(widget.data.audioPath);

        setState(() {
          _audioDuration = player.duration;
        });

        await player.dispose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке длительности аудио: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _validateWarning() {
    final start = Duration(
      minutes: _selectedStartMinute,
      seconds: _selectedStartSecond,
    );
    final end = Duration(
      minutes: _selectedEndMinute,
      seconds: _selectedEndSecond,
    );
    if (end <= start) {
      setState(() {
        _warning = 'Время окончания должно быть больше времени начала!';
      });
    } else {
      setState(() {
        _warning = null;
      });
    }
  }

  int getMaxStartSecond() {
    if (_audioDuration == null) return 59;
    if (_selectedStartMinute == _audioDuration!.inMinutes) {
      return _audioDuration!.inSeconds % 60;
    }
    return 59;
  }

  int getMaxEndSecond() {
    if (_audioDuration == null) return 59;
    if (_selectedEndMinute == _audioDuration!.inMinutes) {
      return _audioDuration!.inSeconds % 60;
    }
    return 59;
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.data.audioPath.split('/').last;

    return AlertDialog(
      title: const Text('Настройки аудио'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Название трека
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            if (_audioDuration != null) ...[
              Row(
                children: [
                  const Text('Старт:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    height: 60,
                    child: TextFormField(
                      initialValue: _selectedStartMinute.toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'мин',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.yellow,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged: (v) {
                        final val = int.tryParse(v) ?? 0;
                        setState(() {
                          _selectedStartMinute = val.clamp(
                            0,
                            _audioDuration!.inMinutes,
                          );
                          if (_selectedStartSecond > getMaxStartSecond()) {
                            _selectedStartSecond = getMaxStartSecond();
                          }
                          _validateWarning();
                        });
                      },
                    ),
                  ),
                  const Text(':'),
                  SizedBox(
                    width: 120,
                    height: 60,
                    child: TextFormField(
                      initialValue: _selectedStartSecond.toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'сек',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.yellow,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged: (v) {
                        final val = int.tryParse(v) ?? 0;
                        setState(() {
                          _selectedStartSecond = val.clamp(
                            0,
                            getMaxStartSecond(),
                          );
                          _validateWarning();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '/ ${_audioDuration!.inMinutes.toString().padLeft(2, '0')}:${(_audioDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Конец:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    height: 60,
                    child: TextFormField(
                      initialValue: _selectedEndMinute.toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'мин',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.yellow,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged: (v) {
                        final val = int.tryParse(v) ?? 0;
                        setState(() {
                          _selectedEndMinute = val.clamp(
                            0,
                            _audioDuration!.inMinutes,
                          );
                          if (_selectedEndSecond > getMaxEndSecond()) {
                            _selectedEndSecond = getMaxEndSecond();
                          }
                          _validateWarning();
                        });
                      },
                    ),
                  ),
                  const Text(':'),
                  SizedBox(
                    width: 120,
                    height: 60,
                    child: TextFormField(
                      initialValue: _selectedEndSecond.toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'сек',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.yellow,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged: (v) {
                        final val = int.tryParse(v) ?? 0;
                        setState(() {
                          _selectedEndSecond = val.clamp(0, getMaxEndSecond());
                          _validateWarning();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '/ ${_audioDuration!.inMinutes.toString().padLeft(2, '0')}:${(_audioDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_warning != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _warning!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black, width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black, width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed:
              _warning == null
                  ? () {
                    final updatedData = widget.data.copyWith(
                      startPosition: Duration(
                        minutes: _selectedStartMinute,
                        seconds: _selectedStartSecond,
                      ),
                      endPosition: Duration(
                        minutes: _selectedEndMinute,
                        seconds: _selectedEndSecond,
                      ),
                    );
                    widget.onDone(updatedData);
                  }
                  : null,
          child: const Text('OK'),
        ),
      ],
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
