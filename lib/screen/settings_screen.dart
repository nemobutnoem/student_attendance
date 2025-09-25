import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/login_screen.dart';
import '../theme_provider.dart'; // SỬA: Import ThemeProvider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supabase = Supabase.instance.client;
  String _appVersion = 'Đang tải...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }
  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // Sau khi logout, quay về LoginScreen và remove hết các màn hình trước đó
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    // SỬA: Kiểm tra `mounted` để tránh lỗi
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        // TODO: Điều hướng về màn hình đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đăng xuất thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    // SỬA: Cập nhật cách gọi `launchUrl` cho phiên bản mới
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở liên kết: $url')),
        );
      }
    }
  }

  // SỬA: Thêm hàm hiển thị dialog chọn giao diện
  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn giao diện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Sáng'), value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Tối'), value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Theo hệ thống'), value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // SỬA: Thêm hàm helper để lấy tên theme
  String _getCurrentThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light: return 'Sáng';
      case ThemeMode.dark: return 'Tối';
      case ThemeMode.system: return 'Hệ thống';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = supabase.auth.currentUser?.email ?? 'Không có thông tin';
    // SỬA: Lắng nghe sự thay đổi của theme
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Tài khoản'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(currentUserEmail),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Đổi mật khẩu'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng đang được phát triển!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red.shade700),
            ),
            // Khi người dùng nhấn vào, gọi hàm _logout
            onTap: () => _logout(context),
          ),
          const Divider(height: 32),

          // === SỬA NHÓM GIAO DIỆN ===
          _buildSectionHeader('Giao diện'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Chế độ'),
            // Sửa: Subtitle động theo theme hiện tại
            subtitle: Text(_getCurrentThemeName(themeProvider.themeMode)),
            // Sửa: Gọi dialog khi nhấn vào
            onTap: _showThemeDialog,
          ),

          const Divider(height: 32),

          _buildSectionHeader('Về ứng dụng'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Phiên bản'),
            subtitle: Text(_appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Chính sách bảo mật'),
            onTap: () => _launchURL('https://github.com/nemobutnoem'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          // SỬA: Lấy màu từ theme để tự động đổi màu Sáng/Tối
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}