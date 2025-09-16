import 'package:cloud_firestore/cloud_firestore.dart';

class NoteController {
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'Notes',
  );

  // Add a note to Firestore
  Future<void> addNote(String title, String desc) async {
    try {
      await notes.add({
        'Title': title,
        'Description': desc,
        'TimestampAdded': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // START MODIFIED SECTION
      throw Exception('Failed to add note: $e');
      // END MODIFIED SECTION
    }
  }

  // Update an existing note in Firestore
  Future<void> updateNote(String? id, String title, String desc) async {
    try {
      await notes.doc(id).update({
        'Title': title,
        'Description': desc,
        'TimestampUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // START MODIFIED SECTION
      throw Exception('Failed to update note: $e');
      // END MODIFIED SECTION
    }
  }

  // Delete a note from Firestore
  Future<void> deleteNote(String id) async {
    try {
      await notes.doc(id).delete();
    } catch (e) {
      // START MODIFIED SECTION
      throw Exception('Failed to delete note: $e');
      // END MODIFIED SECTION
    }
  }
}
