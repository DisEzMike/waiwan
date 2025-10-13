import 'package:flutter/material.dart';
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
      // Determine start and end date from dateController (supports range like "YYYY-MM-DD - YYYY-MM-DD")
      String startDate = _dateController.text;
      String endDate = _dateController.text;
      if (_dateController.text.contains(' - ')) {
        final parts = _dateController.text.split(' - ');
        if (parts.length >= 2) {
          startDate = parts[0];
          endDate = parts[1];
        }
      }

      // Build payload matching backend JSON schema (see provided example)
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final payload = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        // Use full ISO datetimes for backend
        'started_at': '${startDate}T${_timeFromController.text}:00Z',
        'ended_at': '${endDate}T${_timeToController.text}:00Z',
        'price': int.tryParse(_pricePerPersonController.text) ?? 0,
        'work_type': 'general', // default; adjust UI later to choose
        'vehicle': false, // default; adjust UI later to choose
        'max_seniors': int.tryParse(_maxSeniorsController.text) ?? 0,
        'location': {
          'address': _locationController.text,
          // backend may accept additional properties; leave empty for now
          'additionalProp1': {},
        },
        'updated_at': nowIso,
      };

      // Previously navigated to JobDetailScreen here. Requirement: do NOT navigate.
      // Show a confirmation dialog with a brief summary instead.
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('ข้อมูลการค้นหา'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('งาน: ${payload['title'] ?? '-'}'),
                  Text(
                    'วันที่: ${_dateController.text.isNotEmpty ? _dateController.text : '-'}',
                  ),
                  Text(
                    'เวลา: ${_timeFromController.text}-${_timeToController.text}',
                  ),
                  Text('จำนวน: ${payload['max_seniors'] ?? '-'} คน'),
                  Text('ค่าจ้าง/คน: ${payload['price'] ?? '-'}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ปิด'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จ้างงานแบบกลุ่ม'),
        backgroundColor: const Color(0xFF6EB715),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('งาน'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
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
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Intentionally do nothing: button is visible but not interactive
                    },
                    icon: const Icon(Icons.location_on_outlined),
                    label: Text(
                      _locationController.text.isEmpty
                          ? 'ปักหมุดสถานที่'
                          : _locationController.text,
                    ),
                  ),
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
