part of 'structure_bloc.dart';

abstract class GameStructureEvent extends Equatable {
  const GameStructureEvent();
}

class OnInit extends GameStructureEvent {
  const OnInit();

  @override
  List<Object> get props => [];
}

class RoundAdded extends GameStructureEvent {
  final RoundEntity round;

  const RoundAdded(this.round);

  @override
  List<Object> get props => [round];
}

class ThemeAdded extends GameStructureEvent {
  final ThemeEntity theme;

  const ThemeAdded(this.theme);

  @override
  List<Object> get props => [theme];
}

class QuestionAdded extends GameStructureEvent {
  final QuestionEntity question;

  const QuestionAdded(this.question);

  @override
  List<Object> get props => [question];
}

class RoundEdit extends GameStructureEvent {
  final RoundEntity round;
  final BlocEntity? tempChild;

  const RoundEdit(this.round, this.tempChild);

  @override
  List<Object> get props => [round];
}

class ThemeEdit extends GameStructureEvent {
  final ThemeEntity theme;
  final BlocEntity? tempChild;

  const ThemeEdit(this.theme, this.tempChild);

  @override
  List<Object> get props => [theme];
}

class QuestionEdit extends GameStructureEvent {
  final QuestionEntity question;
  final BlocEntity? tempChild;

  const QuestionEdit(this.question, this.tempChild);

  @override
  List<Object> get props => [question];
}

class RoundRemoved extends GameStructureEvent {
  final BlocEntity round;

  const RoundRemoved(this.round);

  @override
  List<Object> get props => [round];
}

class ThemeRemoved extends GameStructureEvent {
  final BlocEntity theme;

  const ThemeRemoved(this.theme);

  @override
  List<Object> get props => [theme];
}

class QuestionRemoved extends GameStructureEvent {
  final BlocEntity question;

  const QuestionRemoved(this.question);

  @override
  List<Object> get props => [question];
}

class ShowError extends GameStructureEvent {
  final String message;

  const ShowError(this.message);

  @override
  List<Object> get props => [message];
}
