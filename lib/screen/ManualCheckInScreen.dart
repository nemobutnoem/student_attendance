import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualCheckinScreen extends StatefulWidget {
  final int sessionId;
  const ManualCheckinScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<ManualCheckinScreen> createState() => _ManualCheckinScreenState();
}

class _ManualCheckinScreenState extends State<ManualCheckinScreen> {
  final TextEditingController _studentIdController = TextEditingController();

  Future<void> _manualCheckin() async {
    final int? studentId = int.tryParse(_studentIdController.text);
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID sinh viên không hợp lệ')));
      return;
    }
    await Supabase.instance.client.from('session_checkin').insert({
      'session_id': widget.sessionId,
      'student_id': studentId,
      'checkin_time': DateTime.now().toIso8601String(),
      'method': 'manual',
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm danh thành công')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Điểm danh thủ công')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Nhập ID sinh viên'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _manualCheckin, child: const Text('Điểm danh')),
          ],
        ),
      ),
    );
  }
}