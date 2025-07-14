import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartest_man/features/blocks/data/repositories/blocks_repository.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';

part 'structure_states.dart';
part 'structure_events.dart';

class GameStructureBloc extends Bloc<GameStructureEvent, GameStructureState> {
  GameStructureBloc({required final StructureRepository repository})
    : _repository = repository,
      super(
        GameStructureInitial(
          gameStructure: GameStructure(
            pack: mainPack,
            rounds: [],
            themes: [],
            questions: [],
          ),
        ),
      ) {
    on<OnInit>(_onInit);
    on<RoundAdded>(_onRoundAdded);
    on<ThemeAdded>(_onThemeAdded);
    on<QuestionAdded>(_onQuestionAdded);

    on<RoundEdit>(_onRoundEdit);
    on<ThemeEdit>(_onThemeEdit);
    on<QuestionEdit>(_onQuestionEdit);

    on<RoundRemoved>(_onRoundRemoved);
    on<ThemeRemoved>(_onThemeRemoved);
    on<QuestionRemoved>(_onQuestionRemoved);
    on<ShowError>(_onShowError);
  }

  final StructureRepository _repository;

  void _onInit(OnInit event, Emitter<GameStructureState> emit) {
    final structureFromCache = _repository.getStructure();

    log('cached ${structureFromCache.toJson()}');

    emit(GameStructureInitial(gameStructure: structureFromCache));
  }

