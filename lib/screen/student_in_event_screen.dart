import 'package:flutter/material.dart';
import '../model/student_in_event_model.dart';
import '../services/student_in_event_service.dart';

class StudentInEventScreen extends StatefulWidget {
  final String eventId;
  const StudentInEventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _StudentInEventScreenState createState() => _StudentInEventScreenState();
}

class _StudentInEventScreenState extends State<StudentInEventScreen> {
  final StudentInEventService _service = StudentInEventService();
  late Future<List<StudentInEvent>> _studentsInEvent;

  @override
  void initState() {
    super.initState();
    _studentsInEvent = _service.fetchStudentsInEvent(widget.eventId);
  }

  void _refreshData() {
    setState(() {
      _studentsInEvent = _service.fetchStudentsInEvent(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Students in Event")),
      body: FutureBuilder<List<StudentInEvent>>(
        future: _studentsInEvent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No students in this event"));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text("Student ID: ${student.studentId}"),
                subtitle: Text("Status: ${student.status}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == "attended" || value == "cancelled") {
                      await _service.updateStudentStatus(student.id, value);
                      _refreshData();
                    } else if (value == "delete") {
                      await _service.deleteStudentFromEvent(student.id);
                      _refreshData();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "attended", child: Text("Mark as Attended")),
                    const PopupMenuItem(value: "cancelled", child: Text("Cancel Registration")),
                    const PopupMenuItem(value: "delete", child: Text("Remove from Event")),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
