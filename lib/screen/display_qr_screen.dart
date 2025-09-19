import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class DisplayQRScreen extends StatelessWidget {
  final int sessionId;
  final String sessionTitle;

  const DisplayQRScreen({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Dữ liệu cần mã hóa thành mã QR
    // Đây là một chuỗi JSON đơn giản chứa session_id
    final String qrData = jsonEncode({
      'session_id': sessionId,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR Check-in'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị tiêu đề của phiên
              Text(
                sessionTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Widget để hiển thị mã QR
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 280.0,
                gapless: false,
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(60, 60),
                ),
                // (Tùy chọn) Thêm logo ở giữa nếu muốn
                // embeddedImage: AssetImage('assets/images/logo.png'),
              ),

              const SizedBox(height: 24),
              // 3. Hướng dẫn cho người dùng
              const Text(
                'Đưa mã này cho sinh viên quét để điểm danh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}