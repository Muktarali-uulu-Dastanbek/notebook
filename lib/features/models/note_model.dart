// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? name;
  final String? description;
  final String? image;
  final Timestamp createdAt;

  Note({
    required this.name,
    this.description,
    required this.image,
    required this.createdAt,
  });
}
