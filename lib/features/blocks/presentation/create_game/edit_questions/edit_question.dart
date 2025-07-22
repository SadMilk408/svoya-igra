import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/bloc/structure_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_text_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/widgets/video_picker_widget.dart';
import 'edit_question_cubit.dart';

import 'widgets/image_picker_widget.dart';
import 'widgets/movable_resizable_text.dart';
import 'widgets/movable_resizable_video.dart';
import 'widgets/movable_resizable_image.dart';
import 'widgets/movable_resizable_audio.dart';
import 'widgets/audio_picker_widget.dart';

class EditQuestion extends StatelessWidget {
  const EditQuestion({super.key, required this.tempChild});
  final QuestionEntity tempChild;

  @override
  Widget build(BuildContext context) {
    final questionEntity = tempChild;

    return BlocProvider(
      create: (_) => EditQuestionCubit(questionEntity),
      child: _EditQuestionContent(tempChild: questionEntity),
    );
  }
}

class _EditQuestionContent extends StatefulWidget {
  const _EditQuestionContent({required this.tempChild});
  final QuestionEntity tempChild;

  @override
  State<_EditQuestionContent> createState() => _EditQuestionContentState();
}

class _EditQuestionContentState extends State<_EditQuestionContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSaveAndGoBack() {
    if (_isSaving) return; // Защита от повторного сохранения
    _isSaving = true;

    final currentQuestionData = context.read<EditQuestionCubit>().state;

    // Отладочная информация
    final questionEntity = widget.tempChild;
    final updatedQuestionEntity = questionEntity.copyWithQuestion(
      questionData: currentQuestionData,
    );

    context.read<GameStructureBloc>().add(
      QuestionEdit(updatedQuestionEntity, widget.tempChild),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            content: Text('Данные сохранены'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 500),
          ),
        )
        .closed
        .then((_) {
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            Navigator.of(context).pop();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Material(
          color: const Color(0xFF1a237e), // Темно-синий цвет
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _onSaveAndGoBack,
                ),
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Вопрос', icon: null),
                      Tab(text: 'Ответ', icon: null),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EditQuestionTabArea(isAnswer: false),
          EditQuestionTabArea(isAnswer: true),
        ],
      ),
    );
  }
}

class EditQuestionTabArea extends StatefulWidget {
  const EditQuestionTabArea({super.key, required this.isAnswer});
  final bool isAnswer;

  @override
  State<EditQuestionTabArea> createState() => _EditQuestionTabAreaState();
}

class _EditQuestionTabAreaState extends State<EditQuestionTabArea> {
  bool _isAudioAdded = false;
  bool _isImageAdded = false;
  bool _isVideoAdded = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _addTextWidget() {
    final textData = MovableResizableTextData(
      text: '',
      fontSize: 24,
      color: Colors.white,
      textAlign: TextAlign.left,
      width: 240,
      height: 80,
      position: const Offset(100, 100),
    );
    context.read<EditQuestionCubit>().addText(
      textData,
      isAnswer: widget.isAnswer,
    );
  }

  void _addImageWidget() {
    // Если изображение уже есть, удаляем его
    if (widget.isAnswer
        ? context.read<EditQuestionCubit>().state.answer.image != null
        : context.read<EditQuestionCubit>().state.question.image != null) {
      context.read<EditQuestionCubit>().removeImage(isAnswer: widget.isAnswer);
    } else {
      // Иначе показываем пикер изображения
      setState(() {
        _isImageAdded = !_isImageAdded;
      });
    }
  }

  void _addVideoWidget() {
    // Если видео уже есть, удаляем его
    if (widget.isAnswer
        ? context.read<EditQuestionCubit>().state.answer.video != null
        : context.read<EditQuestionCubit>().state.question.video != null) {
      context.read<EditQuestionCubit>().removeVideo(isAnswer: widget.isAnswer);
    } else {
      // Иначе показываем пикер видео
      setState(() {
        _isVideoAdded = !_isVideoAdded;
      });
    }
  }

