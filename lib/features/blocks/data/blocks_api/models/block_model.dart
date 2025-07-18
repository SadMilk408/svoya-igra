import 'dart:convert';

import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';

enum BlockType { packs, rounds, themes, questions }

class BlockModel {
  final String id;
  final String name;
  final String parentName;
  final BlockType? blockType;

  BlockModel({
    required this.id,
    required this.name,
    required this.parentName,
    required this.blockType,
  });

  BlocEntity? toEntity() {
    switch (blockType) {
      case BlockType.packs:
        return PackEntity(id: id, blockName: name, parentName: parentName);
      case BlockType.rounds:
        return RoundEntity(id: id, blockName: name, parentName: parentName);
      case BlockType.themes:
        return ThemeEntity(id: id, blockName: name, parentName: parentName);
      default:
        return null;
    }
  }

  factory BlockModel.fromEntity(BlocEntity blocEntity) {
    BlockType? type;

    if (blocEntity is RoundEntity) {
      type = BlockType.rounds;
    }
    if (blocEntity is ThemeEntity) {
      type = BlockType.themes;
    }
    if (blocEntity is QuestionEntity) {
      type = BlockType.questions;
    }

    return BlockModel(
      id: blocEntity.id,
      name: blocEntity.blockName,
      parentName: blocEntity.parentName,
      blockType: type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'parentName': parentName,
      'type': blockType?.name,
    };
  }

  factory BlockModel.fromMap(Map<String, dynamic> map) {
    return BlockModel(
      id: map['id'] as String? ?? '',
      name: map['name'],
      parentName: map['parentName'],
      blockType: BlockType.values.byName(map['type']),
    );
  }

  String toJson() => json.encode(toMap());

  factory BlockModel.fromJson(String source) =>
      BlockModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
