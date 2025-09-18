import 'package:flutter/material.dart';
import '../model/event_model.dart';
import '../services/api_service.dart';
import 'create_edit_event_screen.dart';
import '../app_theme.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để format ngày tháng đẹp hơn

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _futureEvents = apiService.fetchEvents();
    });
  }

  // ==========================================================
  // HÀM XỬ LÝ VIỆC XÓA SỰ KIỆN
  // ==========================================================
  void _handleDelete(Event event) {
    // Hiển thị hộp thoại xác nhận trước khi xóa
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận Xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sự kiện "${event.title}" không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Đóng hộp thoại trước
                try {
                  // Gọi API để xóa
                  await apiService.deleteEvent(event.id);

                  // Hiển thị thông báo thành công
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa sự kiện thành công!')),
                    );
                  }

                  // Tải lại danh sách sự kiện để cập nhật giao diện
                  _loadEvents();

                } catch (e) {
                  // Hiển thị thông báo nếu có lỗi
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi xóa: $e')),
                    );
                  }
                }
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
        title: const Text('Quản lý Sự kiện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi tải dữ liệu: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadEvents,
                      child: const Text('Thử lại'),
                    )
                  ],
                ),
              ),
            );
          }
          else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final events = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  child: ListTile(
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Tổ chức bởi: ${event.organizer}\n'
                            'Từ ${DateFormat('dd/MM/yyyy').format(event.startDate)} đến ${DateFormat('dd/MM/yyyy').format(event.endDate)}'
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateEditEventScreen(event: event),
                              ),
                            ).then((_) => _loadEvents());
                          },
                        ),
                        // ==========================================================
                        // GỌI HÀM _handleDelete KHI NHẤN NÚT
                        // ==========================================================
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _handleDelete(event),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          else {
            return const Center(child: Text('Không có sự kiện nào.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEditEventScreen(),
            ),
          ).then((_) => _loadEvents());
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}