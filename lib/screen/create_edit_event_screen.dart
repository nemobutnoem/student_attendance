import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../model/event_model.dart';
import '../services/api_service.dart';

class CreateEditEventScreen extends StatefulWidget {
  final Event? event;
  final int userId;
  final String role;

  const CreateEditEventScreen({
    super.key,
    this.event,
    required this.userId,
    required this.role,
  });

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _organizerController;
  DateTime? _startDate;
  DateTime? _endDate;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late final bool _isEditMode;

  List<Map<String, dynamic>> _organizers = [];
  int? _selectedOrganizerId;
  bool _isOrganizersLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.event != null;
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _organizerController = TextEditingController(text: widget.event?.organizer ?? '');
    _startDate = widget.event?.startDate;
    _endDate = widget.event?.endDate;
    _selectedOrganizerId = widget.event?.userId;

    if (widget.role == 'admin') {
      _loadOrganizers();
    }
  }

  Future<void> _loadOrganizers() async {
    setState(() => _isOrganizersLoading = true);
    try {
      final List<Map<String, dynamic>> data = await _apiService.fetchOrganizers();
      setState(() {
        _organizers = data;
        if (_isEditMode && _selectedOrganizerId != null) {
          if (!_organizers.any((org) => org['user_id'] == _selectedOrganizerId)) {
            _selectedOrganizerId = null;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách Organizer: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isOrganizersLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveForm() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
      );
      return;
    }
    if (widget.role == 'admin' && _selectedOrganizerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một Organizer để gán')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final Map<String, dynamic> data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'organizer': _organizerController.text,
      'start_date': _startDate!.toIso8601String(),
      'end_date': _endDate!.toIso8601String(),
      'user_id': (widget.role == 'admin') ? _selectedOrganizerId : widget.userId,
    };

    try {
      if (_isEditMode) {
        await _apiService.updateEvent(widget.event!.id!, data);
      } else {
        await _apiService.createEvent(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditMode ? 'Cập nhật thành công!' : 'Tạo thành công!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $errorMessage')),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // Dán đoạn code này để thay thế cho @override Widget build(BuildContext context) cũ

  @override
  Widget build(BuildContext context) {
    // Quay về cấu trúc Scaffold đơn giản ban đầu
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Chỉnh sửa sự kiện' : 'Tạo sự kiện mới'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Giữ lại tất cả các trường nhập liệu, bao gồm cả dropdown
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên sự kiện'),
                validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Đơn vị tổ chức (VD: Khoa CNTT)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              // Dropdown chỉ hiển thị cho admin
              if (widget.role == 'admin')
                _isOrganizersLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                    : DropdownButtonFormField<int>(
                  value: _selectedOrganizerId,
                  decoration: const InputDecoration(
                    labelText: 'Gán cho người phụ trách',
                    border: OutlineInputBorder(),
                  ),
                  items: _organizers.map((organizer) {
                    return DropdownMenuItem<int>(
                      value: organizer['user_id'] as int,
                      child: Text(organizer['email'].toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedOrganizerId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Vui lòng chọn người phụ trách' : null,
                ),
              if (widget.role == 'admin') const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                        child: Text(_startDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(_startDate!)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                        child: Text(_endDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(_endDate!)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isEditMode ? 'CẬP NHẬT' : 'LƯU SỰ KIỆN', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}