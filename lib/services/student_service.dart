import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/Student.dart';

class StudentService {
  final supabase = Supabase.instance.client;
  static const table = 'students';

  Future<List<Student>> getStudents() async {
    final response = await supabase.from(table).select();
    return (response as List)
        .map((row) => Student.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addStudent(Student student) async {
    await supabase.from(table).insert(student.toJson());
  }

  Future<void> updateStudent(Student student) async {
    await supabase
        .from(table)
        .update(student.toJson())
        .eq('student_id', int.parse(student.studentId));
  }

  Future<void> deleteStudent(String studentId) async {
    await supabase
        .from(table)
        .delete()
        .eq('student_id', int.parse(studentId));
  }
}