  void _onRoundAdded(RoundAdded event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;

    // Проверяем уникальность названия раунда
    final existingRound = current.rounds.any(
      (r) => r.blockName == event.round.blockName && r.id != event.round.id,
    );

    if (existingRound) {
      add(
        ShowError(
          'Раунд с названием "${event.round.blockName}" уже существует',
        ),
      );
      return;
    }

    final updatedRounds = [...current.rounds, event.round];

    _repository.saveRounds(updatedRounds);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(rounds: updatedRounds),
      ),
    );
  }

  void _onThemeAdded(ThemeAdded event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;

    // Проверяем уникальность названия темы в рамках одного раунда
    final existingTheme = current.themes.any(
      (t) =>
          t.blockName == event.theme.blockName &&
          t.parentName == event.theme.parentName &&
          t.id != event.theme.id,
    );

    if (existingTheme) {
      add(
        ShowError(
          'Тема с названием "${event.theme.blockName}" уже существует в этом раунде',
        ),
      );
      return;
    }

    final updatedThemes = [...current.themes, event.theme];

    _repository.saveThemes(updatedThemes);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(themes: updatedThemes),
      ),
    );
  }

  void _onQuestionAdded(QuestionAdded event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;

    // Проверяем уникальность стоимости вопроса в рамках одной темы
    final existingQuestion = current.questions.any(
      (q) =>
          q.cost == event.question.cost &&
          q.themeId == event.question.themeId &&
          q.id != event.question.id,
    );

    if (existingQuestion) {
      log('XYI 1');
      add(
        ShowError(
          'Вопрос со стоимостью ${event.question.cost} уже существует в этой теме',
        ),
      );
      return;
    }

    final updatedQuestions = [...current.questions, event.question];

    _repository.saveQuestions(updatedQuestions);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(questions: updatedQuestions),
      ),
    );
  }

  void _onRoundEdit(RoundEdit event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;
    final rounds = current.rounds;

    // Проверяем уникальность названия раунда
    final existingRound = rounds.any(
      (r) => r.blockName == event.round.blockName && r.id != event.round.id,
    );

    if (existingRound) {
      add(
        ShowError(
          'Раунд с названием "${event.round.blockName}" уже существует',
        ),
      );
      return;
    }

    final themes = _repository.getThemes();

    final index = rounds.indexWhere((e) => e.id == event.tempChild?.id);

    final updatedThemes =
        themes.map((theme) {
          if (theme.parentName == rounds[index].blockName) {
            return theme.copyWith(parentName: event.round.blockName);
          }
          return theme;
        }).toList();

    rounds[index] = event.round;

    _repository.saveRounds(rounds);

    _repository.saveThemes(updatedThemes);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(rounds: rounds, themes: updatedThemes),
      ),
    );
  }

  void _onThemeEdit(ThemeEdit event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;
    final themes = current.themes;

    // Проверяем уникальность названия темы в рамках одного раунда
    final existingTheme = themes.any(
      (t) =>
          t.blockName == event.theme.blockName &&
          t.parentName == event.theme.parentName &&
          t.id != event.theme.id,
    );

    if (existingTheme) {
      add(
        ShowError(
          'Тема с названием "${event.theme.blockName}" уже существует в этом раунде',
        ),
      );
      return;
    }

    final questions = _repository.getQuestions();

    final index = themes.indexWhere((e) => e.id == event.tempChild?.id);

    final updatedQuestions =
        questions.map((question) {
          if (question.themeId == themes[index].id) {
            return question.copyWithQuestion(themeId: event.theme.id);
          }
          return question;
        }).toList();

    themes[index] = event.theme;

    _repository.saveThemes(themes);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(
          themes: themes,
          questions: updatedQuestions,
        ),
      ),
    );
  }

  void _onQuestionEdit(QuestionEdit event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;
    final questions = _repository.getQuestions();

    // Отладочная информация
    log('=== DEBUG QUESTION EDIT ===');
    log('Event question: ${event.question.toMap()}');
    log('Event tempChild: ${event.tempChild?.toMap()}');
    log('Current questions count: ${questions.length}');

    // Выводим все существующие вопросы для сравнения
    for (int i = 0; i < questions.length; i++) {
      log('Existing question $i: ${questions[i].toMap()}');
    }

    // Сначала находим индекс редактируемого вопроса
    final index = questions.indexWhere(
      (e) =>
          e.blockName == event.tempChild?.blockName &&
          e.parentName == event.tempChild?.parentName,
    );

    log('Found question index: $index');
    log(
      'Looking for blockName: ${event.tempChild?.blockName}, parentName: ${event.tempChild?.parentName}',
    );

    if (index == -1) {
      log('Question not found for editing');
      add(ShowError('Вопрос не найден для редактирования'));
      return;
    }

    // Проверяем уникальность стоимости вопроса в рамках одной темы, исключая редактируемый вопрос
    final existingQuestion = questions.asMap().entries.any((entry) {
      final i = entry.key;
      final q = entry.value;
      return i != index && // Исключаем редактируемый вопрос
          q.cost == event.question.cost &&
          q.themeId == event.question.themeId;
    });

    log('Existing question check: $existingQuestion');
    log(
      'Looking for cost: ${event.question.cost}, parentName: ${event.question.parentName}',
    );

    if (existingQuestion) {
      log('XYI 2');
      add(
        ShowError(
          'Вопрос со стоимостью ${event.question.cost} уже существует в этой теме',
        ),
      );
      return;
    }

    // Обновляем вопрос
    questions[index] = event.question;

    log('Updated questions count: ${questions.length}');
    log('Updated question at index $index: ${questions[index].toMap()}');

    _repository.saveQuestions(questions);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(questions: questions),
      ),
    );

    log('State updated successfully');
  }

  void _onRoundRemoved(RoundRemoved event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;

    // Удаляем раунд
    final updatedRounds =
        current.rounds.where((r) => r.id != event.round.id).toList();

    // Удаляем все темы, принадлежащие этому раунду
    final updatedThemes =
        current.themes
            .where((t) => t.parentName != event.round.blockName)
            .toList();

    // Удаляем все вопросы, принадлежащие удаленным темам
    final removedThemeIds =
        current.themes
            .where((t) => t.parentName == event.round.blockName)
            .map((t) => t.id)
            .toSet();
    final updatedQuestions =
        current.questions
            .where((q) => !removedThemeIds.contains(q.themeId))
            .toList();

    _repository.saveRounds(updatedRounds);
    _repository.saveThemes(updatedThemes);
    _repository.saveQuestions(updatedQuestions);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(
          rounds: updatedRounds,
          themes: updatedThemes,
          questions: updatedQuestions,
        ),
      ),
    );
  }

  void _onThemeRemoved(ThemeRemoved event, Emitter<GameStructureState> emit) {
    final current = state.gameStructure;

    // Удаляем тему
    final updatedThemes =
        current.themes.where((t) => t.id != event.theme.id).toList();

    // Удаляем все вопросы, принадлежащие этой теме
    final updatedQuestions =
        current.questions.where((q) => q.themeId != event.theme.id).toList();

    _repository.saveThemes(updatedThemes);
    _repository.saveQuestions(updatedQuestions);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(
          themes: updatedThemes,
          questions: updatedQuestions,
        ),
      ),
    );
  }

  void _onQuestionRemoved(
    QuestionRemoved event,
    Emitter<GameStructureState> emit,
  ) {
    final current = state.gameStructure;

    // Удаляем вопрос
    final updatedQuestions =
        current.questions.where((q) => q.id != event.question.id).toList();

    _repository.saveQuestions(updatedQuestions);

    emit(
      GameStructureInitial(
        gameStructure: current.copyWith(questions: updatedQuestions),
      ),
    );
  }

  void _onShowError(ShowError event, Emitter<GameStructureState> emit) {
    emit(
      GameStructureError(
        gameStructure: state.gameStructure,
        errorMessage: event.message,
      ),
    );
  }
}

