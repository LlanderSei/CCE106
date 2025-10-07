import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentController {
  final CollectionReference _studentsCollection = FirebaseFirestore.instance
      .collection('students');

  Stream<List<Student>> getStudents() {
    return _studentsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addStudent(Student student) async {
    await _studentsCollection.add(student.toMap());
  }

  Future<void> updateStudent(Student student) async {
    await _studentsCollection.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _studentsCollection.doc(id).delete();
  }

  Future<void> deleteAllStudents() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await _studentsCollection.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
