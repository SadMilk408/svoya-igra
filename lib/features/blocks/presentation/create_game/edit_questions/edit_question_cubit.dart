import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/question_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_text_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_image_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/movable_resizable_video_data.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/audio_player_data.dart';
import 'package:smartest_man/features/blocks/presentation/create_game/edit_questions/utils/file_utils.dart';

class EditQuestionCubit extends Cubit<QuestionData> {
  EditQuestionCubit(QuestionEntity questionEntity)
    : super(
        questionEntity.questionData ??
            QuestionData(
              question: QuestionTabData(),
              answer: QuestionTabData(),
            ),
      );

  void update({QuestionTabData? question, QuestionTabData? answer}) {
    emit(
      state.copyWith(
        question: question ?? state.question,
        answer: answer ?? state.answer,
      ),
    );
  }

  // Добавить текстовый элемент
  void addText(MovableResizableTextData textData, {bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);

    _updateTabData(
      tabData.copyWith(textItems: [...tabData.textItems, textData]),
      isAnswer,
    );
  }

  // Удалить текстовый элемент
  void removeTextById(String id, {bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);
    _updateTabData(
      tabData.copyWith(
        textItems: tabData.textItems.where((e) => e.id != id).toList(),
      ),
      isAnswer,
    );
  }

  // Обновить текстовый элемент
  void updateText(
    int index,
    MovableResizableTextData newData, {
    bool isAnswer = false,
  }) {
    final tabData = _getTabData(isAnswer);

    if (index >= 0 && index < tabData.textItems.length) {
      final newTextItems = List<MovableResizableTextData>.from(
        tabData.textItems,
      );
      newTextItems[index] = newData;
      _updateTabData(tabData.copyWith(textItems: newTextItems), isAnswer);
    }
  }

  // Добавить/обновить изображение
  void setImage(MovableResizableImageData imageData, {bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);
    _updateTabData(tabData.copyWith(image: imageData), isAnswer);
  }

  // Удалить изображение
  void removeImage({bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);

    // Удаляем файл изображения, если он существует
    if (tabData.image?.imagePath.isNotEmpty == true) {
      FileUtils.deleteFile(tabData.image!.imagePath);
    }

    _updateTabData(tabData.removeImage(), isAnswer);
  }

  // Добавить/обновить видео
  void setVideo(MovableResizableVideoData videoData, {bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);

    // Удаляем старый файл видео, если он существует и отличается от нового
    if (tabData.video?.videoPath.isNotEmpty == true &&
        tabData.video!.videoPath != videoData.videoPath) {
      FileUtils.deleteFile(tabData.video!.videoPath);
    }

    _updateTabData(tabData.copyWith(video: videoData), isAnswer);
  }

  // Удалить видео
  void removeVideo({bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);

    // Удаляем файл видео, если он существует
    if (tabData.video?.videoPath.isNotEmpty == true) {
      FileUtils.deleteFile(tabData.video!.videoPath);
    }

    _updateTabData(tabData.removeVideo(), isAnswer);
  }

  // Добавить/обновить аудио
  void setAudio(AudioPlayerData audioData, {bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);

    // Удаляем старый файл аудио, если он существует и отличается от нового
    if (tabData.audio?.audioPath.isNotEmpty == true &&
        tabData.audio!.audioPath != audioData.audioPath) {
      FileUtils.deleteFile(tabData.audio!.audioPath);
    }

    _updateTabData(tabData.copyWith(audio: audioData), isAnswer);
  }

  // Удалить аудио
  void removeAudio({bool isAnswer = false}) {
    final tabData = _getTabData(isAnswer);

    // Удаляем файл аудио, если он существует
    if (tabData.audio?.audioPath.isNotEmpty == true) {
      FileUtils.deleteFile(tabData.audio!.audioPath);
    }

    _updateTabData(tabData.removeAudio(), isAnswer);
  }

  // Вспомогательные методы
  QuestionTabData _getTabData(bool isAnswer) {
    return isAnswer ? state.answer : state.question;
  }

  void _updateTabData(QuestionTabData tabData, bool isAnswer) {
    final newQuestionData =
        isAnswer
            ? state.copyWith(answer: tabData)
            : state.copyWith(question: tabData);

    emit(newQuestionData);
  }
}
