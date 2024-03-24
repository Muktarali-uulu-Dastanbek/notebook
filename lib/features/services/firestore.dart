import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notebook/features/models/note_model.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection("notes");

  Future<void> addNote(Note note) {
    return notes.add({
      "name": note.name,
      "description": note.description,
      "image": note.image,
      "createdAt": note.createdAt,
    });
  }
}
