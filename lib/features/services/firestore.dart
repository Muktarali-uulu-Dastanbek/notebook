import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notebook/features/models/note_model.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection("notes").withConverter<Note>(
            fromFirestore: (snapshots, _) => Note.fromJson(snapshots.data()!),
            toFirestore: (note, _) => note.toJson(),
          );

  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy("createdAt", descending: true).snapshots();
  }

  Future<void>? addNote(Note note) {
    notes.add(note);
  }

  void updateNote(String noteId, Note note) {
    notes.doc(noteId).update(note.toJson());
  }
  // Future<void> addNote(Note note) {
  //   return notes.add({
  //     "name": note.name,
  //     "description": note.description,
  //     "image": note.image,
  //     "createdAt": note.createdAt,
  //   });
  // }
}
