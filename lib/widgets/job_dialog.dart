import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/services/job_service.dart';
import 'package:waiwan/utils/font_size_helper.dart';
import 'package:waiwan/widgets/input_field.dart';

class JobDialog extends StatefulWidget {
  final String seniorId;
  const JobDialog({super.key, required this.seniorId});

  @override
  State<JobDialog> createState() => _JobDialogState();
}

class _JobDialogState extends State<JobDialog> {
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _jobController.dispose();
    _detailsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  _onSubmit() async {
    // Handle job submission logic here
    final userId = localStorage.getItem('userId') ?? '';
    /* 
    Assuming  
      1 means 'proposed'
      2 means 'accepted'
      3 means 'payment done'
      4 means 'in progress'
      5 means 'completed'
      6 means 'cancelled'
    */
    dynamic payload = {
      "status": 1,
      "user_id": userId,
      "senior_id": widget.seniorId,
      "title": _jobController.text,
      "description": _detailsController.text,
      "price": _priceController.text,
      "work_type": "general",
      "vehicle": true,
    };

    final jobService = JobService();
    try {
      final response = await jobService.createJob(payload);
      final chatroomId = response['chatroom_id'];
      final jobId = response['id'];
      Navigator.pop(context, {chatroomId, jobId}); // Close dialog and return response
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      print('Error submitting job: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "เสนองาน",
                  style: FontSizeHelper.createTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                buildTextField("งานที่ต้องการ", _jobController),
                buildTextField(
                  "รายละเอียดงาน",
                  _detailsController,
                  maxLines: 3,
                ),
                buildTextField(
                  "ราคาที่เสนอ (บาท)",
                  _priceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // TextButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                //   child: const Text('Close'),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _onSubmit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EB715),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('เสนองาน'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
