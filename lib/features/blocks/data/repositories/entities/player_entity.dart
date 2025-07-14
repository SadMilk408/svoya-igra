import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  final String id;
  final String name;
  final int score;

  const PlayerEntity({required this.id, required this.name, this.score = 0});

  PlayerEntity copyWith({String? id, String? name, int? score}) {
    return PlayerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'score': score};
  }

  factory PlayerEntity.fromMap(Map<String, dynamic> map) {
    return PlayerEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      score: map['score'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, score];
}

class GameSession {
  final List<PlayerEntity> players;
  final int currentRoundIndex;

  const GameSession({required this.players, this.currentRoundIndex = 0});

  GameSession copyWith({List<PlayerEntity>? players, int? currentRoundIndex}) {
    return GameSession(
      players: players ?? this.players,
      currentRoundIndex: currentRoundIndex ?? this.currentRoundIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'players': players.map((p) => p.toMap()).toList(),
      'currentRoundIndex': currentRoundIndex,
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      players:
          (map['players'] as List)
              .map((p) => PlayerEntity.fromMap(p as Map<String, dynamic>))
              .toList(),
      currentRoundIndex: map['currentRoundIndex'] as int? ?? 0,
    );
  }
}
