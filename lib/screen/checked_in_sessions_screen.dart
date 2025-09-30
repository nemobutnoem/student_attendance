import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckedInSessionsScreen extends StatefulWidget {
  const CheckedInSessionsScreen({super.key});

  @override
  State<CheckedInSessionsScreen> createState() => _CheckedInSessionsScreenState();
}

class _CheckedInSessionsScreenState extends State<CheckedInSessionsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchCheckedInSessions();
  }

  Future<List<Map<String, dynamic>>> _fetchCheckedInSessions() async {
    final authId = Supabase.instance.client.auth.currentUser?.id;
    if (authId == null) throw Exception("Chưa đăng nhập"); // thêm dòng này để không bao giờ null

    final appUser = await Supabase.instance.client
        .from('app_user').select('user_id').eq('auth_id', authId).single();
    final student = await Supabase.instance.client
        .from('student').select('student_id').eq('user_id', appUser['user_id']).single();
    final checkins = await Supabase.instance.client
        .from('session_checkin')
        .select('session_id, checkin_time')
        .eq('student_id', student['student_id']);
    if (checkins == null || checkins.isEmpty) return [];
    List<Map<String, dynamic>> result = [];
    for (var c in checkins) {
      final session = await Supabase.instance.client
          .from('event_session')
          .select('title, start_time, location')
          .eq('session_id', c['session_id'])
          .single();
      result.add({
        'title': session['title'],
        'start_time': session['start_time'],
        'location': session['location'],
        'checkin_time': c['checkin_time'],
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Các phiên đã điểm danh")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final sessions = snapshot.data!;
          if (sessions.isEmpty) return const Center(child: Text('Bạn chưa điểm danh phiên nào.'));
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];
              return ListTile(
                title: Text(s['title']),
                subtitle: Text('Thời gian: ${s['start_time']} - Địa điểm: ${s['location']} \nĐiểm danh lúc: ${s['checkin_time']}'),
              );
            },
          );
        },
      ),
    );
  }
}