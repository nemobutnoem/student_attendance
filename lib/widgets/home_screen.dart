import 'package:flutter/material.dart';

// Đảm bảo các đường dẫn import này là chính xác
import '../screen/event_management_screen.dart';
import '../screen/student_in_event_screen.dart';
import '../screen/university_management_screen.dart';
import 'placeholder_screen.dart';
import '../screen/SessionListScreen.dart';
import '../screen/student_management_screen.dart';
import '../screen/event_session_management_screen.dart';
import '../screen/reporting_screen.dart';
import '../screen/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final String role;
  final int userId;

  const HomeScreen({
    super.key,
    required this.role,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardTheme = Theme.of(context).cardTheme;

    final List<Map<String, dynamic>> features = [
      {'title': 'Quản lý Sự kiện', 'icon': Icons.event_note_outlined, 'screen': const EventManagementScreen()},
      {'title': 'Quản lý Sinh viên', 'icon': Icons.groups_outlined, 'screen': const StudentManagementScreen()},
      {'title': 'Quản lý Trường/ĐV', 'icon': Icons.school_outlined, 'screen': const UniversityScreen()},
      {'title': 'Quản lý Phiên', 'icon': Icons.access_time_outlined, 'screen': const EventSessionManagementScreen()},
      {'title': 'SV trong Sự kiện', 'icon': Icons.group_add_outlined, 'screen': StudentInEventScreen(eventId: 4, eventTitle: "Sự kiện có SV")},
      {'title': 'Điểm danh', 'icon': Icons.fact_check_outlined, 'screen': const SessionListScreen()},
      {'title': 'Báo cáo & Thống kê', 'icon': Icons.bar_chart_outlined, 'screen': const ReportingScreen()},
      {'title': 'Cài đặt', 'icon': Icons.settings_outlined, 'screen': const SettingsScreen()},
    ];

    return Scaffold(
      // SỬA LỖI Ở ĐÂY: Thêm thuộc tính extendBodyBehindAppBar
      extendBodyBehindAppBar: true,

      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('Trang chủ', style: textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondary.withOpacity(0.3),
                  colorScheme.background,
                  colorScheme.primary.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            // Giờ đây SafeArea sẽ tự động đẩy GridView xuống dưới AppBar
            // mà không làm ảnh hưởng đến nền gradient
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      if (feature['screen'] != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => feature['screen']));
                      }
                    },
                    borderRadius: cardTheme.shape is RoundedRectangleBorder
                        ? (cardTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadius
                        : BorderRadius.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          feature['icon'],
                          size: 40,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          feature['title'],
                          textAlign: TextAlign.center,
                          style: textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}