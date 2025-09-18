import 'package:flutter/material.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  // Hàm xử lý (sẽ được code ở các bước sau)
  void _exportStudentsByEvent() {
    // Tạm thời hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng xuất danh sách theo sự kiện đang được phát triển!')),
    );
  }

  void _showStatsByUniversity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thống kê theo trường đang được phát triển!')),
    );
  }

  void _showStatsByDate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thống kê theo ngày đang được phát triển!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo & Thống kê'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(
            context,
            icon: Icons.download_for_offline,
            title: 'Xuất danh sách theo sự kiện',
            subtitle: 'Xuất file Excel/PDF danh sách sinh viên tham dự của từng sự kiện.',
            onTap: _exportStudentsByEvent,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            icon: Icons.school,
            title: 'Thống kê theo trường',
            subtitle: 'Xem biểu đồ số lượng sinh viên tham gia từ các trường/đơn vị.',
            onTap: _showStatsByUniversity,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            context,
            icon: Icons.calendar_today,
            title: 'Thống kê theo ngày',
            subtitle: 'Xem biểu đồ số lượng sinh viên tham gia theo từng ngày.',
            onTap: _showStatsByDate,
          ),
        ],
      ),
    );
  }

  // Widget helper để tạo card cho mỗi chức năng
  Widget _buildReportCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}