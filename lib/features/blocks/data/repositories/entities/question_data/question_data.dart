import 'movable_resizable_text_data.dart';
import 'movable_resizable_image_data.dart';
import 'movable_resizable_video_data.dart';
import 'audio_player_data.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';

class QuestionTabData extends Equatable {
  final List<MovableResizableTextData> textItems;
  final MovableResizableImageData? image;
  final MovableResizableVideoData? video;
  final AudioPlayerData? audio;

  QuestionTabData({
    List<MovableResizableTextData>? textItems,
    this.image,
    this.video,
    this.audio,
  }) : textItems = textItems ?? [];

  QuestionTabData copyWith({
    List<MovableResizableTextData>? textItems,
    MovableResizableImageData? image,
    MovableResizableVideoData? video,
    AudioPlayerData? audio,
  }) {
    return QuestionTabData(
      textItems: textItems ?? this.textItems,
      image: image ?? this.image,
      video: video ?? this.video,
      audio: audio ?? this.audio,
    );
  }

  Map<String, dynamic> toMap() => {
    'textItems': textItems.map((e) => e.toMap()).toList(),
    'image': image?.toMap(),
    'video': video?.toMap(),
    'audio': audio?.toMap(),
  };

  factory QuestionTabData.fromMap(Map<String, dynamic> map) => QuestionTabData(
    textItems:
        (map['textItems'] as List<dynamic>?)
            ?.map(
              (e) => MovableResizableTextData.fromMap(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList() ??
        [],
    image:
        map['image'] != null
            ? MovableResizableImageData.fromMap(
              Map<String, dynamic>.from(map['image']),
            )
            : null,
    video:
        map['video'] != null
            ? MovableResizableVideoData.fromMap(
              Map<String, dynamic>.from(map['video']),
            )
            : null,
    audio:
        map['audio'] != null
            ? AudioPlayerData.fromMap(Map<String, dynamic>.from(map['audio']))
            : null,
  );

  String toJson() => json.encode(toMap());
  factory QuestionTabData.fromJson(String source) =>
      QuestionTabData.fromMap(Map<String, dynamic>.from(json.decode(source)));

  // Методы для удаления элементов
  QuestionTabData removeImage() {
    return QuestionTabData(textItems: textItems, video: video, audio: audio);
  }

  QuestionTabData removeVideo() {
    return QuestionTabData(textItems: textItems, image: image, audio: audio);
  }

  QuestionTabData removeAudio() {
    return QuestionTabData(textItems: textItems, image: image, video: video);
  }

  @override
  List<Object?> get props => [textItems, image, video, audio];
}

class QuestionData extends Equatable {
  final QuestionTabData question;
  final QuestionTabData answer;

  const QuestionData({required this.question, required this.answer});

  QuestionData copyWith({QuestionTabData? question, QuestionTabData? answer}) {
    return QuestionData(
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  Map<String, dynamic> toMap() => {
    'question': question.toMap(),
    'answer': answer.toMap(),
  };

  factory QuestionData.fromMap(Map<String, dynamic> map) => QuestionData(
    question: QuestionTabData.fromMap(
      Map<String, dynamic>.from(map['question']),
    ),
    answer: QuestionTabData.fromMap(Map<String, dynamic>.from(map['answer'])),
  );

  String toJson() => json.encode(toMap());
  factory QuestionData.fromJson(String source) =>
      QuestionData.fromMap(Map<String, dynamic>.from(json.decode(source)));

  @override
  List<Object?> get props => [question, answer];
}