GameStructureEvent? chooseAddedEvent({
  required BlocEntity? tempParent,
  required BlocEntity newChild,
}) {
  if (tempParent is PackEntity) {
    return RoundAdded(
      RoundEntity(
        id: newChild.id,
        parentName: newChild.parentName,
        blockName: newChild.blockName,
      ),
    );
  }
  if (tempParent is RoundEntity) {
    return ThemeAdded(
      ThemeEntity(
        id: newChild.id,
        parentName: newChild.parentName,
        blockName: newChild.blockName,
      ),
    );
  }
  if (tempParent is ThemeEntity) {
    if (newChild is QuestionEntity) {
      return QuestionAdded(
        QuestionEntity(
          id: newChild.id,
          parentName: newChild.parentName,
          blockName: newChild.blockName,
          cost: newChild.cost,
          themeId: (newChild).themeId,
        ),
      );
    }
  }
  return null;
}

GameStructureEvent? chooseEditEvent({
  required BlocEntity? parent,
  required BlocEntity? tempChild,
  required BlocEntity changedChild,
  required int index,
}) {
  if (parent is PackEntity) {
    return RoundEdit(
      RoundEntity(
        id: changedChild.id,
        parentName: changedChild.parentName,
        blockName: changedChild.blockName,
      ),
      tempChild,
    );
  }
  if (parent is RoundEntity) {
    return ThemeEdit(
      ThemeEntity(
        id: changedChild.id,
        parentName: changedChild.parentName,
        blockName: changedChild.blockName,
      ),
      tempChild,
    );
  }
  if (parent is ThemeEntity) {
    if (changedChild is QuestionEntity) {
      return QuestionEdit(
        QuestionEntity(
          id: changedChild.id,
          parentName: changedChild.parentName,
          blockName: changedChild.blockName,
          cost: changedChild.cost,
          themeId: (changedChild).themeId,
        ),
        tempChild,
      );
    }
  }
  return null;
}

GameStructureEvent? chooseRemoveEvent({
  required BlocEntity? tempParent,
  required BlocEntity deletedChild,
}) {
  if (tempParent is PackEntity) {
    return RoundRemoved(deletedChild);
  }
  if (tempParent is RoundEntity) {
    return ThemeRemoved(deletedChild);
  }
  if (tempParent is ThemeEntity) {
    return QuestionRemoved(deletedChild);
  }
  return null;
}
