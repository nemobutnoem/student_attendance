import 'package:flutter/material.dart';
import 'package:student_attendance/screen/ManualCheckInScreen.dart';
import 'package:student_attendance/screen/QRScannerScreen.dart';
import '../screen/event_management_screen.dart';
import '../screen/student_in_event_screen.dart';
import '../screen/university_management_screen.dart';
import 'placeholder_screen.dart';
import '../screen/SessionListScreen.dart';
import 'package:student_attendance/screen/student_management_screen.dart';
import '../screen/event_session_management_screen.dart';
import '../screen/reporting_screen.dart';
import '../screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;   // admin | organizer | student
  final int userId;    // id user sau khi login

  const HomeScreen({
    super.key,
    required this.role,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Danh sách menu cho từng role
  List<Map<String, dynamic>> get _adminFeatures => [
    {
      'title': 'Quản lý Sự kiện',
      'icon': Icons.event_note,
      'screen': const EventManagementScreen(),
    },
    {
      'title': 'Quản lý Sinh viên',
      'icon': Icons.people,
      'screen': const StudentManagementScreen(),
    },
    {
      'title': 'Quản lý Trường/ĐV',
      'icon': Icons.school,
      'screen': const UniversityScreen(),
    },
    {
      'title': 'Quản lý Phiên',
      'icon': Icons.access_time,
      'screen': const EventSessionManagementScreen(),
    },
    {
      'title': 'SV trong Sự kiện',
      'icon': Icons.group_add,
      'screen': StudentInEventScreen(eventId: 4, eventTitle: "Sự kiện có SV"),
    },
    {
      'title': 'Điểm danh',
      'icon': Icons.fact_check_outlined,
      'screen': const SessionListScreen(),
    },
    {
      'title': 'Báo cáo & Thống kê',
      'icon': Icons.bar_chart,
      'screen': const ReportingScreen(),
    },
    {
      'title': 'Cài đặt',
      'icon': Icons.settings,
      'screen': const SettingsScreen(),
    },
  ];

  List<Map<String, dynamic>> get _organizerFeatures => [
    {
      'title': 'Quản lý Sự kiện của tôi',
      'icon': Icons.event_note,
      'screen': const EventManagementScreen(), // Trong màn EventManagementScreen, chỉ query event organizer_id = userId
    },
    {
      'title': 'Quản lý Phiên của tôi',
      'icon': Icons.access_time,
      'screen': const EventSessionManagementScreen(), // Cũng filter theo event của organizer
    },
    {
      'title': 'Điểm danh',
      'icon': Icons.fact_check_outlined,
      'screen': const SessionListScreen(),
    },
    {
      'title': 'Cài đặt',
      'icon': Icons.settings,
      'screen': const SettingsScreen(),
    },
  ];

  List<Map<String, dynamic>> _studentFeatures(int studentId) => [
    {
      'title': 'Quét QR Check-in',
      'icon': Icons.qr_code_scanner,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRScannerScreen(studentId: studentId),
          ),
        );
      },
    },
    {
      'title': 'Sự kiện của tôi',
      'icon': Icons.event,
      'screen': const PlaceholderScreen(title: 'Sự kiện của tôi'),
    },
    {
      'title': 'Thông tin cá nhân',
      'icon': Icons.person,
      'screen': const PlaceholderScreen(title: 'Thông tin cá nhân'),
    },
    {
      'title': 'Cài đặt',
      'icon': Icons.settings,
      'screen': const SettingsScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Chọn menu theo role
    List<Map<String, dynamic>> features;
    if (widget.role == "admin") {
      features = _adminFeatures;
    } else if (widget.role == "organizer") {
      features = _organizerFeatures;
    } else {
      features = _studentFeatures(widget.userId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ (${widget.role})'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _buildFeatureCard(
            context,
            title: feature['title'],
            icon: feature['icon'],
            onTap: feature['onTap'] ??
                    () {
                  if (feature['screen'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => feature['screen']),
                    );
                  }
                },
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
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