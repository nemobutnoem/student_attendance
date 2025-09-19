import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:student_attendance/supabase_config.dart';


import 'widgets/home_screen.dart';
import '../app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  // GỌI INIT SUPABASE Ở ĐÂY
  await SupabaseConfig.initSupabase();

  runApp(const MyApp());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Sự kiện Sinh viên',
      theme: buildAppTheme(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// test chơi cho zui nè