  void _addAudioWidget() {
    // Если аудио уже есть, удаляем его
    if (widget.isAnswer
        ? context.read<EditQuestionCubit>().state.answer.audio != null
        : context.read<EditQuestionCubit>().state.question.audio != null) {
      context.read<EditQuestionCubit>().removeAudio(isAnswer: widget.isAnswer);
    } else {
      // Иначе показываем пикер аудио
      setState(() {
        _isAudioAdded = !_isAudioAdded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionData = context.watch<EditQuestionCubit>().state;
    final tabData =
        widget.isAnswer ? questionData.answer : questionData.question;
    final textItems = tabData.textItems;
    final imageData = tabData.image;
    final videoData = tabData.video;
    final audioData = tabData.audio;

    return Column(
      children: [
        Container(
          color: Colors.black.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.text_fields, color: Colors.white),
                tooltip: 'Добавить текст',
                onPressed: _addTextWidget,
              ),
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: imageData != null ? Colors.blue : Colors.white,
                ),
                tooltip: 'Добавить картинку',
                onPressed: _addImageWidget,
              ),
              IconButton(
                icon: Icon(
                  Icons.videocam,
                  color: videoData != null ? Colors.blue : Colors.white,
                ),
                tooltip: 'Добавить видео',
                onPressed: _addVideoWidget,
              ),
              IconButton(
                icon: Icon(
                  Icons.audiotrack,
                  color: audioData != null ? Colors.blue : Colors.white,
                ),
                tooltip: 'Добавить аудио',
                onPressed: _addAudioWidget,
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
              // Отображение изображения из кубита
              if (imageData != null)
                MovableResizableImageWidget(
                  key: ValueKey(
                    'image-${widget.isAnswer ? 'answer' : 'question'}',
                  ),
                  data: imageData,
                  onDelete: () {
                    context.read<EditQuestionCubit>().removeImage(
                      isAnswer: widget.isAnswer,
                    );
                  },
                  onDone: (updatedData) {
                    context.read<EditQuestionCubit>().setImage(
                      updatedData,
                      isAnswer: widget.isAnswer,
                    );
                  },
                ),
              // Отображение видео из кубита
              if (videoData != null)
                MovableResizableVideoWidget(
                  key: ValueKey(
                    'video-${widget.isAnswer ? 'answer' : 'question'}',
                  ),
                  data: videoData,
                  onDelete: () {
                    context.read<EditQuestionCubit>().removeVideo(
                      isAnswer: widget.isAnswer,
                    );
                  },
                  onDone: (updatedData) {
                    context.read<EditQuestionCubit>().setVideo(
                      updatedData,
                      isAnswer: widget.isAnswer,
                    );
                  },
                ),
              // Отображение аудио из кубита
              if (audioData != null)
                MovableResizableAudioWidget(
                  key: ValueKey(
                    'audio-${widget.isAnswer ? 'answer' : 'question'}',
                  ),
                  data: audioData,
                  onDelete: () {
                    context.read<EditQuestionCubit>().removeAudio(
                      isAnswer: widget.isAnswer,
                    );
                  },
                  onDone: (updatedData) {
                    context.read<EditQuestionCubit>().setAudio(
                      updatedData,
                      isAnswer: widget.isAnswer,
                    );
                  },
                ),
              ...textItems.map(
                (data) => MovableResizableTextWidget(
                  key: ValueKey(data.id),
                  data: data,
                  onDelete: () {
                    context.read<EditQuestionCubit>().removeTextById(
                      data.id,
                      isAnswer: widget.isAnswer,
                    );
                  },
                  onDone: (updatedData) {
                    final index = textItems.indexWhere((e) => e.id == data.id);
                    if (index != -1) {
                      context.read<EditQuestionCubit>().updateText(
                        index,
                        updatedData,
                        isAnswer: widget.isAnswer,
                      );
                    }
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isImageAdded)
                    ImagePickerWidget(
                      isAnswer: widget.isAnswer,
                      onImageAdded: () {
                        setState(() {
                          _isImageAdded = false;
                        });
                      },
                    ),
                  if (_isVideoAdded)
                    VideoPickerWidget(
                      isAnswer: widget.isAnswer,
                      onVideoAdded: () {
                        setState(() {
                          _isVideoAdded = false;
                        });
                      },
                    ),
                  if (_isAudioAdded)
                    AudioPickerWidget(
                      isAnswer: widget.isAnswer,
                      onAudioAdded: () {
                        setState(() {
                          _isAudioAdded = false;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
