// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? name;
  final String? description;
  final String? image;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Note({
    required this.name,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  Note.fromJson(Map<String, Object?> json)
      : this(
          name: json["name"] as String,
          description: json["description"] as String,
          image: json["image"] as String,
          createdAt: json["createdAt"]! as Timestamp,
          updatedAt: json["updatedAt"]! as Timestamp,
        );

  Note copyWith({
    String? name,
    String? description,
    String? image,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Note(
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "name": name,
      "description": description,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
