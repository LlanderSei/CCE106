import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:statefulwidget_villacino/controllers/tasks.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _textController = TextEditingController();
  final TaskController _taskController = TaskController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Widget Villacino'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await _taskController.deleteCompletedTasks();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_textController.text.trim().isNotEmpty) {
                
                await _taskController.addTask(_textController.text);
                _textController.clear();
                setState(() {});
              }
            },
            child: const Text('Add Task'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _taskController.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tasks'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final taskId = task.id;
                    final taskName = task['Name'] as String;
                    final isCompleted = task['Completed'] as bool;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          activeColor: Color.fromARGB(255, 56, 165, 42),
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.black, width: 10),
                          ),
                          value: isCompleted,
                          onChanged: (value) async {
                            await _taskController.updateTaskStatus(
                              taskId,
                              value ?? false,
                            );
                            setState(() {});
                          },
                        ),
                        title: Text(
                          taskName,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _taskController.deleteTask(taskId);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _taskController.clearAllTasks();
          setState(() {});
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
