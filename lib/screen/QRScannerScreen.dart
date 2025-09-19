import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../services/SessionCheckInService.dart';

class QRScannerScreen extends StatefulWidget {
  final int studentId; // ID của sinh viên đang đăng nhập

  const QRScannerScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final SessionCheckInService _checkinService = SessionCheckInService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(BarcodeCapture barcodeCapture) async {
    // Ngăn việc xử lý nhiều lần một mã QR
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        try {
          final data = jsonDecode(rawValue);
          final int sessionId = data['session_id'];

          // Gọi service để check-in
          final bool success = await _checkinService.createCheckin(
            sessionId: sessionId,
            studentId: widget.studentId,
            method: 'QR',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Check-in thành công!' : 'Check-in thất bại.'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
            Navigator.of(context).pop(); // Quay lại màn hình trước đó
          }
        } catch (e) {
          // Xử lý lỗi nếu QR không đúng định dạng hoặc có lỗi mạng
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mã QR không hợp lệ hoặc có lỗi xảy ra.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
    // Mở lại xử lý sau một khoảng thời gian ngắn
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã QR để Check-in')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleQRCode,
          ),
          // Lớp phủ để tạo giao diện đẹp hơn
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}