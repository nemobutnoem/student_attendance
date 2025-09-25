import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _studentCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  int? _universityId;
  bool _loading = true;
  bool _isNew = false; // true nếu chưa có record student

  List<Map<String, dynamic>> _universities = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final supabase = Supabase.instance.client;
    try {
      // Fetch danh sách university
      final universityList = await supabase
          .from('university')
          .select('university_id, name')
          .order('name');
      // Fetch thông tin student
      final data = await supabase
          .from('student')
          .select()
          .eq('user_id', widget.userId)
          .maybeSingle();

      setState(() {
        _universities = List<Map<String, dynamic>>.from(universityList);
      });

      if (data == null) {
        setState(() {
          _isNew = true;
          _loading = false;
        });
        return;
      }

      setState(() {
        _nameController.text = data['name'] ?? '';
        _studentCodeController.text = data['student_code'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _universityId = data['university_id'];
        _isNew = false;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final supabase = Supabase.instance.client;
    try {
      if (_universityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn phải chọn trường đại học')),
        );
        return;
      }
      if (_isNew) {
        // Insert mới
        await supabase.from('student').insert({
          'user_id': widget.userId,
          'name': _nameController.text.trim(),
          'student_code': _studentCodeController.text.trim(),
          'phone': _phoneController.text.trim(),
          'university_id': _universityId,
        });
        setState(() {
          _isNew = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo hồ sơ thành công')),
        );
      } else {
        // Update
        await supabase.from('student').update({
          'name': _nameController.text.trim(),
          'student_code': _studentCodeController.text.trim(),
          'phone': _phoneController.text.trim(),
          'university_id': _universityId,
        }).eq('user_id', widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin cá nhân")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
            TextField(
              controller: _studentCodeController,
              decoration: const InputDecoration(labelText: 'Mã sinh viên'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),

            const SizedBox(height: 12),
            // Dropdown chọn trường đại học
            DropdownButtonFormField<int>(
              value: _universityId,
              decoration: const InputDecoration(labelText: 'Trường đại học'),
              items: _universities.map((uni) {
                return DropdownMenuItem<int>(
                  value: uni['university_id'] as int,
                  child: Text(uni['name'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _universityId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text(_isNew ? 'Tạo hồ sơ' : 'Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}