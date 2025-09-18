import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/event_session_model.dart';
import '../services/event_session_service.dart';

class EventSessionFormScreen extends StatefulWidget {
  final EventSession? eventSession;
  final int eventId;

  const EventSessionFormScreen({
    super.key,
    this.eventSession,
    required this.eventId,
  });

  @override
  State<EventSessionFormScreen> createState() => _EventSessionFormScreenState();
}

class _EventSessionFormScreenState extends State<EventSessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  final EventSessionService _sessionService = EventSessionService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventSession?.title ?? '');
    _locationController = TextEditingController(text: widget.eventSession?.location ?? '');
    _startDateTime = widget.eventSession?.startTime;
    _endDateTime = widget.eventSession?.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartDateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: (isStartDateTime ? _startDateTime : _endDateTime) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          (isStartDateTime ? _startDateTime : _endDateTime) ?? DateTime.now(),
        ),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartDateTime) {
            _startDateTime = selectedDateTime;
          } else {
            _endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thời gian bắt đầu và kết thúc')),
      );
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!) || _endDateTime!.isAtSameMomentAs(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thời gian kết thúc phải sau thời gian bắt đầu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionToSave = EventSession(
        sessionId: widget.eventSession?.sessionId,
        eventId: widget.eventId,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        startTime: _startDateTime!,
        endTime: _endDateTime!,
      );

      if (widget.eventSession == null) {
        // Tạo mới
        await _sessionService.createEventSession(sessionToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo phiên thành công!')),
          );
        }
      } else {
        // Cập nhật
        await _sessionService.updateEventSession(sessionToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật phiên thành công!')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventSession != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa Phiên' : 'Tạo Phiên mới'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveForm,
              child: Text(
                isEditing ? 'Cập nhật' : 'Tạo',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
              // Tiêu đề phiên
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề phiên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề phiên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Địa điểm
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa điểm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa điểm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Thời gian bắt đầu
              InkWell(
                onTap: () => _selectDateTime(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Thời gian bắt đầu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _startDateTime != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_startDateTime!)
                        : 'Chọn thời gian bắt đầu',
                    style: TextStyle(
                      color: _startDateTime != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Thời gian kết thúc
              InkWell(
                onTap: () => _selectDateTime(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Thời gian kết thúc',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _endDateTime != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_endDateTime!)
                        : 'Chọn thời gian kết thúc',
                    style: TextStyle(
                      color: _endDateTime != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nút lưu
              ElevatedButton(
                onPressed: _isLoading ? null : _saveForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Đang lưu...'),
                        ],
                      )
                    : Text(isEditing ? 'Cập nhật Phiên' : 'Tạo Phiên'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}