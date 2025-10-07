import 'package:cloud_firestore/cloud_firestore.dart';

class TaskController {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('Tasks');

  // Add a new task to Firestore
  Future<void> addTask(String name) async {
    await _tasksCollection.add({
      'Name': name,
      'Completed': false,
      'CreatedAt': Timestamp.now(),
    });
  }

  // Get all tasks from Firestore
  Stream<QuerySnapshot> getTasks() {
    return _tasksCollection.orderBy('CreatedAt', descending: true).snapshots();
  }

  // Update task completion status
  Future<void> updateTaskStatus(String taskId, bool completed) async {
    await _tasksCollection.doc(taskId).update({'Completed': completed});
  }

  // Delete a single task
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // Delete all completed tasks
  Future<void> deleteCompletedTasks() async {
    final completedTasks = await _tasksCollection
        .where('Completed', isEqualTo: true)
        .get();
    for (var task in completedTasks.docs) {
      await _tasksCollection.doc(task.id).delete();
    }
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    final allTasks = await _tasksCollection.get();
    for (var task in allTasks.docs) {
      await _tasksCollection.doc(task.id).delete();
    }
  }
}
