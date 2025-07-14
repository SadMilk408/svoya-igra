import 'package:flutter/material.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/question_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_text_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_image_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/audio_player_data.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/widgets/movable_resizable_video.dart';

class QuestionContentDisplay extends StatefulWidget {
  final QuestionTabData data;

  const QuestionContentDisplay({super.key, required this.data});

  @override
  State<QuestionContentDisplay> createState() => _QuestionContentDisplayState();
}

class _QuestionContentDisplayState extends State<QuestionContentDisplay> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  // bool _isVideoPlaying = false;
  bool _isAudioPlaying = false;
  // Duration _videoPosition = Duration.zero;
  Duration _audioPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  // double _calculateVideoProgress(MovableResizableVideoData videoData) {
  //   final intervalDuration = videoData.endPosition - videoData.startPosition;
  //   if (intervalDuration.inMilliseconds <= 0) return 0.0;

  //   final currentProgress = _videoPosition - videoData.startPosition;
  //   if (currentProgress.inMilliseconds <= 0) return 0.0;

  //   return (currentProgress.inMilliseconds / intervalDuration.inMilliseconds)
  //       .clamp(0.0, 1.0);
  // }

  double _calculateAudioProgress(AudioPlayerData audioData) {
    final intervalDuration = audioData.endPosition - audioData.startPosition;
    if (intervalDuration.inMilliseconds <= 0) return 0.0;

    final currentProgress = _audioPosition - audioData.startPosition;
    if (currentProgress.inMilliseconds <= 0) return 0.0;

    return (currentProgress.inMilliseconds / intervalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Widget _buildAudioProgressBar(AudioPlayerData audioData) {
    final progress = _calculateAudioProgress(audioData);

    return Container(
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // Фоновая дорожка
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          // Прогресс
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeMedia() {
    // Инициализация видео
    if (widget.data.video != null) {
      _videoController = VideoPlayerController.file(
        File(widget.data.video!.videoPath),
      );
      _videoController!
          .initialize()
          .then((_) {
            if (mounted) {
              _videoController!.addListener(() {
                if (mounted) {
                  setState(() {
                    // _videoPosition = _videoController!.value.position;
                    // _isVideoPlaying = _videoController!.value.isPlaying;
                  });
                }
              });
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _videoController = null;
              });
            }
          });
    }

    // Инициализация аудио
    if (widget.data.audio != null) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!
          .setFilePath(widget.data.audio!.audioPath)
          .then((_) {})
          .catchError((_) {
            if (mounted) {
              setState(() {
                _audioPlayer = null;
              });
            }
          });
      _audioPlayer!.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _audioPosition = position;
          });
        }
      });
      _audioPlayer!.playingStream.listen((playing) {
        if (mounted) {
          setState(() {
            _isAudioPlaying = playing;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Текстовые элементы
        ...widget.data.textItems.map((textData) => _buildTextWidget(textData)),
        // Изображение
        if (widget.data.image != null) _buildImageWidget(widget.data.image!),
        // Видео
        if (widget.data.video != null)
          MovableResizableVideoWidget(
            data: widget.data.video!,
            settings: false,
          ),
        // Аудио
        if (widget.data.audio != null) _buildAudioWidget(widget.data.audio!),
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

  Widget _buildAudioWidget(AudioPlayerData audioData) {
    return Positioned(
      left: audioData.position.dx,
      top: audioData.position.dy,
      child: Container(
        width: 280,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Красивая кнопка воспроизведения
            if (_audioPlayer != null)
              GestureDetector(
                onTap: () {
                  if (_isAudioPlaying) {
                    _audioPlayer!.pause();
                  } else {
                    // Если аудио было остановлено, продолжаем с того же места
                    // Если только запускаем, начинаем с заданной позиции
                    if (_audioPosition < audioData.startPosition) {
                      _audioPlayer!.seek(audioData.startPosition);
                    }
                    _audioPlayer!.play();
                    // Остановить аудио в конце интервала
                    _audioPlayer!.positionStream.listen((position) {
                      if (position >= audioData.endPosition) {
                        _audioPlayer!.pause();
                        _audioPlayer!.seek(audioData.startPosition);
                      }
                    });
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            const SizedBox(height: 16),
            // Прогресс-бар
            if (_audioPlayer != null)
              _buildAudioProgressBar(audioData)
            else
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
