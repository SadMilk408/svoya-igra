import 'package:flutter/material.dart';
import 'dart:convert';

class MovableResizableVideoData {
  final String id;
  String videoPath;
  double size;
  Offset position;
  Duration startPosition;
  Duration endPosition;

  MovableResizableVideoData({
    String? id,
    required this.videoPath,
    required this.size,
    required this.position,
    required this.startPosition,
    required this.endPosition,
  }) : id = id ?? UniqueKey().toString();

  MovableResizableVideoData copyWith({
    String? id,
    String? videoPath,
    double? size,
    Offset? position,
    Duration? startPosition,
    Duration? endPosition,
  }) {
    return MovableResizableVideoData(
      id: id ?? this.id,
      videoPath: videoPath ?? this.videoPath,
      size: size ?? this.size,
      position: position ?? this.position,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'videoPath': videoPath,
    'size': size,
    'position': {'dx': position.dx, 'dy': position.dy},
    'startPosition': startPosition.inMilliseconds,
    'endPosition': endPosition.inMilliseconds,
  };

  factory MovableResizableVideoData.fromMap(Map<String, dynamic> map) =>
      MovableResizableVideoData(
        videoPath: map['videoPath'] ?? '',
        size: map['size']?.toDouble() ?? 300.0,
        position: Offset(
          (map['position']?['dx'] ?? 100).toDouble(),
          (map['position']?['dy'] ?? 100).toDouble(),
        ),
        startPosition: Duration(milliseconds: map['startPosition'] ?? 0),
        endPosition: Duration(milliseconds: map['endPosition'] ?? 10000),
      );

  String toJson() => toMap().toString();
  factory MovableResizableVideoData.fromJson(String source) =>
      MovableResizableVideoData.fromMap(
        Map<String, dynamic>.from(json.decode(source)),
      );
}
