import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_video_data.dart';
import 'package:flutter/foundation.dart';

class MovableResizableVideoWidget extends StatefulWidget {
  final MovableResizableVideoData data;
  final void Function(MovableResizableVideoData data)? onDone;
  final VoidCallback? onDelete;
  final bool settings;

  const MovableResizableVideoWidget({
    super.key,
    required this.data,
    this.onDone,
    this.onDelete,
    this.settings = true,
  });

  @override
  State<MovableResizableVideoWidget> createState() =>
      _MovableResizableVideoWidgetState();
}

class _MovableResizableVideoWidgetState
    extends State<MovableResizableVideoWidget> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MovableResizableVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.videoPath != widget.data.videoPath) {
      _controller?.dispose();
      _initializeController();
    }
  }

  Future<void> _initializeController() async {
    try {
      if (kIsWeb && widget.data.videoPath.startsWith('assets/')) {
        _controller = VideoPlayerController.asset(widget.data.videoPath);
      } else {
        _controller = VideoPlayerController.file(File(widget.data.videoPath));
      }
      await _controller!.initialize();
      await _controller!.seekTo(widget.data.startPosition);
      _controller!.addListener(_onVideoProgress);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке видео: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onVideoProgress() {
    if (_controller != null && _controller!.value.isInitialized) {
      final currentPosition = _controller!.value.position;
      final endPosition = widget.data.endPosition;
      // Если достигли времени окончания, останавливаем воспроизведение
      if (currentPosition >= endPosition) {
        _controller!.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        setState(() {}); // Динамически обновлять прогресс-бар
      }
    }
  }

  Future<void> _playVideo() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isPlaying) {
      // Останавливаем воспроизведение (ставим на паузу, не возвращаем к началу)
      await _controller!.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      try {
        // Если текущая позиция вне выбранного отрезка — переместить к startPosition
        final pos = _controller!.value.position;
        if (pos < widget.data.startPosition || pos > widget.data.endPosition) {
          await _controller!.seekTo(widget.data.startPosition);
        }
        await _controller!.play();
      } catch (e) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _onMoveDrag(DragUpdateDetails details) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    Offset newPos = widget.data.position + details.delta;
    if (widget.data.size < screenH && widget.data.size < screenW) {
      newPos = Offset(
        newPos.dx.clamp(0.0, screenW - widget.data.size),
        newPos.dy.clamp(0.0, screenH - widget.data.size),
      );
    }

    final updatedData = widget.data.copyWith(position: newPos);
    widget.onDone?.call(updatedData);
  }

  void _onResizeDrag(DragUpdateDetails details) {
    double delta =
        details.delta.dx.abs() > details.delta.dy.abs()
            ? details.delta.dx
            : details.delta.dy;

    double newSize = widget.data.size + delta;
    newSize = newSize.clamp(100.0, 800.0);

    final updatedData = widget.data.copyWith(size: newSize);
    widget.onDone?.call(updatedData);
  }

  Future<void> _showVideoSettingsDialog() async {
    Duration tempStartPosition = widget.data.startPosition;
    Duration tempEndPosition = widget.data.endPosition;
    Duration? videoDuration;

    if (_controller != null && _controller!.value.isInitialized) {
      videoDuration = _controller!.value.duration;
    }

    // Переменные для скроллеров
    int selectedStartMinute = tempStartPosition.inMinutes;
    int selectedStartSecond = tempStartPosition.inSeconds % 60;
    int selectedEndMinute = tempEndPosition.inMinutes;
    int selectedEndSecond = tempEndPosition.inSeconds % 60;
    int maxMinute = videoDuration?.inMinutes ?? 0;

    // Функции для вычисления максимального количества секунд
    int getMaxStartSecond() {
      if (selectedStartMinute == maxMinute && videoDuration != null) {
        return videoDuration.inSeconds % 60;
      }
      return 59;
    }

    int getMaxEndSecond() {
      if (selectedEndMinute == maxMinute && videoDuration != null) {
        return videoDuration.inSeconds % 60;
      }
      return 59;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            String? warning;
            // Проверяем валидность времени
            if (tempStartPosition >= tempEndPosition) {
              warning = 'Время начала должно быть меньше времени окончания';
            } else {
              warning = null;
            }

            // Сброс секунд если они больше максимума
            final maxStartSecond = getMaxStartSecond();
            if (selectedStartSecond > maxStartSecond) {
              selectedStartSecond = maxStartSecond;
              tempStartPosition = Duration(
                minutes: selectedStartMinute,
                seconds: selectedStartSecond,
              );
            }
            final maxEndSecond = getMaxEndSecond();
            if (selectedEndSecond > maxEndSecond) {
              selectedEndSecond = maxEndSecond;
              tempEndPosition = Duration(
                minutes: selectedEndMinute,
                seconds: selectedEndSecond,
              );
            }

            return AlertDialog(
              title: const Text('Настройки времени видео'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (videoDuration != null) ...[
                      // Начальная позиция
                      Row(
                        children: [
                          const Text('Старт:'),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            height: 60,
                            child: TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                              cursorColor: Colors.white,
                              initialValue: selectedStartMinute.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'мин',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
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
                                setStateDialog(() {
                                  selectedStartMinute = val.clamp(0, maxMinute);
                                  if (selectedStartSecond >
                                      getMaxStartSecond()) {
                                    selectedStartSecond = getMaxStartSecond();
                                  }
                                  tempStartPosition = Duration(
                                    minutes: selectedStartMinute,
                                    seconds: selectedStartSecond,
                                  );
                                });
                              },
                            ),
                          ),
                          const Text(':'),
                          SizedBox(
                            width: 120,
                            height: 60,
                            child: TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                              cursorColor: Colors.white,
                              initialValue: selectedStartSecond.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'сек',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
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
                                setStateDialog(() {
                                  selectedStartSecond = val.clamp(
                                    0,
                                    getMaxStartSecond(),
                                  );
                                  tempStartPosition = Duration(
                                    minutes: selectedStartMinute,
                                    seconds: selectedStartSecond,
                                  );
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '/ ${videoDuration.inMinutes.toString().padLeft(2, '0')}:${(videoDuration.inSeconds) % 60}'
                                  .padLeft(2, '0'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Конечная позиция
                      Row(
                        children: [
                          const Text('Конец:'),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            height: 60,
                            child: TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                              cursorColor: Colors.white,
                              initialValue: selectedEndMinute.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'мин',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
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
                                setStateDialog(() {
                                  selectedEndMinute = val.clamp(0, maxMinute);
                                  if (selectedEndSecond > getMaxEndSecond()) {
                                    selectedEndSecond = getMaxEndSecond();
                                  }
                                  tempEndPosition = Duration(
                                    minutes: selectedEndMinute,
                                    seconds: selectedEndSecond,
                                  );
                                });
                              },
                            ),
                          ),
                          const Text(':'),
                          SizedBox(
                            width: 120,
                            height: 60,
                            child: TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                              cursorColor: Colors.white,
                              initialValue: selectedEndSecond.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'сек',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
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
                                setStateDialog(() {
                                  selectedEndSecond = val.clamp(
                                    0,
                                    getMaxEndSecond(),
                                  );
                                  tempEndPosition = Duration(
                                    minutes: selectedEndMinute,
                                    seconds: selectedEndSecond,
                                  );
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '/ ${videoDuration.inMinutes.toString().padLeft(2, '0')}:${(videoDuration.inSeconds) % 60}'
                                  .padLeft(2, '0'),
                            ),
                          ),
                        ],
                      ),
                      if (warning != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            warning,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed:
                      tempStartPosition >= tempEndPosition
                          ? null
                          : () {
                            final updatedData = widget.data.copyWith(
                              startPosition: tempStartPosition,
                              endPosition: tempEndPosition,
                            );
                            widget.onDone?.call(updatedData);
                            Navigator.of(context).pop();
                          },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _getIntervalProgress() {
    if (_controller == null || !_controller!.value.isInitialized) return 0.0;
    final pos = _controller!.value.position;
    final start = widget.data.startPosition;
    final end = widget.data.endPosition;
    final interval = end - start;
    if (interval.inMilliseconds <= 0) return 0.0;
    final current = pos - start;
    if (current.inMilliseconds <= 0) return 0.0;
    return (current.inMilliseconds / interval.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.videoPath.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: widget.data.position.dx,
      top: widget.data.position.dy,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            width: widget.data.size,
            height: widget.data.size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                _controller != null && _controller!.value.isInitialized
                    ? GestureDetector(
                      onTap: _playVideo,
                      child: Container(
                        color: Colors.red,
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                            // Прогресс-бар поверх видео
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: LinearProgressIndicator(
                                  value: _getIntervalProgress(),
                                  backgroundColor: Colors.transparent,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          if (widget.settings) ...[
            // Move handle (top-left)
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
            // Resize handle (bottom-right)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onPanUpdate: _onResizeDrag,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: const Icon(Icons.open_in_full, color: Colors.white),
                  ),
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
            // Settings handle (bottom-left)
            Positioned(
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _showVideoSettingsDialog,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.settings, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
