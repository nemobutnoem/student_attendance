import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'display_qr_screen.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessions();
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    return await Supabase.instance.client
        .from('event_session')
        .select('session_id, title, start_time, end_time, location')
        .order('start_time');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách phiên sự kiện')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final sessions = snapshot.data!;
            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, i) {
                final session = sessions[i];
                return ListTile(
                  title: Text(session['title']),
                  subtitle: Text('Địa điểm: ${session['location']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DisplayQRScreen(
                          sessionId: session['session_id'],
                          sessionTitle: session['title'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
      ),
    );
  }
}