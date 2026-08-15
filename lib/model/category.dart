// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String description;
  final DateTime? createdAT;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.createdAT,
  });

  // converting the general JSON Map to User Object.
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'] ?? "",
      description: map["description"] ?? "",
      createdAT: map["createdAt"]?.toDate(),
    );
  }

  // convert user Object to json map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'createdAT': createdAT ?? DateTime.now(),
    };
  }

  // copy with helps to keep the copying of styling by thdifferen name
  Category copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAT,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAT: createdAT,
    );
  }
}

// use serialization  package from the pub.dev  json_serializable package
