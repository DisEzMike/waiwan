import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/model/job.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/screens/main_screen.dart';
import 'package:waiwan/services/job_service.dart';
import 'package:waiwan/utils/font_size_helper.dart';
import 'package:waiwan/screens/map_picker_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateJobScreen extends StatefulWidget {
  final String seniorId;
  final String? query;

  const CreateJobScreen({super.key, required this.seniorId, this.query});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now().add(const Duration(hours: 2));
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.query ?? "";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // Form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validations
    if (_selectedAddress.isEmpty && _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกสถานที่โดยกดปักหมุด'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('วันเวลาสิ้นสุดต้องมากกว่าวันเวลาเริ่มต้น'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Handle job submission logic here
    final userId = localStorage.getItem('userId') ?? '';

    final payload = {
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "price": double.tryParse(_priceController.text.trim()) ?? 0.0,
      "work_type": "individual",
      "vehicle": false,
      "max_seniors": 1,
      "started_at": startDateTime.toIso8601String(),
      "ended_at": endDateTime.toIso8601String(),
      "senior_id": widget.seniorId,
      "employer_id": userId,
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

    final jobService = JobService();
    try {
      final response = await jobService.createJob(payload);
      final job = MyJob.fromJson(response['job']);


      // Invite the selected senior
      final invitePayload = {
        "senior_id": widget.seniorId,
        "message": "มีงานใหม่สำหรับคุณ",
      };
      await jobService.inviteSenior(job.id, invitePayload);

      // Show success and return
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('เสนองานเรียบร้อยแล้ว')));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyMainPage(initialIndex: 2)),
          (route) => false,
        );
      }
    } catch (e) {
      // Handle error
      print('Error submitting job: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? startDateTime : endDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          startDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            startDateTime.hour,
            startDateTime.minute,
          );
          // If end date is before start date, update it
          if (endDateTime.isBefore(startDateTime)) {
            endDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              endDateTime.hour,
              endDateTime.minute,
            );
          }
        } else {
          endDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            endDateTime.hour,
            endDateTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        isStart ? startDateTime : endDateTime,
      ),
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          startDateTime = DateTime(
            startDateTime.year,
            startDateTime.month,
            startDateTime.day,
            time.hour,
            time.minute,
          );
        } else {
          endDateTime = DateTime(
            endDateTime.year,
            endDateTime.month,
            endDateTime.day,
            time.hour,
            time.minute,
          );
        }
      });
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

      // Show success feedback
      if (_selectedAddress.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เลือกสถานที่แล้ว: $_selectedAddress'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เสนองาน"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: Consumer<FontSizeProvider>(
                builder: (context, fontSizeProvider, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: "งานที่ต้องการ",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกชื่องาน';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: "รายละเอียดงาน",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกรายละเอียดงาน';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: "ราคาที่เสนอ (บาท)",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกราคา';
                            }
                            final price = double.tryParse(value.trim());
                            if (price == null || price <= 0) {
                              return 'กรุณากรอกราคาที่ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Start Date/Time Picker
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "วันเริ่มงาน",
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () => _selectDate(true),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${startDateTime.day}/${startDateTime.month}/${startDateTime.year}",
                                              style:
                                                  FontSizeHelper.createTextStyle(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () => _selectTime(true),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}",
                                              style:
                                                  FontSizeHelper.createTextStyle(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // End Date/Time Picker
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "วันสิ้นสุดงาน",
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () => _selectDate(false),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${endDateTime.day}/${endDateTime.month}/${endDateTime.year}",
                                              style:
                                                  FontSizeHelper.createTextStyle(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () => _selectTime(false),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}",
                                              style:
                                                  FontSizeHelper.createTextStyle(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Location Picker with Google Maps
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "สถานที่",
                                    style: FontSizeHelper.createTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    " *",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _openMapPicker,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          _selectedAddress.isEmpty
                                              ? Colors.red.withOpacity(0.5)
                                              : Colors.grey,
                                      width: _selectedAddress.isEmpty ? 1.5 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        _selectedAddress.isEmpty
                                            ? Colors.red.withOpacity(0.05)
                                            : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color:
                                            _selectedAddress.isEmpty
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedAddress.isEmpty
                                              ? "กดเพื่อปักหมุดสถานที่ (จำเป็น)"
                                              : _selectedAddress,
                                          style: FontSizeHelper.createTextStyle(
                                            fontSize: 16,
                                            color:
                                                _selectedAddress.isEmpty
                                                    ? Colors.red[600]
                                                    : Colors.black,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_selectedAddress.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    "กรุณาเลือกสถานที่โดยการปักหมุด",
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Note field
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: "หมายเหตุเพิ่มเติม (ไม่บังคับ)",
                            border: OutlineInputBorder(),
                            hintText: "ระบุข้อมูลเพิ่มเติมหากต้องการ...",
                          ),
                          maxLines: 2,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6EB715),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'เสนองาน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
