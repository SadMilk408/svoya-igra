import 'dart:convert';

import 'package:smartest_man/features/blocks/data/blocks_api/models/block_model.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/question_data.dart';

class QuestionModel extends BlockModel {
  QuestionModel({
    required super.id,
    required super.name,
    required super.parentName,
    BlockType super.blockType = BlockType.questions,
    required this.questionData,
    required this.price,
    required this.themeId,
  });

  final QuestionData? questionData;
  final int price;
  final String themeId;

  @override
  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      blockName: name,
      parentName: parentName,
      cost: price,
      themeId: themeId,
      questionData: questionData,
    );
  }

  factory QuestionModel.fromEntity(QuestionEntity questionEntity) {
    return QuestionModel(
      id: questionEntity.id,
      name: questionEntity.blockName,
      parentName: questionEntity.parentName,
      blockType: BlockType.questions,
      questionData: questionEntity.questionData,
      price: questionEntity.cost,
      themeId: questionEntity.themeId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'parentName': parentName,
      'type': blockType?.name,
      'questionData': questionData?.toMap(),
      'price': price,
      'themeId': themeId,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    final nameValue = map['name'];
    final String name =
        (nameValue is String && nameValue.isNotEmpty) ? nameValue : '';
    return QuestionModel(
      id: map['id'] as String? ?? '',
      name: name,
      parentName: map['parentName'] as String,
      blockType:
          map['type'] != null
              ? BlockType.values.byName(map['type'])
              : BlockType.questions,
      questionData:
          map['questionData'] != null
              ? QuestionData.fromMap(
                Map<String, dynamic>.from(map['questionData']),
              )
              : null,
      price: map['price'] as int,
      themeId: map['themeId'] as String? ?? '',
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory QuestionModel.fromJson(String source) =>
      QuestionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
