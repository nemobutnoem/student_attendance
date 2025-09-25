import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../model/event_model.dart';
import '../services/api_service.dart';

class CreateEditEventScreen extends StatefulWidget {
  final Event? event;
  final int userId;

  const CreateEditEventScreen({
    super.key,
    this.event,
    required this.userId,
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

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.event != null;
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _organizerController = TextEditingController(text: widget.event?.organizer ?? '');
    _startDate = widget.event?.startDate;
    _endDate = widget.event?.endDate;
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

    setState(() { _isLoading = true; });

    final Map<String, dynamic> data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'organizer': _organizerController.text,
      'start_date': _startDate!.toIso8601String(),
      'end_date': _endDate!.toIso8601String(),
    };

    try {
      if (_isEditMode) {
        // CHẾ ĐỘ CẬP NHẬT
        // SỬA: Dùng `widget.event!.id!` là chính xác vì model đã được chuẩn hóa.
        await _apiService.updateEvent(widget.event!.id!, data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật sự kiện thành công!')),
        );
      } else {
        // CHẾ ĐỘ TẠO MỚI
        // Dòng này sẽ fix lỗi RLS của bạn.
        data['user_id'] = widget.userId;
        await _apiService.createEvent(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo sự kiện thành công!')),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $errorMessage')),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phần build giữ nguyên, không cần thay đổi.
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên sự kiện'),
                validator: (value) => (value == null || value.isEmpty) ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Đơn vị tổ chức'),
                validator: (value) => (value == null || value.isEmpty) ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Không được để trống' : null,
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