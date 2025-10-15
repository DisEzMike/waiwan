import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/model/job.dart';
import 'package:waiwan/screens/group_search_results.dart';
import 'package:waiwan/services/job_service.dart';
import 'package:waiwan/utils/helper.dart';
import 'map_picker_screen.dart';
// Pin button intentionally left as a no-op (visible but does nothing)

class GroupJobFormPage extends StatefulWidget {
  const GroupJobFormPage({super.key});

  @override
  State<GroupJobFormPage> createState() => _GroupJobFormPageState();
}

class _GroupJobFormPageState extends State<GroupJobFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeFromController = TextEditingController();
  final TextEditingController _timeToController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxSeniorsController = TextEditingController();
  final TextEditingController _pricePerPersonController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final String userId = localStorage.getItem("userId") ?? "";

  // Location data
  LatLng? _selectedLocation;
  String _selectedAddress = '';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    _locationController.dispose();
    _maxSeniorsController.dispose();
    _pricePerPersonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Validate date range format
        if (!_dateController.text.contains(' - ')) {
          showErrorSnackBar(context, 'กรุณาเลือกช่วงวันที่ให้ถูกต้อง');
          return;
        }

        final dateParts = _dateController.text.split(' - ');
        if (dateParts.length != 2) {
          showErrorSnackBar(context, 'รูปแบบวันที่ไม่ถูกต้อง');
          return;
        }

        // Parse and validate datetime
        final startDateTime = DateTime.parse(
          '${dateParts[0]} ${_timeFromController.text}:00',
        );
        final endDateTime = DateTime.parse(
          '${dateParts[1]} ${_timeToController.text}:00',
        );

        // Validate that end time is after start time
        if (endDateTime.isBefore(startDateTime)) {
          showErrorSnackBar(context, 'เวลาสิ้นสุดต้องมาหลังเวลาเริ่มต้น');
          return;
        }

        final jobPayLoad = {
          "title": _titleController.text.trim(),
          "description": _descriptionController.text.trim(),
          "price": int.parse(_pricePerPersonController.text.trim()),
          "work_type": "group",
          "vehicle": false,
          "max_seniors": int.parse(_maxSeniorsController.text.trim()),
          "started_at": startDateTime.toIso8601String(),
          "ended_at": endDateTime.toIso8601String(),
          "location": {
            "address":
                _selectedAddress.isNotEmpty
                    ? _selectedAddress
                    : _locationController.text.trim(),
            "lat": _selectedLocation?.latitude,
            "lng": _selectedLocation?.longitude,
            "note": _noteController.text.trim(),
          },
        };

        final res = await JobService().createJob(jobPayLoad);
        final job = MyJob.fromJson(res['job']);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GroupSearchResultsPage(job: job),
          ),
        );
      } catch (e) {
        print('Error creating job: $e');
        if (mounted) {
          String errorMessage = 'เกิดข้อผิดพลาดในการสร้างงาน';

          // Try to extract meaningful error message
          if (e.toString().contains('FormatException')) {
            errorMessage =
                'เกิดข้อผิดพลาดในการประมวลผลข้อมูล กรุณาลองใหม่อีกครั้ง';
          } else if (e.toString().contains('TimeoutException')) {
            errorMessage =
                'การเชื่อมต่อหมดเวลา กรุณาตรวจสอบอินเทอร์เน็ตและลองใหม่';
          } else if (e.toString().contains('SocketException')) {
            errorMessage =
                'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่อ';
          } else if (e.toString().contains('DateTime')) {
            errorMessage =
                'รูปแบบวันที่หรือเวลาไม่ถูกต้อง กรุณาตรวจสอบและลองใหม่';
          }

          showErrorSnackBar(context, errorMessage);
        }
      }
    } else {
      // Show a helpful message when validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => MapPickerScreen(
              initialLocation: _selectedLocation,
              initialAddress: _selectedAddress,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result['location'] as LatLng?;
        _selectedAddress = result['address'] as String? ?? '';
        _locationController.text = _selectedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จ้างงานแบบกลุ่ม'),
        backgroundColor: const Color(0xFF6EB715),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('งาน'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'กรุณากรอกชื่องาน';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('รายละเอียดงาน'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'กรุณากรอกรายละเอียดงาน';
                    }
                    return null;
                  },
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('วันที่'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dateController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'กรุณาเลือกช่วงวันที่';
                    }
                    return null;
                  },
                  readOnly: true,
                  onTap: () async {
                    DateTime start = DateTime.now();
                    DateTime end = DateTime.now().add(const Duration(days: 1));

                    final result = await showDialog<bool?>(
                      context: context,
                      builder: (ctx) {
                        return StatefulBuilder(
                          builder: (ctx2, setState2) {
                            String fmt(DateTime d) =>
                                '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

                            return AlertDialog(
                              title: const Text('เลือกช่วงวันที่'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('วันที่เริ่มต้น'),
                                    subtitle: Text(fmt(start)),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: ctx2,
                                        initialDate: start,
                                        firstDate: DateTime(start.year - 5),
                                        lastDate: DateTime(start.year + 5),
                                      );
                                      if (picked != null) {
                                        setState2(() {
                                          start = picked;
                                          if (end.isBefore(start)) {
                                            end = start.add(
                                              const Duration(days: 1),
                                            );
                                          }
                                        });
                                      }
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('วันที่สิ้นสุด'),
                                    subtitle: Text(fmt(end)),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: ctx2,
                                        initialDate: end,
                                        firstDate: DateTime(end.year - 5),
                                        lastDate: DateTime(end.year + 5),
                                      );
                                      if (picked != null) {
                                        setState2(() {
                                          end = picked;
                                          if (end.isBefore(start)) {
                                            start = end.subtract(
                                              const Duration(days: 1),
                                            );
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(ctx2).pop(false),
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx2).pop(true),
                                  child: const Text('ตกลง'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );

                    if (result == true) {
                      final s = start;
                      final e = end;
                      final sStr =
                          '${s.year.toString().padLeft(4, '0')}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}';
                      final eStr =
                          '${e.year.toString().padLeft(4, '0')}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}';
                      _dateController.text = '$sStr - $eStr';
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'YYYY-MM-DD - YYYY-MM-DD',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('เวลา'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _timeFromController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'กรุณาเลือกเวลาเริ่มต้น';
                          }
                          return null;
                        },
                        readOnly: true,
                        onTap: () async {
                          final now = TimeOfDay.now();
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: now,
                          );
                          if (picked != null) {
                            final h = picked.hour.toString().padLeft(2, '0');
                            final mm = picked.minute.toString().padLeft(2, '0');
                            _timeFromController.text = '$h:$mm';
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'HH:MM',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      alignment: Alignment.center,
                      child: const Text('-', style: TextStyle(fontSize: 18)),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _timeToController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'กรุณาเลือกเวลาสิ้นสุด';
                          }
                          return null;
                        },
                        readOnly: true,
                        onTap: () async {
                          final now = TimeOfDay.now();
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: now,
                          );
                          if (picked != null) {
                            final h = picked.hour.toString().padLeft(2, '0');
                            final mm = picked.minute.toString().padLeft(2, '0');
                            _timeToController.text = '$h:$mm';
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'HH:MM',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('สถานที่'),
                const SizedBox(height: 8),
                FormField<String>(
                  initialValue:
                      _selectedAddress.isNotEmpty
                          ? _selectedAddress
                          : _locationController.text,
                  validator: (v) {
                    if (_selectedAddress.isEmpty &&
                        (v == null || v.trim().isEmpty)) {
                      return 'กรุณาระบุสถานที่';
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show selected address if available
                        if (_selectedAddress.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedAddress = '';
                                      _selectedLocation = null;
                                      _locationController.clear();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Map picker button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openMapPicker,
                            icon: const Icon(Icons.location_on_outlined),
                            label: Text(
                              _selectedAddress.isNotEmpty
                                  ? 'เปลี่ยนสถานที่'
                                  : 'ปักหมุดสถานที่',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ที่อยู่ (เพิ่มเติม)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText:
                                'เพิ่มเติม เช่น ใกล้ MRT, หมายเลขห้อง, ชั้น ฯลฯ',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        // Manual text input (optional)
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                            child: Text(
                              state.errorText ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('จำนวนคน'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _maxSeniorsController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'กรุณาระบุจำนวนคน';
                              }
                              final n = int.tryParse(v);
                              if (n == null || n <= 0) {
                                return 'จำนวนคนต้องเป็นตัวเลขมากกว่า 0';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ค่าจ้าง / คน'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pricePerPersonController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'กรุณาระบุค่าจ้างต่อคน';
                              }
                              final p = int.tryParse(v);
                              if (p == null || p < 0) {
                                return 'ค่าจ้างต้องเป็นตัวเลข';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color.fromARGB(255, 252, 247, 247),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EB715),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _onSubmit,
                    child: const Text('สร้างงาน'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
