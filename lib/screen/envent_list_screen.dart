import 'package:flutter/material.dart';
import '../services/student_service.dart';

class EventListScreen extends StatefulWidget {
  final int userId;

  const EventListScreen({super.key, required this.userId});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final StudentService _service = StudentService();
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final now = DateTime.now().toIso8601String();

      // Lấy student_id từ userId
      final studentRow = await _service.supabase
          .from('student')
          .select('student_id')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (studentRow == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy sinh viên!")),
        );
        return;
      }

      final studentId = studentRow['student_id'] as int;

      final response = await _service.supabase
          .from('event')
          .select('''
          event_id,
          title,
          start_date,
          end_date,
          student_in_event!inner(student_id)
        ''')
          .gte('end_date', now)
          .order('start_date');

      // Đánh dấu sự kiện nào đã đăng ký
      final events = List<Map<String, dynamic>>.from(response);
      for (var ev in events) {
        final regs = ev['student_in_event'] as List? ?? [];
        ev['registered'] = regs.any((r) => r['student_id'] == studentId);
      }

      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải sự kiện: $e")),
      );
    }
  }

  Future<void> _registerEvent(int index, int eventId) async {
    try {
      final studentRow = await _service.supabase
          .from('student')
          .select('student_id')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (studentRow == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy sinh viên!")),
        );
        return;
      }

      final studentId = studentRow['student_id'] as int;

      // check đã đăng ký chưa
      final existing = await _service.supabase
          .from('student_in_event')
          .select()
          .eq('student_id', studentId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn đã đăng ký sự kiện này rồi!")),
        );
        return;
      }

      await _service.registerEvent(studentId, eventId);

      // ✅ Cập nhật UI ngay lập tức
      setState(() {
        _events[index]['registered'] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng ký: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách sự kiện")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final ev = _events[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.blue),
              title: Text(ev['title'] ?? ''),
              subtitle: Text(
                "Bắt đầu: ${ev['start_date']}\nKết thúc: ${ev['end_date']}",
              ),
              trailing: ev['registered'] == true
                  ? const Chip(
                label: Text("Đã đăng ký"),
                backgroundColor: Colors.greenAccent,
              )
                  : ElevatedButton(
                onPressed: () =>
                    _registerEvent(index, ev['event_id']),
                child: const Text("Đăng ký"),
              ),
            ),
          );
        },
      ),
    );
  }
}
