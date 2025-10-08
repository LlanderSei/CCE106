import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import '../models/student.dart';

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final StudentController _controller = StudentController();
  final _formKey = GlobalKey<FormState>();
  String _studentName = '';
  String _courseTitle = '';
  Student? _editingStudent;

  void _showStudentDialog({Student? student}) {
    _editingStudent = student;
    _studentName = student?.studentName ?? '';
    _courseTitle = student?.courseTitle ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _studentName,
                decoration: InputDecoration(labelText: 'Student Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
                onSaved: (value) => _studentName = value!,
              ),
              TextFormField(
                initialValue: _courseTitle,
                decoration: InputDecoration(labelText: 'Course Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course title';
                  }
                  return null;
                },
                onSaved: (value) => _courseTitle = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(onPressed: _saveStudent, child: Text('Save')),
        ],
      ),
    );
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final student = Student(
        id: _editingStudent?.id ?? '',
        studentName: _studentName,
        courseTitle: _courseTitle,
      );
      if (_editingStudent == null) {
        _controller.addStudent(student);
      } else {
        _controller.updateStudent(student);
      }
      Navigator.of(context).pop();
    }
  }

  void _deleteStudent(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deleteStudent(id);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAllStudents() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete All Students'),
        content: Text('Are you sure you want to delete all students?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deleteAllStudents();
              Navigator.of(context).pop();
            },
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    print('Logout clicked.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students Records'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: StreamBuilder<List<Student>>(
        stream: _controller.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return Center(
              child: Text('No available records. Try adding some.'),
            );
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                student.studentName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(student.courseTitle),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 7,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _showStudentDialog(student: student),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteStudent(student.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showStudentDialog(),
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'delete_all',
            onPressed: _deleteAllStudents,
            child: Icon(Icons.delete_forever),
          ),
        ],
      ),
    );
  }
}
