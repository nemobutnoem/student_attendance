import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;

  Future<Map<String, int>> _getStudentInfo() async {
    final authId = Supabase.instance.client.auth.currentUser?.id;
    if (authId == null) throw Exception('Chưa đăng nhập');
    final appUser = await Supabase.instance.client
        .from('app_user')
        .select('user_id')
        .eq('auth_id', authId)
        .single();
    final int userId = appUser['user_id'];
    final student = await Supabase.instance.client
        .from('student')
        .select('student_id')
        .eq('user_id', userId)
        .single();
    final int studentId = student['student_id'];
    return {'userId': userId, 'studentId': studentId};
  }

  Future<void> _handleBarcode(String rawValue) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final data = jsonDecode(rawValue);
      final int sessionId = data['session_id'];
      final info = await _getStudentInfo();

      // Kiểm tra đã điểm danh chưa
      final existing = await Supabase.instance.client
          .from('session_checkin')
          .select()
          .eq('session_id', sessionId)
          .eq('student_id', info['studentId'] as Object)
          .maybeSingle();

      if (existing != null) {
        // Đã điểm danh rồi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bạn đã được điểm danh phiên này rồi!")),
          );
        }
        return;
      }

      // Chưa điểm danh, thực hiện insert
      await Supabase.instance.client.from('session_checkin').insert({
        'session_id': sessionId,
        'user_id': info['userId'],
        'student_id': info['studentId'],
        'method': 'QR',
        'checkin_time': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Điểm danh thành công ✅")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi quét mã: $e")),
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quét mã QR")),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final barcode = barcodeCapture.barcodes.first;
          if (barcode.rawValue != null) {
            _handleBarcode(barcode.rawValue!);
          }
        },
      ),
    );
  }
}