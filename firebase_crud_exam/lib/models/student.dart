class Student {
  String id;
  String studentName;
  String courseTitle;

  Student({
    required this.id,
    required this.studentName,
    required this.courseTitle,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      studentName: data['studentName'] ?? '',
      courseTitle: data['courseTitle'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'studentName': studentName, 'courseTitle': courseTitle};
  }
}
