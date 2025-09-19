import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/Student.dart';
import 'package:excel/excel.dart';
import 'dart:io';
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
  Future<List<Student>> importFromExcel(File file) async {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    List<Student> students = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows.skip(1)) { // skip header
        final s = Student(
          studentId: row[0]?.value.toString() ?? '',
          name: row[1]?.value.toString() ?? '',
          studentCode: row[2]?.value.toString() ?? '',
          email: row[3]?.value.toString() ?? '',
          phone: row[4]?.value.toString() ?? '',
          universityId: row[5]?.value.toString() ?? '',
        );
        students.add(s);
      }
    }

    return students;
  }
}
