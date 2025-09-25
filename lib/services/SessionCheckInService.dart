import 'package:supabase_flutter/supabase_flutter.dart';

class SessionCheckInService {
  final supabase = Supabase.instance.client;

  Future<bool> createCheckin({
    required int sessionId,
    required int studentId,
    required int userId,
    required String method,
  }) async {
    try {
      final response = await supabase.from('session_checkin').insert({
        'session_id': sessionId,
        'student_id': studentId,
        'user_id': userId,
        'method': method,
      });

      print('DEBUG Insert response: $response');
      return true;
    } catch (e) {
      print('Check-in error: $e');
      return false;
    }
  }
}
