import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart';

import '../model/event_model.dart';
import '../services/api_service.dart';
import '../app_theme.dart';
import 'statistics_screen.dart'; // Import màn hình thống kê

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<String> _getPublicDownloadsPath() async {
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }

    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      final downloadsPath = '${externalDir.path}/Download';
      final downloadsDirectory = Directory(downloadsPath);
      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }
      return downloadsDirectory.path;
    }

    throw Exception('Không tìm thấy thư mục lưu trữ ngoài.');
  }

  Future<void> _exportStudentsByEvent() async {
    final selectedEvent = await _showEventSelectionDialog();
    // Sửa lỗi: Kiểm tra null cho cả event và id của nó
    if (selectedEvent == null || selectedEvent.id == null) {
      return;
    }

    setState(() => _isLoading = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang chuẩn bị xuất file... Vui lòng chờ.')),
    );

    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Không được cấp quyền truy cập bộ nhớ.');
      }

      // Sửa lỗi: Dùng `selectedEvent.id!` vì đã kiểm tra null ở trên
      final studentData = await _apiService.fetchStudentDataForEvent(selectedEvent.id!);

      if (studentData.isEmpty) {
        throw Exception('Sự kiện này chưa có sinh viên nào tham dự.');
      }

      var excel = Excel.createExcel();
      Sheet sheet = excel[excel.getDefaultSheet()!];

      sheet.appendRow([
        TextCellValue('STT'), TextCellValue('Mã Sinh Viên'), TextCellValue('Họ Tên'),
        TextCellValue('Trường/Đơn vị'), TextCellValue('Email'), TextCellValue('Số điện thoại'),
      ]);

      for (var i = 0; i < studentData.length; i++) {
        final record = studentData[i];
        final student = record['student'];
        if (student == null) continue;

        final university = student['university'];

        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(student['student_code']?.toString() ?? 'N/A'),
          TextCellValue(student['name']?.toString() ?? 'N/A'),
          TextCellValue(university?['name']?.toString() ?? 'N/A'),
          TextCellValue(student['email']?.toString() ?? 'N/A'),
          TextCellValue(student['phone']?.toString() ?? 'N/A'),
        ]);
      }

      final downloadsPath = await _getPublicDownloadsPath();

      final safeTitle = selectedEvent.title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final fileName = 'DS_SV_${safeTitle}_${DateTime.now().toIso8601String().replaceAll(":", "-")}.xlsx';
      final filePath = '$downloadsPath/$fileName';

      final excelData = excel.save();
      if (excelData != null) {
        final file = File(filePath);
        await file.writeAsBytes(excelData);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xuất file thành công! Đã lưu tại: $filePath'),
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        throw Exception('Không thể lưu file Excel.');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      return true;
    }

    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cần quyền truy cập bộ nhớ'),
            content: const Text('Ứng dụng cần quyền để lưu file. Vui lòng vào cài đặt và cấp quyền truy cập bộ nhớ cho ứng dụng.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Để sau')),
              TextButton(onPressed: () { openAppSettings(); Navigator.of(context).pop(); }, child: const Text('Mở cài đặt')),
            ],
          ),
        );
      }
      return false;
    }
    status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<Event?> _showEventSelectionDialog() async {
    try {
      final events = await _apiService.fetchEvents();
      if (!mounted) return null;
      if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có sự kiện nào để chọn.')));
        return null;
      }
      return showDialog<Event>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chọn một sự kiện'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(title: Text(event.title), onTap: () => Navigator.of(context).pop(event));
              },
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách sự kiện: $e')));
      }
      return null;
    }
  }

  // Thêm hàm điều hướng đến màn hình thống kê
  void _navigateToStatistics(StatsType statsType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(initialStatsType: statsType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo & Thống kê')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildReportCard(
                context,
                icon: Icons.download_for_offline,
                title: 'Xuất danh sách theo sự kiện',
                subtitle: 'Xuất file Excel danh sách sinh viên tham dự.',
                onTap: _isLoading ? null : _exportStudentsByEvent,
              ),
              const SizedBox(height: 16),
              // Sửa: Gọi hàm điều hướng thống kê
              _buildReportCard(
                context,
                icon: Icons.school,
                title: 'Thống kê theo trường',
                subtitle: 'Xem biểu đồ số lượng sinh viên từ các trường/đơn vị.',
                onTap: () => _navigateToStatistics(StatsType.byUniversity),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                context,
                icon: Icons.event,
                title: 'Thống kê theo sự kiện',
                subtitle: 'Xem biểu đồ số lượng sinh viên của mỗi sự kiện.',
                onTap: () => _navigateToStatistics(StatsType.byEvent),
              ),
              const SizedBox(height: 16),
              _buildReportCard(
                context,
                icon: Icons.calendar_today,
                title: 'Thống kê theo ngày',
                subtitle: 'Xem biểu đồ số lượng sinh viên tham gia theo ngày.',
                onTap: () => _navigateToStatistics(StatsType.byDate),
              ),
            ],
          ),
          if (_isLoading)
            Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback? onTap}) {
    final bool isEnabled = onTap != null;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: isEnabled ? AppColors.primary : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isEnabled ? Colors.black87 : Colors.grey)),
        subtitle: Text(subtitle),
        onTap: onTap,
        enabled: isEnabled,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}