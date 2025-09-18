import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Thay đổi import để trỏ đến trang chủ mới
import 'widgets/home_screen.dart';
import '../app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Sự kiện Sinh viên',
      theme: buildAppTheme(),

      // ===> THAY ĐỔI QUAN TRỌNG NHẤT LÀ Ở ĐÂY <===
      home: const HomeScreen(), // Đặt HomeScreen làm trang chủ

      debugShowCheckedModeBanner: false,
    );
  }
}

// test chơi cho zui nè