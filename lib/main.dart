import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/home_screen.dart';
import 'app_theme.dart'; // Import file app_theme.dart

void main() {
  runApp(
    // BƯỚC 1: Cung cấp ThemeProvider cho toàn bộ ứng dụng
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
    // BƯỚC 2: "Lắng nghe" sự thay đổi của ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Student Attendance',
          debugShowCheckedModeBanner: false,

          // BƯỚC 3: Áp dụng theme dựa trên lựa chọn của người dùng
          theme: buildAppTheme(), // Theme cho chế độ sáng
          darkTheme: buildAppDarkTheme(), // Theme cho chế độ tối
          themeMode: themeProvider.themeMode, // Quyết định theme nào sẽ được hiển thị

          home: const HomeScreen(),
        );
      },
    );
  }
}