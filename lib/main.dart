import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import thư viện Supabase

// Import các file cần thiết khác trong dự án của bạn
import 'theme_provider.dart';
import 'screen/login_screen.dart';
import 'app_theme.dart';
import 'supabase_config.dart'; // 2. Import file cấu hình Supabase của bạn

// 3. Chuyển hàm main thành hàm bất đồng bộ (async)
Future<void> main() async {
  // 4. Đảm bảo các thành phần của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 5. Khởi tạo Supabase với URL và Anon Key của bạn
  await Supabase.initialize(
    url: 'https://vxxjfbvboktsxqccqrqf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4eGpmYnZib2t0c3hxY2NxcnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxNzgyODYsImV4cCI6MjA3Mzc1NDI4Nn0.B-2UN9d9V9pzU0Zft4WavBVfk2X6SZje2Xuw8Z6D_Oo', // Lấy từ file supabase_config.dart
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Student Attendance',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          darkTheme: buildAppDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}

// Helper để truy cập nhanh đến Supabase client
final supabase = Supabase.instance.client;