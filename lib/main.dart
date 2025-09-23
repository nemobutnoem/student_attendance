import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screen/login_screen.dart';
import 'widgets/home_screen.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://vxxjfbvboktsxqccqrqf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4eGpmYnZib2t0c3hxY2NxcnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxNzgyODYsImV4cCI6MjA3Mzc1NDI4Nn0.B-2UN9d9V9pzU0Zft4WavBVfk2X6SZje2Xuw8Z6D_Oo',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Hàm xác định màn hình đầu tiên
  Future<Widget> _getInitialScreen() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;

    // Nếu chưa đăng nhập -> quay về Login
    if (session == null) {
      return const LoginScreen();
    }

    final uuid = client.auth.currentUser!.id; // UUID dạng String

    // Query bảng app_user để lấy user_id (int8) + role
    final response = await client
        .from('app_user')
        .select('user_id, role')
        .eq('auth_id', uuid) // auth_id mapping với supabase user id
        .maybeSingle();

    if (response == null || response['role'] == null) {
      return const LoginScreen(); // fallback nếu chưa có role
    }

    final int userId = response['user_id'] as int; // ép về int
    final String role = response['role'] as String;

    return HomeScreen(
      role: role,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Lỗi: ${snapshot.error}")),
            );
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
    );
  }
}