import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/student_in_event_model.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

// Đảm bảo file này chỉ chứa class StudentInEventService
class StudentInEventService {
  SupabaseClient get _supabase => Supabase.instance.client;
  static const String _tableName = 'student_in_event';
  static const String _idColumn = 'student_in_event_id';

  /// Lấy danh sách sinh viên đã đăng ký trong tất cả sự kiện.
  Future<List<StudentInEvent>> fetchAllStudentsInEvents() async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('''
            student_in_event_id, status, event_id, student_id,
            student(student_id, student_code, name, email),
            event(event_id, title)
          ''');

      print('🔥 Raw data tất cả sự kiện: $data');
      return data.map<StudentInEvent>((item) => StudentInEvent.fromJson(item)).toList();
    } catch (e) {
      print('Lỗi khi lấy tất cả sinh viên trong các sự kiện: $e');
      throw Exception('Không thể tải danh sách sinh viên trong các sự kiện.');
    }
  }

  /// Cập nhật trạng thái của một sinh viên trong sự kiện
  Future<void> updateStudentStatus(int? studentInEventId, String newStatus) async {
    if (studentInEventId == null) {
      throw Exception('ID bản ghi không hợp lệ để cập nhật.');
    }
    try {
      await _supabase
          .from(_tableName)
          .update({'status': newStatus})
          .eq(_idColumn, studentInEventId);
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái: $e');
      throw Exception('Không thể cập nhật trạng thái.');
    }
  }

  /// Thêm một sinh viên vào sự kiện.
  Future<StudentInEvent?> addStudentToEvent(int eventId, String studentCode) async {
    try {
      // 1. Tìm student_id theo student_code
      final studentData = await _supabase
          .from('student')
          .select('student_id')
          .eq('student_code', studentCode)
          .maybeSingle();

      if (studentData == null) {
        throw Exception("Không tìm thấy sinh viên với mã: $studentCode");
      }

      final studentId = studentData['student_id'];

      // 2. Insert student vào event
      final data = await _supabase
          .from(_tableName)
          .insert({
        'event_id': eventId,
        'student_id': studentId,
        'status': 'registered',
      })
          .select('''
            student_in_event_id, student_id, status,
            student(student_id, student_code, name, email),
            event(event_id, title)
          ''')
          .single();

      print("🔥 Insert result: $data");

      return StudentInEvent.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception("Sinh viên này đã đăng ký sự kiện.");
      }
      print('Lỗi Postgres khi thêm sinh viên: ${e.message}');
      throw Exception("Không thể thêm sinh viên vào sự kiện.");
    } catch (e) {
      print('Lỗi khác khi thêm sinh viên: $e');
      throw Exception("Không thể thêm sinh viên vào sự kiện.");
    }
  }

  /// Xóa một sinh viên khỏi sự kiện.
  Future<void> deleteStudentFromEvent(int? studentInEventId) async {
    if (studentInEventId == null) {
      throw Exception('ID bản ghi không hợp lệ để xóa.');
    }
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq(_idColumn, studentInEventId);
    } catch (e) {
      print('Lỗi khi xóa sinh viên khỏi sự kiện: $e');
      throw Exception('Không thể xóa sinh viên.');
    }
  }

  /// Import danh sách sinh viên vào sự kiện
  Future<void> importStudentsFromExcel() async {
    try {
      // 1️⃣ Chọn file Excel
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) {
        print("❌ Không có file nào được chọn");
        return;
      }

      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();

      // 2️⃣ Đọc Excel
      final excel = Excel.decodeBytes(bytes);
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      if (sheet.rows.length <= 1) {
        print("⚠️ File Excel không có dữ liệu");
        return;
      }

      final List<Map<String, dynamic>> rowsToInsert = [];

      // 3️⃣ Duyệt từng dòng (bỏ header)
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        final eventIdStr = row[0]?.value?.toString() ?? '';
        final studentCode = row[1]?.value?.toString() ?? '';
        final status = row[2]?.value?.toString() ?? 'registered';

        if (eventIdStr.isEmpty || studentCode.isEmpty) {
          print("⚠️ Dòng ${i + 1} bị bỏ qua do thiếu event_id hoặc student_code");
          continue;
        }

        final eventId = int.tryParse(eventIdStr);
        if (eventId == null) {
          print("⚠️ Dòng ${i + 1} có event_id không hợp lệ: $eventIdStr");
          continue;
        }

        // 4️⃣ Lookup student_id từ student_code
        Map<String, dynamic>? studentData;
        try {
          studentData = await Supabase.instance.client
              .from('student')
              .select('student_id')
              .eq('student_code', studentCode)
              .maybeSingle();
        } catch (e) {
          print("⚠️ Không tìm thấy sinh viên với mã $studentCode ở dòng ${i + 1}");
          continue; // bỏ qua dòng này
        }

        if (studentData == null) {
          print("⚠️ Không tìm thấy sinh viên với mã $studentCode ở dòng ${i + 1}");
          continue;
        }

        final studentId = studentData['student_id'];

        rowsToInsert.add({
          'event_id': eventId,
          'student_id': studentId,
          'status': status,
        });
      }

      if (rowsToInsert.isEmpty) {
        print("⚠️ Không có dữ liệu hợp lệ để insert");
        return;
      }

      // 5️⃣ Bulk insert
      try {
        await Supabase.instance.client
            .from('student_in_event')
            .insert(rowsToInsert);

        print("✅ Import thành công ${rowsToInsert.length} dòng!");
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          print("⚠️ Một số sinh viên đã đăng ký sự kiện, bỏ qua trùng lặp.");
        } else {
          print("❌ Lỗi Postgres: ${e.message}");
        }
      }
    } catch (e) {
      print("❌ Lỗi khi import Excel: $e");
    }
  }

  /// Lấy danh sách sự kiện còn hạn (end_date >= NOW)
  Future<List<Map<String, dynamic>>> fetchActiveEvents() async {
    try {
      final data = await _supabase
          .from('event')
          .select('event_id, title, start_date, end_date')
          .gte('end_date', DateTime.now().toUtc().toIso8601String());

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Lỗi khi lấy sự kiện: $e");
      rethrow;
    }
  }
}
