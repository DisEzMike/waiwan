import 'package:flutter/material.dart';
import 'package:waiwan/model/group_job.dart';
import 'package:waiwan/model/elderly_person.dart';

class GroupJobDetailPage extends StatelessWidget {
  final GroupJobDetails job;
  final List<ElderlyPerson> selectedSeniors;

  const GroupJobDetailPage({
    super.key,
    required this.job,
    required this.selectedSeniors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดกลุ่ม'),
        backgroundColor: const Color(0xFF6EB715),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ผู้สูงอายุ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedSeniors.length,
                  itemBuilder: (context, i) {
                    final s = selectedSeniors[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(s.profile.imageUrl),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'วันที่ : ${job.dateRange}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text('เวลา : ${job.timeFrom}:${job.timeTo}'),
              const SizedBox(height: 6),
              Text(
                'งานที่จ้าง : ${job.title}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text('รายละเอียด\n${job.description}'),
              const SizedBox(height: 12),
              Text(
                'จำนวนคน\n${selectedSeniors.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'ราคาที่จ้าง\n${job.pricePerPerson} บาท / คน',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('สถานที่ทำงาน\n${job.location}'),
              const Spacer(),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text('แก้ไข'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EB715),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text('ยืนยัน'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
