import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../entities/player_entity.dart';

// Events
abstract class PlayersEvent extends Equatable {
  const PlayersEvent();

  @override
  List<Object?> get props => [];
}

class AddPlayer extends PlayersEvent {
  final String name;

  const AddPlayer(this.name);

  @override
  List<Object?> get props => [name];
}

class RemovePlayer extends PlayersEvent {
  final String playerId;

  const RemovePlayer(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class UpdatePlayerName extends PlayersEvent {
  final String playerId;
  final String newName;

  const UpdatePlayerName(this.playerId, this.newName);

  @override
  List<Object?> get props => [playerId, newName];
}

class UpdatePlayerScore extends PlayersEvent {
  final String playerId;
  final int newScore;

  const UpdatePlayerScore(this.playerId, this.newScore);

  @override
  List<Object?> get props => [playerId, newScore];
}

class AddScoreToPlayer extends PlayersEvent {
  final String playerId;
  final int pointsToAdd;

  const AddScoreToPlayer(this.playerId, this.pointsToAdd);

  @override
  List<Object?> get props => [playerId, pointsToAdd];
}

class LoadGameSession extends PlayersEvent {}

class SaveGameSession extends PlayersEvent {}

class SetCurrentRound extends PlayersEvent {
  final int roundIndex;

  const SetCurrentRound(this.roundIndex);

  @override
  List<Object?> get props => [roundIndex];
}

class ResetGame extends PlayersEvent {}

// States
abstract class PlayersState extends Equatable {
  final GameSession gameSession;

  const PlayersState(this.gameSession);

  @override
  List<Object?> get props => [gameSession];
}

class PlayersInitial extends PlayersState {
  const PlayersInitial() : super(const GameSession(players: []));
}

class PlayersLoading extends PlayersState {
  const PlayersLoading(super.gameSession);
}

class PlayersLoaded extends PlayersState {
  const PlayersLoaded(super.gameSession);
}

class PlayersError extends PlayersState {
  final String message;

  const PlayersError(super.gameSession, this.message);

  @override
  List<Object?> get props => [gameSession, message];
}

// BLOC
class PlayersBloc extends Bloc<PlayersEvent, PlayersState> {
  final SharedPreferences _prefs;
  static const String _sessionKey = 'game_session';

  PlayersBloc({required SharedPreferences prefs})
    : _prefs = prefs,
      super(const PlayersInitial()) {
    on<AddPlayer>(_onAddPlayer);
    on<RemovePlayer>(_onRemovePlayer);
    on<UpdatePlayerName>(_onUpdatePlayerName);
    on<UpdatePlayerScore>(_onUpdatePlayerScore);
    on<AddScoreToPlayer>(_onAddScoreToPlayer);
    on<LoadGameSession>(_onLoadGameSession);
    on<SaveGameSession>(_onSaveGameSession);
    on<SetCurrentRound>(_onSetCurrentRound);
    on<ResetGame>(_onResetGame);
  }

  void _onAddPlayer(AddPlayer event, Emitter<PlayersState> emit) {
    final newPlayer = PlayerEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      score: 0,
    );

    final updatedPlayers = [...state.gameSession.players, newPlayer];
    final updatedSession = state.gameSession.copyWith(players: updatedPlayers);

    emit(PlayersLoaded(updatedSession));
    add(SaveGameSession());
  }

  void _onRemovePlayer(RemovePlayer event, Emitter<PlayersState> emit) {
    final updatedPlayers =
        state.gameSession.players
            .where((player) => player.id != event.playerId)
            .toList();

    final updatedSession = state.gameSession.copyWith(players: updatedPlayers);
    emit(PlayersLoaded(updatedSession));
    add(SaveGameSession());
  }

  void _onUpdatePlayerName(UpdatePlayerName event, Emitter<PlayersState> emit) {
    final updatedPlayers =
        state.gameSession.players.map((player) {
          if (player.id == event.playerId) {
            return player.copyWith(name: event.newName);
          }
          return player;
        }).toList();

    final updatedSession = state.gameSession.copyWith(players: updatedPlayers);
    emit(PlayersLoaded(updatedSession));
    add(SaveGameSession());
  }

  void _onUpdatePlayerScore(
    UpdatePlayerScore event,
    Emitter<PlayersState> emit,
  ) {
    final updatedPlayers =
        state.gameSession.players.map((player) {
          if (player.id == event.playerId) {
            return player.copyWith(score: event.newScore);
          }
          return player;
        }).toList();

    final updatedSession = state.gameSession.copyWith(players: updatedPlayers);
    emit(PlayersLoaded(updatedSession));
    add(SaveGameSession());
  }

  void _onAddScoreToPlayer(AddScoreToPlayer event, Emitter<PlayersState> emit) {
    final updatedPlayers =
        state.gameSession.players.map((player) {
          if (player.id == event.playerId) {
            return player.copyWith(score: player.score + event.pointsToAdd);
          }
          return player;
        }).toList();

    final updatedSession = state.gameSession.copyWith(players: updatedPlayers);
    emit(PlayersLoaded(updatedSession));
    add(SaveGameSession());
  }

  void _onLoadGameSession(LoadGameSession event, Emitter<PlayersState> emit) {
    try {
      final sessionJson = _prefs.getString(_sessionKey);
      if (sessionJson != null) {
        final sessionMap = json.decode(sessionJson) as Map<String, dynamic>;
        final session = GameSession.fromMap(sessionMap);
        emit(PlayersLoaded(session));
      } else {
        emit(PlayersLoaded(GameSession(players: [])));
      }
    } catch (e) {
      emit(PlayersError(state.gameSession, 'Ошибка загрузки сессии: $e'));
    }
  }

  void _onSaveGameSession(SaveGameSession event, Emitter<PlayersState> emit) {
    try {
      final sessionJson = json.encode(state.gameSession.toMap());
      _prefs.setString(_sessionKey, sessionJson);
    } catch (e) {
      emit(PlayersError(state.gameSession, 'Ошибка сохранения сессии: $e'));
    }
  }

  void _onSetCurrentRound(SetCurrentRound event, Emitter<PlayersState> emit) {
    final updatedSession = state.gameSession.copyWith(
      currentRoundIndex: event.roundIndex,
    );
    emit(PlayersLoaded(updatedSession));
    add(SaveGameSession());
  }

  void _onResetGame(ResetGame event, Emitter<PlayersState> emit) {
    // Сбрасываем игру к начальному состоянию
    final resetSession = GameSession(
      players:
          state.gameSession.players
              .map((player) => player.copyWith(score: 0))
              .toList(),
      currentRoundIndex: 0,
    );
    emit(PlayersLoaded(resetSession));
    add(SaveGameSession());
  }
}
