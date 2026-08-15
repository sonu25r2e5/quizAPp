import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Question {
  final String text;
  final List<String> options;
  final int correctOptionsIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctOptionsIndex,
  });

  // json to object
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'] ?? "No text found",
      options: List<String>.from(map['options'] ?? []),
      correctOptionsIndex: map['correctOptionsIndex'] ?? 0,
    );
  }
  // object to json
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'options': options,
      'correctOptionsIndex': correctOptionsIndex,
    };
  }

  Question copyWith({
    String? text,
    List<String>? options,
    int? correctOptionsIndex,
  }) {
    return Question(
      text: text ?? this.text,
      options: options ?? this.options,
      correctOptionsIndex: correctOptionsIndex ?? this.correctOptionsIndex,
    );
  }
}
