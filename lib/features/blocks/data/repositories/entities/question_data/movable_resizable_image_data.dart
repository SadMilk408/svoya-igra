import 'package:flutter/material.dart';
import 'dart:convert';

class MovableResizableImageData {
  final String id;
  final String imagePath;
  final double size;
  final Offset position;

  MovableResizableImageData({
    String? id,
    required this.imagePath,
    required this.size,
    required this.position,
  }) : id = id ?? UniqueKey().toString();

  MovableResizableImageData copyWith({
    String? id,
    String? imagePath,
    double? size,
    Offset? position,
  }) {
    return MovableResizableImageData(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      size: size ?? this.size,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'imagePath': imagePath,
    'size': size,
    'position': {'dx': position.dx, 'dy': position.dy},
  };

  factory MovableResizableImageData.fromMap(Map<String, dynamic> map) =>
      MovableResizableImageData(
        id: map['id'] as String?,
        imagePath: map['imagePath'] as String,
        size: map['size'] as double,
        position: Offset(
          (map['position']['dx'] as num).toDouble(),
          (map['position']['dy'] as num).toDouble(),
        ),
      );

  String toJson() => json.encode(toMap());
  factory MovableResizableImageData.fromJson(String source) =>
      MovableResizableImageData.fromMap(
        Map<String, dynamic>.from(json.decode(source)),
      );
}
