import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
static Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://vxxjfbvboktsxqccqrqf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4eGpmYnZib2t0c3hxY2NxcnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxNzgyODYsImV4cCI6MjA3Mzc1NDI4Nn0.B-2UN9d9V9pzU0Zft4WavBVfk2X6SZje2Xuw8Z6D_Oo',
  );
  }
}