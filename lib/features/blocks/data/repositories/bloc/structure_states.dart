part of 'structure_bloc.dart';

abstract class GameStructureState extends Equatable {
  final GameStructure gameStructure;

  const GameStructureState({required this.gameStructure});

  List<BlocEntity> getChilds(BlocEntity? tempParent);

  @override
  List<Object> get props => [gameStructure];
}

class GameStructureInitial extends GameStructureState {
  const GameStructureInitial({required super.gameStructure});

  @override
  List<BlocEntity> getChilds(BlocEntity? tempParent) {
    if (tempParent is PackEntity) {
      final list =
          gameStructure.rounds
              .where((e) => e.parentName == tempParent.blockName)
              .toList();
      return list;
    }
    if (tempParent is RoundEntity) {
      final list =
          gameStructure.themes
              .where((e) => e.parentName == tempParent.blockName)
              .toList();
      return list;
    }
    if (tempParent is ThemeEntity) {
      return gameStructure.questions
          .where((e) => e.themeId == tempParent.id)
          .toList();
    }
    return [];
  }
}

BlocEntity? getNextParent(BlocEntity? tempParent, BlocEntity tempChild) {
  if (tempParent is PackEntity) {
    return RoundEntity(
      id: tempChild.id,
      blockName: tempChild.blockName,
      parentName: tempParent.blockName,
    );
  }
  if (tempParent is RoundEntity) {
    return ThemeEntity(
      id: tempChild.id,
      blockName: tempChild.blockName,
      parentName: tempParent.blockName,
    );
  }
  return null;
}

String _generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString() +
      (1000 + (DateTime.now().microsecond % 9000)).toString();
}

String getChildsTitle(BlocEntity? tempParent) {
  if (tempParent is PackEntity) {
    return 'Раунды';
  }
  if (tempParent is RoundEntity) {
    return 'Темы';
  }
  if (tempParent is ThemeEntity) {
    return 'Вопросы';
  }
  return '';
}

class GameStructureError extends GameStructureState {
  final String errorMessage;

  const GameStructureError({
    required super.gameStructure,
    required this.errorMessage,
  });

  @override
  List<BlocEntity> getChilds(BlocEntity? tempParent) {
    if (tempParent is PackEntity) {
      final list =
          gameStructure.rounds
              .where((e) => e.parentName == tempParent.blockName)
              .toList();
      return list;
    }
    if (tempParent is RoundEntity) {
      final list =
          gameStructure.themes
              .where((e) => e.parentName == tempParent.blockName)
              .toList();
      return list;
    }
    if (tempParent is ThemeEntity) {
      return gameStructure.questions
          .where((e) => e.themeId == tempParent.id)
          .toList();
    }
    return [];
  }

  @override
  List<Object> get props => [gameStructure, errorMessage];
}
