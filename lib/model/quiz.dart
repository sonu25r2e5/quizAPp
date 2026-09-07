// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/model/question.dart';

class Quiz {
  final String id;
  final String title;
  final String category;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updateAt;

  Quiz({
    required this.id,
    required this.title,
    required this.category,
    required this.timeLimit,
    required this.questions,
    this.createdAt,
    this.updateAt,
  });

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory Quiz.fromMap(Map<String, dynamic> map, [String? documentId]) {
    final rawCreatedAt = map['createdAt'];
    final rawUpdatedAt = map['updateAt'];

    return Quiz(
      id: documentId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? map['categoryId'] ?? '',
      timeLimit: map['timeLimit'] ?? map['timeLimti'] ?? 0,
      questions: ((map['questions'] ?? []) as List)
          .map((e) => Question.fromMap(e))
          .toList(),
      createdAt: _parseDate(rawCreatedAt),
      updateAt: _parseDate(rawUpdatedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'categoryId': category,
      'timeLimit': timeLimit,
      'questions': questions.map((x) => x.toMap()).toList(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updateAt': updateAt != null
          ? Timestamp.fromDate(updateAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Quiz copyWith({
    String? id,
    String? title,
    String? category,
    int? timeLimit,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? updateAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }
}
