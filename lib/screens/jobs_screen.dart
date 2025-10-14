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
                color: selected ? const Color(0xFF6EB715) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: selected ? Colors.transparent : const Color(0xFFE9E9E9),
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[700],
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          // use a white border so it stays crisp and doesn't blend with the glow
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            // reduced green glow so it doesn't blur the border edge
            BoxShadow(
              color: const Color(0xFF6EB715).withOpacity(0.06),
              blurRadius: 18,
              spreadRadius: 3,
              offset: const Offset(0, 2),
            ),
            // subtle dark drop shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          // add extra bottom padding so cards are taller and won't overflow
          // when a floating green button or other overlay is present
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 44.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF6EB715),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${j['date'] ?? ''}, ${j['time'] ?? ''}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                j['title'] ?? '',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color.fromARGB(255, 142, 142, 142)),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    TextSpan(
                                      text: 'ผู้จ้าง ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color:  const Color.fromARGB(255, 142, 142, 142)),
                                    ),
                                    TextSpan(
                                      text: j['employer'] ?? 'น้องกาย',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: const Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${j['price_per_person'] ?? ''}.00 บาท',
                              style: TextStyle(
                                color: const Color.fromRGBO(46, 125, 50, 1),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
