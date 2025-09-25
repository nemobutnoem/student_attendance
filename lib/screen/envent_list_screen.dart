import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để format ngày tháng
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
    // SỬA: Đặt try-catch bao trùm toàn bộ để bắt lỗi tốt hơn
    try {
      final now = DateTime.now().toIso8601String();

      final studentRow = await _service.supabase
          .from('student')
          .select('student_id')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (studentRow == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy thông tin sinh viên!")),
        );
        setState(() => _loading = false);
        return;
      }

      final studentId = studentRow['student_id'] as int;

      // ====================================================================
      // SỬA LỖI CHÍNH: Xóa `!inner` để chuyển sang LEFT JOIN
      // ====================================================================
      final response = await _service.supabase
          .from('event')
          .select('''
            event_id,
            title,
            start_date,
            end_date,
            student_in_event(student_id)
          ''')
          .gte('end_date', now)
          .order('start_date');
      // ====================================================================

      final events = List<Map<String, dynamic>>.from(response);

      // Logic kiểm tra đăng ký vẫn hoạt động đúng
      for (var ev in events) {
        final regs = ev['student_in_event'] as List? ?? [];
        ev['registered'] = regs.any((r) => r['student_id'] == studentId);
      }

      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải sự kiện: $e")),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _registerEvent(int index, int eventId) async {
    // ... hàm này đã đúng, không cần sửa ...
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

  // SỬA: Format lại ngày tháng cho dễ đọc hơn
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString; // Trả về chuỗi gốc nếu không parse được
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách sự kiện")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text("Không có sự kiện nào sắp diễn ra."))
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
              leading: const Icon(Icons.event_available, color: Colors.blueAccent),
              title: Text(ev['title'] ?? 'Chưa có tiêu đề'),
              subtitle: Text(
                "Từ: ${_formatDate(ev['start_date'])} - Đến: ${_formatDate(ev['end_date'])}",
              ),
              trailing: ev['registered'] == true
                  ? const Chip(
                label: Text("Đã ĐK", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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