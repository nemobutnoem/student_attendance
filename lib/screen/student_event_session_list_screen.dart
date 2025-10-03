import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class StudentEventSessionListScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;
  final int studentId;

  const StudentEventSessionListScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
    required this.studentId,
  }) : super(key: key);

  @override
  State<StudentEventSessionListScreen> createState() => _StudentEventSessionListScreenState();
}

class _StudentEventSessionListScreenState extends State<StudentEventSessionListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchSessions();
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('event_session')
        .select('session_id, title, start_time, end_time, location, session_checkin(session_id, student_id)')
        .eq('event_id', widget.eventId);

    print("👉 Raw sessions: $data");

    // map lại dữ liệu
    return (data as List).map<Map<String, dynamic>>((s) {
      final session = Map<String, dynamic>.from(s);
      final checkins = session['session_checkin'] as List<dynamic>? ?? [];
      final checkedIn = checkins.any((c) => c['student_id'] == widget.studentId);

      return {
        ...session,
        'checked_in': checkedIn,
      };
    }).toList();
  }

  String _formatDT(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return iso ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phiên - ${widget.eventTitle}')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final sessions = snapshot.data!;
          if (sessions.isEmpty) return const Center(child: Text("Chưa có phiên nào."));
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.access_time, color: s['checked_in'] ? Colors.green : Colors.grey),
                  title: Text(s['title']),
                  subtitle: Text(
                    'Bắt đầu: ${_formatDT(s['start_time'])}\n'
                        'Kết thúc: ${_formatDT(s['end_time'])}\n'
                        'Địa điểm: ${s['location'] ?? ""}',
                  ),
                  trailing: s['checked_in']
                      ? Chip(label: Text("Đã điểm danh"), backgroundColor: Colors.green.shade100)
                      : Chip(label: Text("Chưa điểm danh"), backgroundColor: Colors.red.shade100),
                ),
              );
            },
          );
        },
      ),
    );
  }
}