import 'package:flutter/material.dart';
import 'job_detail.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final List<String> _tabs = [
    'เสนอ / รอยืนยัน',
    'รอชำระ',
    'ชำระแล้ว / กำลังดำเนินการ',
    'เสร็จสิ้น',
    'ยกเลิก',
  ];

  int _selectedTab = 0;

  Widget _buildStatusTabs() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final selected = index == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color:
                    selected
                        ? const Color(0xFF6EB715)
                        : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard([Map<String, dynamic>? job]) {
    final j =
        job ??
        {
          'title': 'จัดสถานที่',
          'date': '20/02/2568',
          'time': '09:00 - 14:00',
          'price_per_person': '400',
          'total': '800',
          'location': '88/1 แขวงลาดกระบัง ...',
          'description': 'รายละเอียดงาน',
        };

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (c) => JobDetailScreen(job: j)));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF6EB715),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${j['date'] ?? ''}, ${j['time'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          j['title'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          '฿ ${j['price_per_person'] ?? ''}/คน',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('จำนวน ${j['max_seniors'] ?? 'N'} คน'),
                        const SizedBox(width: 12),
                        Text(
                          'ทั้งหมด ฿ ${j['total'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FCEB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title area handled by NavBarWrapper AppBar
            _buildStatusTabs(),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => _buildJobCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
