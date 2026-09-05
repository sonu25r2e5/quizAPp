// ignore_for_file: public_member_api_docs, sort_constructors_first

class Category {
  final String id;
  final String name;
  final String description;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
  });

  // String id is converted we use here.
  // converting the general JSON Map to User Object.
  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
      id: id,
      name: map['name'] ?? "",
      description: map["description"] ?? "",
      createdAt: map["createdAt"]?.toDate(),
    );
  }

  // convert user Object to json map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  // copy with helps to keep the copying of styling by thdifferen name
  Category copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}

// use serialization  package from the pub.dev  json_serializable package
