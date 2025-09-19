import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ManualCheckinScreen.dart'; // Import màn hình điểm danh thủ công
import 'display_qr_screen.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  // Biến Future để lưu trữ kết quả truy vấn từ Supabase
  late final Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm để tải danh sách các phiên khi màn hình được khởi tạo
    _sessionsFuture = _fetchSessions();
  }

  // Hàm truy vấn danh sách các phiên từ bảng 'event_session'
  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    try {
      final response = await Supabase.instance.client
          .from('event_session')
          .select('session_id, title, start_time, location')
          .order('start_time', ascending: false); // Sắp xếp theo thời gian mới nhất
      return response;
    } catch (e) {
      // Nếu có lỗi, ném ra để FutureBuilder có thể bắt được
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách phiên: $e')),
      );
      rethrow;
    }
  }

  void _showOptions(BuildContext context, Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.qr_code_2_rounded),
              title: const Text('Hiển thị mã QR'),
              onTap: () {
                Navigator.pop(ctx); // Đóng hộp thoại
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayQRScreen(
                      sessionId: session['session_id'],
                      sessionTitle: session['title'] ?? 'Không có tiêu đề',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: const Text('Điểm danh thủ công'),
              onTap: () {
                Navigator.pop(ctx); // Đóng hộp thoại
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualCheckinScreen(
                      sessionId: session['session_id'],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn phiên để điểm danh'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có phiên nào được tìm thấy.'));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.access_time_filled_rounded),
                  title: Text(
                    session['title'] ?? 'Không có tiêu đề',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Địa điểm: ${session['location'] ?? 'Chưa xác định'}'),
                  trailing: const Icon(Icons.more_vert),
                  // SỬA Ở ĐÂY: Gọi hàm _showOptions khi nhấn vào
                  onTap: () {
                    _showOptions(context, session);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}