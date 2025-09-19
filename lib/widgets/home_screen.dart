import 'package:flutter/material.dart';
import '../screen/event_management_screen.dart';
import '../screen/student_in_event_screen.dart';
import 'placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách các chức năng của ứng dụng
    final List<Map<String, dynamic>> features = [
      {
        'title': 'Quản lý Sự kiện',
        'icon': Icons.event_note,
        'screen': const EventManagementScreen(),
      },
      {
        'title': 'Quản lý Sinh viên',
        'icon': Icons.people,
        'screen': const PlaceholderScreen(title: 'Quản lý Sinh viên'),
      },
      {
        'title': 'Quản lý Trường/ĐV',
        'icon': Icons.school,
        'screen': const PlaceholderScreen(title: 'Quản lý Trường/Đơn vị'),
      },
      {
        'title': 'Quản lý Phiên',
        'icon': Icons.access_time,
        'screen': const PlaceholderScreen(title: 'Quản lý Phiên'),
      },
      {
        'title': 'SV trong Sự kiện',
        'icon': Icons.group_add,
        'screen': StudentInEventScreen(eventId: 3, eventTitle: "Sự kiện có SV"),
      },
      {
        'title': 'Báo cáo & Thống kê',
        'icon': Icons.bar_chart,
        'screen': const PlaceholderScreen(title: 'Báo cáo & Thống kê'),
      },
      {
        'title': 'Cài đặt',
        'icon': Icons.settings,
        'screen': const PlaceholderScreen(title: 'Cài đặt'),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Hiển thị 2 cột
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2, // Tỉ lệ chiều rộng/chiều cao của mỗi item
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _buildFeatureCard(
            context,
            title: feature['title'],
            icon: feature['icon'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => feature['screen']),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}