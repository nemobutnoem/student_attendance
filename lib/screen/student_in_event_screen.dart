import 'package:flutter/material.dart';
import '../model/student_in_event_model.dart';
import '../services/student_in_event_service.dart';

class StudentInEventScreen extends StatefulWidget {
  // Constructor đúng phải ở đây, trong file UI
  final int eventId;
  final String eventTitle;

  const StudentInEventScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<StudentInEventScreen> createState() => _StudentInEventScreenState();
}

class _StudentInEventScreenState extends State<StudentInEventScreen> {
  final StudentInEventService _service = StudentInEventService();
  late Future<List<StudentInEvent>> _studentsInEvent;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _studentsInEvent = _service.fetchStudentsInEvent(widget.eventId);
    });
  }

  void _handleMenuSelection(String value, StudentInEvent student) async {
    try {
      if (value == "attended" || value == "cancelled") {
        await _service.updateStudentStatus(student.id, value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật trạng thái thành công!')),
        );
      } else if (value == "delete") {
        await _service.deleteStudentFromEvent(student.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa sinh viên khỏi sự kiện.')),
        );
      }
      _loadData(); // Tải lại dữ liệu sau khi hành động thành công
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SV trong: ${widget.eventTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<List<StudentInEvent>>(
        future: _studentsInEvent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có sinh viên nào trong sự kiện này."));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${student.studentId}')),
                  title: Text("Mã sinh viên: ${student.studentId}"),
                  subtitle: Text("Trạng thái: ${student.status}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuSelection(value, student),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "attended", child: Text("Đánh dấu: Đã tham dự")),
                      const PopupMenuItem(value: "cancelled", child: Text("Đánh dấu: Đã hủy")),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Xóa khỏi sự kiện", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}