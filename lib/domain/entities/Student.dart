class Student {
  final String studentId;
  final String name;
  final String studentCode;
  final String email;
  final String phone;
  final String? universityId;

  Student({
    required this.studentId,
    required this.name,
    required this.studentCode,
    required this.email,
    required this.phone,
    this.universityId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'].toString(),
      name: json['name'] ?? '',
      studentCode: json['student_code'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      universityId: json['university_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': int.parse(studentId),
      'name': name,
      'student_code': studentCode,
      'email': email,
      'phone': phone,
      'university_id': universityId != null ? int.tryParse(universityId!) : null,
    };
  }
}