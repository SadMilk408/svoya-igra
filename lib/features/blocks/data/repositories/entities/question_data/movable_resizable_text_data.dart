import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:smartest_man/extensions/color_ext.dart';

class MovableResizableTextData {
  final String id;
  String text;
  double fontSize;
  Color color;
  TextAlign textAlign;
  double width;
  double height;
  Offset position;

  MovableResizableTextData({
    String? id,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.textAlign,
    required this.width,
    required this.height,
    required this.position,
  }) : id = id ?? UniqueKey().toString();

  MovableResizableTextData copyWith({
    String? id,
    String? text,
    double? fontSize,
    Color? color,
    TextAlign? textAlign,
    double? width,
    double? height,
    Offset? position,
  }) {
    return MovableResizableTextData(
      id: id ?? this.id,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      textAlign: textAlign ?? this.textAlign,
      width: width ?? this.width,
      height: height ?? this.height,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() {
    final colorHex = color.toHex(leadingHashSign: false);
    return {
      'id': id,
      'text': text,
      'fontSize': fontSize,
      'color': colorHex,
      'textAlign': textAlign.toString(),
      'width': width,
      'height': height,
      'position': {'dx': position.dx, 'dy': position.dy},
    };
  }

  factory MovableResizableTextData.fromMap(Map<String, dynamic> map) {
    final colorHex = map['color'] as String;
    final color = HexColor.fromHex(colorHex);
    return MovableResizableTextData(
      id: map['id'] as String?,
      text: map['text'] as String,
      fontSize: map['fontSize'] as double,
      color: color,
      textAlign: TextAlign.values.firstWhere(
        (e) => e.toString() == map['textAlign'],
      ),
      width: map['width'] as double,
      height: map['height'] as double,
      position: Offset(
        (map['position']['dx'] as num).toDouble(),
        (map['position']['dy'] as num).toDouble(),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory MovableResizableTextData.fromJson(String source) =>
      MovableResizableTextData.fromMap(
        Map<String, dynamic>.from(json.decode(source)),
      );
}
