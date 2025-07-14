import 'dart:convert';

import 'package:smartest_man/features/blocks/data/blocks_api/models/block_model.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/structure_entity.dart';
import 'package:smartest_man/features/blocks/data/repositories/entities/question_data/question_data.dart';

class QuestionModel extends BlockModel {
  QuestionModel({
    required super.parentName,
    super.blockType = BlockType.questions,
    required this.questionData,
    required this.price,
  }) : super(name: '$price');

  final QuestionData? questionData;
  final int price;

  @override
  QuestionEntity toEntity() {
    return QuestionEntity(
      id: _generateId(),
      blockName: name,
      parentName: parentName,
      cost: price,
      questionData: questionData,
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (DateTime.now().microsecond % 9000)).toString();
  }

  factory QuestionModel.fromEntity(QuestionEntity questionEntity) {
    return QuestionModel(
      parentName: questionEntity.parentName,
      questionData: questionEntity.questionData,
      price: questionEntity.cost,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'parentName': parentName,
      'questionData': questionData?.toMap(),
      'price': price,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      parentName: map['parentName'] as String,
      questionData:
          map['questionData'] != null
              ? QuestionData.fromMap(
                Map<String, dynamic>.from(map['questionData']),
              )
              : null,
      price: map['price'] as int,
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory QuestionModel.fromJson(String source) =>
      QuestionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
