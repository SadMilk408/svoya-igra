// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'question_data/question_data.dart';

enum StructureType { rounds, themes }

class GameStructure {
  final PackEntity pack;
  final List<RoundEntity> rounds;
  final List<ThemeEntity> themes;
  final List<QuestionEntity> questions;

  GameStructure({
    required this.pack,
    required this.rounds,
    required this.themes,
    required this.questions,
  });

  GameStructure copyWith({
    PackEntity? pack,
    List<RoundEntity>? rounds,
    List<ThemeEntity>? themes,
    List<QuestionEntity>? questions,
  }) {
    return GameStructure(
      pack: pack ?? this.pack,
      rounds: rounds ?? this.rounds,
      themes: themes ?? this.themes,
      questions: questions ?? this.questions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pack': pack.toMap(),
      'rounds': rounds.map((x) => x.toMap()).toList(),
      'themes': themes.map((x) => x.toMap()).toList(),
      'questions': questions.map((x) => x.toMap()).toList(),
    };
  }

  factory GameStructure.fromMap(Map<String, dynamic> map) {
    return GameStructure(
      pack:
          BlocEntity.fromMap(map['pack'] as Map<String, dynamic>) as PackEntity,
      rounds: List<RoundEntity>.from(
        (map['rounds'] as List<dynamic>).map<RoundEntity>(
          (x) =>
              BlocEntity.fromMap(Map<String, dynamic>.from(x)) as RoundEntity,
        ),
      ),
      themes: List<ThemeEntity>.from(
        (map['themes'] as List<dynamic>).map<ThemeEntity>(
          (x) =>
              BlocEntity.fromMap(Map<String, dynamic>.from(x)) as ThemeEntity,
        ),
      ),
      questions: List<QuestionEntity>.from(
        (map['questions'] as List<dynamic>).map<QuestionEntity>(
          (x) =>
              BlocEntity.fromMap(Map<String, dynamic>.from(x))
                  as QuestionEntity,
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory GameStructure.fromJson(String source) =>
      GameStructure.fromMap(json.decode(source) as Map<String, dynamic>);
}

class BlocEntity {
  BlocEntity({
    required this.id,
    required this.blockName,
    required this.parentName,
  });

  final String id;
  final String blockName;
  final String parentName;

  BlocEntity copyWith({String? id, String? blockName, String? parentName}) {
    return BlocEntity(
      id: id ?? this.id,
      blockName: blockName ?? this.blockName,
      parentName: parentName ?? this.parentName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'blockName': blockName,
      'parentName': parentName,
    };
  }

  factory BlocEntity.fromMap(Map<String, dynamic> map) {
    // Проверяем, есть ли поле cost, чтобы определить тип сущности
    if (map.containsKey('cost')) {
      return QuestionEntity.fromMap(map);
    }
    return BlocEntity(
      id: map['id'] as String? ?? _generateId(),
      blockName: map['blockName'] as String,
      parentName: map['parentName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BlocEntity.fromJson(String source) =>
      BlocEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant BlocEntity other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Генератор уникальных ID
String _generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString() +
      (1000 + (DateTime.now().microsecond % 9000)).toString();
}

class PackEntity extends BlocEntity {
  PackEntity({
    required super.id,
    required super.blockName,
    required super.parentName,
  });
}

class RoundEntity extends BlocEntity {
  RoundEntity({
    required super.id,
    required super.blockName,
    required super.parentName,
  });

  @override
  RoundEntity copyWith({String? id, String? blockName, String? parentName}) {
    return RoundEntity(
      id: id ?? this.id,
      blockName: blockName ?? this.blockName,
      parentName: parentName ?? this.parentName,
    );
  }
}

class ThemeEntity extends BlocEntity {
  ThemeEntity({
    required super.id,
    required super.blockName,
    required super.parentName,
  });

  @override
  ThemeEntity copyWith({String? id, String? blockName, String? parentName}) {
    return ThemeEntity(
      id: id ?? this.id,
      blockName: blockName ?? this.blockName,
      parentName: parentName ?? this.parentName,
    );
  }
}

class QuestionEntity extends BlocEntity with EquatableMixin {
  QuestionEntity({
    required super.id,
    required super.blockName,
    required super.parentName,
    required this.cost,
    this.questionData,
  });

  final int cost;
  final QuestionData? questionData;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'cost': cost,
      'questionData': questionData?.toMap(),
    };
  }

  factory QuestionEntity.fromMap(Map<String, dynamic> map) {
    return QuestionEntity(
      id: map['id'] as String? ?? _generateId(),
      blockName: map['blockName'] as String,
      parentName: map['parentName'] as String,
      cost: map['cost'] as int,
      questionData:
          map['questionData'] != null
              ? QuestionData.fromMap(
                Map<String, dynamic>.from(map['questionData']),
              )
              : null,
    );
  }

  QuestionEntity copyWithQuestion({
    String? id,
    String? parentName,
    String? blockName,
    int? cost,
    QuestionData? questionData,
  }) {
    return QuestionEntity(
      id: id ?? this.id,
      parentName: parentName ?? super.parentName,
      blockName: blockName ?? super.blockName,
      cost: cost ?? this.cost,
      questionData: questionData ?? this.questionData,
    );
  }

  @override
  List<Object?> get props => [id, blockName, parentName, cost, questionData];
}
