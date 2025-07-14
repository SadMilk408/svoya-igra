import 'dart:convert';
import 'package:flutter/material.dart';

class AudioPlayerData {
  String audioPath;
  Duration startPosition;
  Duration endPosition;
  Offset position;

  AudioPlayerData({
    required this.audioPath,
    required this.startPosition,
    required this.endPosition,
    required this.position,
  });

  AudioPlayerData copyWith({
    String? audioPath,
    Duration? startPosition,
    Duration? endPosition,
    double? volume,
    Offset? position,
  }) {
    return AudioPlayerData(
      audioPath: audioPath ?? this.audioPath,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() => {
    'audioPath': audioPath,
    'startPosition': startPosition.inMilliseconds,
    'endPosition': endPosition.inMilliseconds,
    'position': {'dx': position.dx, 'dy': position.dy},
  };

  factory AudioPlayerData.fromMap(Map<String, dynamic> map) => AudioPlayerData(
    audioPath: map['audioPath'] as String,
    startPosition: Duration(milliseconds: map['startPosition'] as int),
    endPosition: Duration(milliseconds: map['endPosition'] as int),
    position: Offset(
      (map['position']['dx'] as num).toDouble(),
      (map['position']['dy'] as num).toDouble(),
    ),
  );

  String toJson() => toMap().toString();
  factory AudioPlayerData.fromJson(String source) =>
      AudioPlayerData.fromMap(Map<String, dynamic>.from(json.decode(source)));
}
