import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/Student.dart';
import 'package:excel/excel.dart';
import 'dart:io';

class StudentService {
  final supabase = Supabase.instance.client;
  static const studentTable = 'student';
  static const studentInEventTable = 'student_in_event';

  /// -------------------------------
  /// CRUD cho student
  /// -------------------------------
  Future<List<Student>> getStudents() async {
    final response = await supabase.from(studentTable).select();
    return (response as List)
        .map((row) => Student.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addStudent(Student student) async {
    await supabase.from(studentTable).insert(student.toJson());
  }

  Future<void> updateStudent(Student student) async {
    await supabase
        .from(studentTable)
        .update(student.toJson())
        .eq('student_id', int.parse(student.studentId));
  }

  Future<void> deleteStudent(String studentId) async {
    await supabase
        .from(studentTable)
        .delete()
        .eq('student_id', int.parse(studentId));
  }

  /// Import sinh viên từ Excel
  Future<List<Student>> importFromExcel(File file) async {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    List<Student> students = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows.skip(1)) {
        // skip header
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

  /// -------------------------------
  /// Event logic
  /// -------------------------------

  /// Lấy danh sách sự kiện đã đăng ký theo studentId
  Future<List<Map<String, dynamic>>> getMyEventsByStudentId(int studentId) async {
    final response = await supabase
        .from(studentInEventTable)
        .select('''
        status,
        created_at,
        event:event_id (
          event_id,
          title,
          start_date,
          end_date,
          description
        )
      ''')
        .eq('student_id', studentId);

    return List<Map<String, dynamic>>.from(response ?? []);
  }

  /// Lấy danh sách sự kiện đã đăng ký theo userId của app
  Future<List<Map<String, dynamic>>> getMyEventsForAppUserId(int appUserId) async {
    final studentRow = await supabase
        .from(studentTable)
        .select('student_id')
        .eq('user_id', appUserId)
        .maybeSingle();

    if (studentRow == null) return [];
    final studentId = studentRow['student_id'] as int;
    return getMyEventsByStudentId(studentId);
  }

  /// Đăng ký sự kiện
  Future<bool> registerEvent(int studentId, int eventId) async {
    // Kiểm tra đã tồn tại chưa
    final exists = await supabase
        .from(studentInEventTable)
        .select()
        .eq('student_id', studentId)
        .eq('event_id', eventId)
        .maybeSingle();

    if (exists != null) {
      return false; // đã đăng ký rồi
    }

    await supabase.from(studentInEventTable).insert({
      'student_id': studentId,
      'event_id': eventId,
      'status': 'registered',
      'created_at': DateTime.now().toIso8601String(),
    });

    return true;
  }

  /// Hủy đăng ký sự kiện
  Future<bool> unregisterEvent(int studentId, int eventId) async {
    final deleted = await supabase
        .from(studentInEventTable)
        .delete()
        .eq('student_id', studentId)
        .eq('event_id', eventId);

    return deleted != null; // nếu có xóa được
  }

  /// Check xem sinh viên đã đăng ký chưa
  Future<bool> isRegistered(int studentId, int eventId) async {
    final exists = await supabase
        .from(studentInEventTable)
        .select('student_id')
        .eq('student_id', studentId)
        .eq('event_id', eventId)
        .maybeSingle();

    return exists != null;
  }
}
