import 'package:flutter/material.dart';
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
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
      body: Stack(
        children: [
          // LỚP 1: HIỆU ỨNG NỀN "SÓNG"
          Container(
            decoration: BoxDecoration(
              color: colorScheme.background,
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondary.withOpacity(0.5), // Màu tím
                  colorScheme.background,
                  colorScheme.primary.withOpacity(0.4), // Màu xanh
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // LỚP 2: NỘI DUNG CHÍNH
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Text('Trang chủ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                style: TextStyle(
                                  // SỬA LỖI Ở ĐÂY: Lấy màu từ theme thay vì gọi trực tiếp
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
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
          ),
        ],
      ),
    );
  }
}