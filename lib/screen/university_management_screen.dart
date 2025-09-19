import 'package:flutter/material.dart';
import '../domain/entities/University.dart';
import '../services/university_service.dart';

class UniversityScreen extends StatefulWidget {
  const UniversityScreen({Key? key}) : super(key: key);

  @override
  State<UniversityScreen> createState() => _UniversityScreenState();
}

class _UniversityScreenState extends State<UniversityScreen> {
  List<University> universities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final data = await UniversityService().fetchUniversities();
    setState(() {
      universities = data;
      isLoading = false;
    });
  }

  int _generateNewId() {
    final existingIds = universities
        .map((u) => u.universityId ?? 0)
        .where((id) => id > 0)
        .toList()
      ..sort();

    int newId = 1;
    for (final id in existingIds) {
      if (id == newId) {
        newId++;
      } else if (id > newId) {
        break; // tìm được khoảng trống
      }
    }
    return newId;
  }


  void _showForm({University? uni}) {
    final nameCtrl = TextEditingController(text: uni?.name ?? "");
    final addressCtrl = TextEditingController(text: uni?.address ?? "");
    final contactCtrl = TextEditingController(text: uni?.contactInfo ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(uni == null ? "Thêm Trường/Đơn vị" : "Sửa Trường/Đơn vị"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Tên")),
              TextField(controller: addressCtrl, decoration: InputDecoration(labelText: "Địa chỉ")),
              TextField(controller: contactCtrl, decoration: InputDecoration(labelText: "Liên hệ")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          // Bên trong hàm _showForm, tìm đến nút ElevatedButton
          ElevatedButton(
            onPressed: () async {
              if (uni == null) {
                // Thêm mới
                await UniversityService().addUniversity(
                  University(
                    // SỬA Ở ĐÂY: Bỏ hoàn toàn universityId khi thêm mới
                    // universityId: _generateNewId(), // <-- XÓA DÒNG NÀY
                    name: nameCtrl.text,
                    address: addressCtrl.text,
                    contactInfo: contactCtrl.text,
                  ),
                );
              } else {
                // Sửa (giữ nguyên)
                await UniversityService().updateUniversity(
                  University(
                    universityId: uni.universityId,
                    name: nameCtrl.text,
                    address: addressCtrl.text,
                    contactInfo: contactCtrl.text,
                  ),
                );
              }
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: Text("Lưu"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUniversity(int id) async {
    await UniversityService().deleteUniversity(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý Trường/Đơn vị")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: universities.length,
        itemBuilder: (context, index) {
          final uni = universities[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            // ...
            child: ListTile(
              isThreeLine: true, // Cho phép ListTile hiển thị 3 dòng
              title: Text(
                uni.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng địa chỉ
                  Text(uni.address ?? "Không có địa chỉ"),
                  const SizedBox(height: 4), // Thêm một chút khoảng cách
                  // Dòng thông tin liên hệ
                  Text(uni.contactInfo ?? "Không có thông tin liên hệ"),
                ],
              ),
              trailing: Row(
// ...
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showForm(uni: uni),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUniversity(uni.universityId!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
