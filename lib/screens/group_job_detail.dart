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
        foregroundColor: Colors.white,
        centerTitle: true,
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  // soft green glow
                  BoxShadow(
                    color: const Color(0xFF6EB715).withOpacity(0.06),
                    blurRadius: 18,
                    spreadRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                  // subtle dark drop shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ผู้สูงอายุ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  // show only avatars that fit in one row; if more, show a "ดูทั้งหมด" button
                  LayoutBuilder(builder: (context, constraints) {
                    // avatar diameter + spacing
                    const double avatarDiameter = 56; // radius 28
                    const double spacing = 8;
                    // available width inside the card (subtract small padding)
                    final double available = constraints.maxWidth - 8;
                    final int fitCount = available > 0
                        ? (available + spacing) ~/ (avatarDiameter + spacing)
                        : 1;
                    final int showCount = fitCount.clamp(1, selectedSeniors.length);
                    final int hiddenCount = selectedSeniors.length - showCount;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // avatars
                        for (var i = 0; i < showCount; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: spacing),
                            child: CircleAvatar(
                              radius: avatarDiameter / 2,
                              backgroundImage: NetworkImage(selectedSeniors[i].profile.imageUrl),
                            ),
                          ),

                        // if some hidden, show nearby 'ดูทั้งหมด' with count
                        if (hiddenCount > 0)
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: SizedBox(
                                    width: 320,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('รายชื่อผู้สูงอายุ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: selectedSeniors.map((s) => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(radius: 28, backgroundImage: NetworkImage(s.profile.imageUrl)),
                                                const SizedBox(height: 6),
                                                SizedBox(width: 80, child: Text(s.displayName, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
                                              ],
                                            )).toList(),
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('ปิด')),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Text('ดูทั้งหมด (+$hiddenCount)', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                      // helper for two-column rows
                      Builder(builder: (context) {
                        final labelStyle = const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        );
                        final valueStyle = TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey[700],
                        );

                        Widget twoCol(String label, String value, {Color? valueColor}) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '$label',
                                    style: labelStyle,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.right,
                                    style: valueStyle.copyWith(
                                      color: valueColor ?? valueStyle.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 'ดูทั้งหมด' link centered under avatars
                            Center(
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('ดูทั้งหมด', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black54)),
                              ),
                            ),
                            const Divider(thickness: 1.5),
                            twoCol('วันที่ :', job.dateRange),
                            twoCol('เวลา :', '${job.timeFrom} - ${job.timeTo} น.'),
                            twoCol('งานที่จ้าง', job.title, valueColor: Colors.green),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Text('รายละเอียด', style: labelStyle),
                            ),
                            Text(
                              job.description,
                              style: TextStyle(
                                color:  const Color.fromARGB(255, 114, 114, 114),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            twoCol('จำนวนคน', '${selectedSeniors.length}', valueColor: Colors.grey[800]!),
                            twoCol('ราคาที่จ้าง', '${job.pricePerPerson} บาท / คน', valueColor: Colors.green),
                            const SizedBox(height: 12),
                            const Divider(thickness: 1.5),
                            const SizedBox(height: 8),
                            Text('สถานที่ทำงาน', style: labelStyle),
                            const SizedBox(height: 6),
                            Text(job.location, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 18),
                          ],
                        );
                      }),
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            minimumSize: const Size(48, 48),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
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
        ),
      ),
    );
  }
}
