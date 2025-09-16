class StudentInfo {
  final String firstName;
  final String? middleInitial;
  final String lastName;
  final String? image;
  final String? studentID;
  final String? course;
  final String? standingYear;
  final String? email;
  final String? phoneNum;
  final String? homeAddress;

  StudentInfo({
    required this.firstName,
    this.middleInitial,
    required this.lastName,
    this.image,
    this.studentID,
    this.course,
    this.standingYear,
    this.email,
    this.phoneNum,
    this.homeAddress,
  });
}
