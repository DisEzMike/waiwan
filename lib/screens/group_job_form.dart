import 'package:flutter/material.dart';
import 'group_search_results.dart';
import '../model/group_job.dart';
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
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // We keep the raw date text in the controller; no local parsing required here.

      // We intentionally do not send payload here. Navigation to
      // GroupSearchResultsPage will let the user choose seniors first.

      // Per requirement: push the GroupSearchResultsPage so users can select seniors.
      final query =
          (_titleController.text.trim().isNotEmpty)
              ? _titleController.text.trim()
              : _descriptionController.text.trim();

      final job = GroupJobDetails(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateRange: _dateController.text.trim(),
        timeFrom: _timeFromController.text.trim(),
        timeTo: _timeToController.text.trim(),
        location: _locationController.text.trim(),
        maxSeniors: int.tryParse(_maxSeniorsController.text) ?? 0,
        pricePerPerson: int.tryParse(_pricePerPersonController.text) ?? 0,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupSearchResultsPage(query: query, job: job),
        ),
      );
    }
    else {
      // Show a helpful message when validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
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
                                          if (end.isBefore(start))
                                            end = start.add(
                                              const Duration(days: 1),
                                            );
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
                                          if (end.isBefore(start))
                                            start = end.subtract(
                                              const Duration(days: 1),
                                            );
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
                  initialValue: _locationController.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'กรุณาระบุสถานที่';
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final controller =
                                  TextEditingController(text: _locationController.text);
                              final result = await showDialog<bool?>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('สถานที่'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        hintText: 'ระบุสถานที่',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('ยกเลิก'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('ตกลง'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (result == true) {
                                setState(() {
                                  _locationController.text = controller.text.trim();
                                });
                                state.didChange(controller.text.trim());
                              }
                            },
                            icon: const Icon(Icons.location_on_outlined),
                            label: Text(
                              _locationController.text.isEmpty
                                  ? 'ปักหมุดสถานที่'
                                  : _locationController.text,
                            ),
                          ),
                        ),
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
                    child: const Text('ค้นหา'),
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
