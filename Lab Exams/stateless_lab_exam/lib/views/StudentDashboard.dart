import 'package:flutter/material.dart';
import 'package:stateless_lab_exam/data/StudentInfo.dart';
import 'package:stateless_lab_exam/data/Subjects.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final studentInfo = StudentInfo().studentInfo;
    final subjects = Subjects().subjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              print('Logout clicked');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(studentInfo.image!),
                  child: studentInfo.image!.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                  onBackgroundImageError: (error, stackTrace) {
                    debugPrint('Image load error: $error');
                  },
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${studentInfo.firstName} ${studentInfo.middleInitial}. ${studentInfo.lastName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${studentInfo.studentID}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${studentInfo.course} - ${studentInfo.standingYear} Year',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contact Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(studentInfo.email!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(studentInfo.phoneNum!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(studentInfo.homeAddress!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Subjects Title
            const Text(
              'Subjects',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Subject Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(subject.subjectTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Instructor: ${subject.instructor}'),
                        Text('Days: ${subject.days.join(', ')}'),
                        Text('Time: ${subject.timeStart} - ${subject.timeEnd}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Add Subject Clicked!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
