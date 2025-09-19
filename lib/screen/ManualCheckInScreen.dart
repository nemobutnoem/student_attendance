import 'package:flutter/material.dart';

import '../services/SessionCheckInService.dart';

class ManualCheckinScreen extends StatefulWidget {
  final int sessionId;

  const ManualCheckinScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<ManualCheckinScreen> createState() => _ManualCheckinScreenState();
}

class _ManualCheckinScreenState extends State<ManualCheckinScreen> {
  final SessionCheckInService _checkinService = SessionCheckInService();
  late Future<List<Map<String, dynamic>>> _attendanceListFuture;

  @override
  void initState() {
    super.initState();
    _loadAttendanceList();
  }

  void _loadAttendanceList() {
    _attendanceListFuture = _checkinService.getCheckinStatusForSession(widget.sessionId);
  }

  Future<void> _manualCheckin(int studentId) async {
    final success = await _checkinService.createCheckin(
      sessionId: widget.sessionId,
      studentId: studentId,
      method: 'manual',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Điểm danh thành công!' : 'Có lỗi xảy ra.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      // Tải lại danh sách để cập nhật trạng thái
      setState(() {
        _loadAttendanceList();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm danh thủ công - Phiên ${widget.sessionId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadAttendanceList();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendanceListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có sinh viên nào đăng ký sự kiện này.'));
          }

          final students = snapshot.data!;
          final checkedInStudents = students.where((s) => s['checkin_status'] == 'Đã Check-in').toList();
          final notCheckedInStudents = students.where((s) => s['checkin_status'] == 'Chưa Check-in').toList();

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              _buildSectionHeader('Đã Check-in (${checkedInStudents.length})', Colors.green),
              ...checkedInStudents.map((student) => _buildStudentTile(student, true)),
              const SizedBox(height: 20),
              _buildSectionHeader('Chưa Check-in (${notCheckedInStudents.length})', Colors.orange),
              ...notCheckedInStudents.map((student) => _buildStudentTile(student, false)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student, bool isCheckedIn) {
    return Card(
      child: ListTile(
        title: Text(student['student_name'] ?? 'Không có tên'),
        subtitle: Text('MSSV: ${student['student_code'] ?? 'N/A'}'),
        trailing: isCheckedIn
            ? Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
          onPressed: () => _manualCheckin(student['student_id']),
          child: const Text('Check-in'),
        ),
      ),
    );
  }
}