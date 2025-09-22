import 'package:flutter/material.dart';
import '../model/student_in_event_model.dart';
import '../services/student_in_event_service.dart';

class StudentInEventScreen extends StatefulWidget {
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
      _studentsInEvent = _service.fetchAllStudentsInEvents();
    });
  }

  void _handleMenuSelection(String value, StudentInEvent student) async {
    try {
      if (value == "attended" || value == "cancelled") {
        await _service.updateStudentStatus(student.id, value);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công!')),
        );
      } else if (value == "delete") {
        await _service.deleteStudentFromEvent(student.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sinh viên khỏi sự kiện.')),
        );
      }
      _loadData();
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
        title: const Text('SV tham gia sự kiện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () async {
              try {
                await _service.importStudentsFromExcel();
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import Excel thành công!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi import Excel: $e')),
                );
              }
            },
            tooltip: "Import từ file Excel",
          ),
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
            return const Center(
              child: Text("Chưa có sinh viên nào trong sự kiện này."),
            );
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
                  title: Row(
                    children: [
                      const Text(
                        "MSSV: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          student.student?.studentCode ?? 'Null',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "Sự kiện: ${student.event?['title'] ?? 'Không có'}\n"
                        "Trạng thái: ${student.status}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: "Đánh dấu: Đã tham dự",
                        onPressed: () => _handleMenuSelection("attended", student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.orange),
                        tooltip: "Đánh dấu: Đã hủy",
                        onPressed: () => _handleMenuSelection("cancelled", student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Xóa khỏi sự kiện",
                        onPressed: () => _handleMenuSelection("delete", student),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          int? selectedEventId;
          List<Map<String, dynamic>> events = [];

          try {
            events = await _service.fetchActiveEvents();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi khi tải sự kiện: $e")),
            );
            return;
          }

          await showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Thêm sinh viên vào sự kiện"),
                    content: SingleChildScrollView(
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: "Nhập mã sinh viên",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<int>(
                              value: selectedEventId,
                              decoration: const InputDecoration(
                                labelText: "Chọn sự kiện",
                                border: OutlineInputBorder(),
                              ),
                              items: events.map((event) {
                                return DropdownMenuItem<int>(
                                  value: event['event_id'],
                                  child: Text(event['title']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedEventId = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Hủy"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final code = controller.text.trim();
                          if (code.isNotEmpty && selectedEventId != null) {
                            try {
                              await _service.addStudentToEvent(
                                  selectedEventId!, code);
                              Navigator.pop(context);
                              _loadData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Thêm sinh viên thành công!"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: const Text("Thêm"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
