import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/student_in_event_model.dart';
import '../util/constants.dart';

class StudentInEventService {
  final String baseUrl = "https://68cba3cb716562cf507455bb.mockapi.io/attendance-system";

  Future<List<StudentInEvent>> fetchStudentsInEvent(String eventId) async {
    final response = await http.get(Uri.parse('$baseUrl?event_id=$eventId'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => StudentInEvent.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load students in event");
    }
  }

  Future<void> addStudentInEvent(StudentInEvent student) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add student to event");
    }
  }

  Future<void> updateStudentStatus(String id, String newStatus) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": newStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update student status");
    }
  }

  Future<void> deleteStudentFromEvent(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete student from event");
    }
  }
}
