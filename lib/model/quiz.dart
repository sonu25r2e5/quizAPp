// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_application_1/model/question.dart';

class Quiz {
  final String id;
  final String title;
  final String category;
  final int timeLimti;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updateAt;
  // created a constructor using the propertises.
  Quiz({
    required this.id,
    required this.title,
    required this.category,
    required this.timeLimti,
    required this.questions,
    this.createdAt,
    this.updateAt,
  });

  // ?? this is non-collapsing operator.
  // convert json to string
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      title: map['title'] ?? "",
      category: map['category'] ?? "",
      timeLimti: map['timeLimti'] ?? 0,
      questions: ((map['questions'] ?? []) as List)
          .map((e) => Question.fromMap(e))
          .toList(),
      createdAt: map['createdAt']?.toDate(),
      updateAt: map['updateAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updateAt'] as int)
          : null,
    );
  }

  // converting object o json
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'timeLimti': timeLimti,
      'question': questions.map((x) => x.toMap()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updateAt': DateTime.now(),
    };
  }

  // copywith is done by extension property.
  Quiz copyWith({
    String? id,
    String? title,
    String? category,
    int? timeLimti,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? updateAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      timeLimti: timeLimti ?? this.timeLimti,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }
}
