import 'package:flutter/material.dart';
import 'package:waiwan/screens/elderlyscreen/payment_page.dart';
import 'package:waiwan/screens/elderlyscreen/review_screen.dart';
import 'package:waiwan/model/chat_message.dart';
import 'package:waiwan/providers/font_size_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isConfirmed = false;
  bool _isPaid = false;
  bool _isCompleted = false;

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatTimeRange(String? startIso, String? endIso) {
    if (startIso == null) return '-';
    try {
      final s = DateTime.parse(startIso);
      final e = endIso != null ? DateTime.parse(endIso) : null;
      final sStr =
          '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}';
      final eStr =
          e != null
              ? '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}'
              : '-';
      return '$sStr - $eStr';
    } catch (_) {
      return '-';
    }
  }

  String _computeTotal(Map<String, dynamic> job) {
    final price = double.tryParse(job['price']?.toString() ?? '') ?? 0;
    final maxSeniors = int.tryParse(job['max_seniors']?.toString() ?? '') ?? 1;
    final total = (price * maxSeniors).toInt();
    return total.toString();
  }

  String _currentStatusText() {
    // Order: 1) รอการยืนยันจากผู้สูงอายุ 2) ชำระเงิน 3) อยู่ในช่วงการทำงาน 4) เสร็จสิ้น
    if (!_isConfirmed) return 'รอการยืนยันจากผู้สูงอายุ';
    if (!_isPaid) return 'ชำระเงิน';
    if (!_isCompleted) return 'อยู่ในช่วงการทำงาน';
    return 'เสร็จสิ้น';
  }

  Widget _buildStepIcon(IconData icon, {required bool active}) {
    final scale = FontSizeProvider.instance.fontSizeScale.clamp(0.8, 1.6);
    final radius = (18 * scale).clamp(12.0, 40.0);
    final iconSize = (18 * scale).clamp(10.0, 40.0);
    final spacing = (6 * scale).clamp(4.0, 18.0);

    return Column(
      children: [
        CircleAvatar(
          radius: radius.toDouble(),
          backgroundColor: active ? const Color(0xFF2E7D32) : Colors.grey[200],
          child: Icon(
            icon,
            color: active ? Colors.white : Colors.grey[700],
            size: iconSize.toDouble(),
          ),
        ),
        SizedBox(height: spacing.toDouble()),
      ],
    );
  }

  Widget _buildProcessRow() {
    // 4 steps: person, money, timer, check
    const totalSteps = 4;
    final activeCount =
        1 + (_isConfirmed ? 1 : 0) + (_isPaid ? 1 : 0) + (_isCompleted ? 1 : 0);
    // fraction previously used for proportional progress; not needed with discrete step spacing

    final scale = FontSizeProvider.instance.fontSizeScale.clamp(0.8, 1.6);
    final radius = (18 * scale).clamp(12.0, 40.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = (constraints.maxWidth - (radius * 2)).clamp(
          0.0,
          constraints.maxWidth,
        );
        final stepSpacing =
            totalSteps > 1
                ? (availableWidth / (totalSteps - 1))
                : availableWidth;
        final progressWidth = stepSpacing * (activeCount - 1);

        return SizedBox(
          height: radius * 2 + 8,
          child: Stack(
            children: [
              // base track starting at first icon center and ending at last icon center
              Positioned(
                left: radius.toDouble(),
                right: radius.toDouble(),
                top: (radius.toDouble() + 8) / 2 - 2,
                child: Container(height: 4, color: Colors.grey[200]),
              ),
              // progress fill from first icon center
              if (progressWidth > 0)
                Positioned(
                  left: radius.toDouble(),
                  top: (radius.toDouble() + 8) / 2 - 2,
                  child: Container(
                    height: 4,
                    width: progressWidth.toDouble(),
                    color: const Color(0xFF6EB715),
                  ),
                ),
              // positioned icons
              for (var i = 0; i < totalSteps; i++)
                Positioned(
                  left:
                      (radius + stepSpacing * i).toDouble() - radius.toDouble(),
                  top: 0,
                  width: radius.toDouble() * 2,
                  child: Center(
                    child: _buildStepIcon(
                      i == 0
                          ? Icons.person
                          : i == 1
                          ? Icons.attach_money
                          : i == 2
                          ? Icons.timer
                          : Icons.check,
                      active:
                          i == 0
                              ? true
                              : (i == 1
                                  ? _isConfirmed
                                  : (i == 2 ? _isPaid : _isCompleted)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final title = job['title'] ?? 'งาน';
    final price = job['price']?.toString() ?? '0';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EB715),
        title: const Text('สถานะงาน', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'สถานะงาน',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(_currentStatusText(), style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              _buildProcessRow(),
              const Divider(height: 24),

              const Text(
                'ผู้สูงอายุ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final scale = FontSizeProvider.instance.fontSizeScale.clamp(
                    0.8,
                    1.6,
                  );
                  final avatarRadius = (28 * scale).clamp(16.0, 48.0);
                  final gap = (8 * scale).clamp(6.0, 20.0);

                  return SizedBox(
                    height: avatarRadius * 2,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder:
                          (context, idx) => CircleAvatar(
                            radius: avatarRadius.toDouble(),
                            backgroundImage: const AssetImage(
                              'images/avatar_placeholder.png',
                            ),
                          ),
                      separatorBuilder:
                          (_, __) => SizedBox(width: gap.toDouble()),
                      itemCount: 3,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'วันที่ :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(_formatDate(job['started_at']?.toString())),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'เวลา :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatTimeRange(
                        job['started_at']?.toString(),
                        job['ended_at']?.toString(),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'งานที่จ้าง',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  // 'จัดสถานที่' button removed as requested
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'รายละเอียด',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(job['description']?.toString() ?? ''),
              const SizedBox(height: 16),

              // Action area (flow)
              if (!_isConfirmed) ...[
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => setState(() => _isConfirmed = true),
                        child: const Text('ยืนยัน'),
                      ),
                    ),
                  ],
                ),
              ] else if (!_isPaid) ...[
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6EB715),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final paymentDetails = PaymentDetails(
                            jobTitle: title,
                            payment: price,
                            workType: job['work_type']?.toString() ?? '',
                            paymentMethod:
                                job['payment_method']?.toString() ?? 'card',
                            code: job['code']?.toString() ?? '',
                            totalAmount:
                                job['total_amount']?.toString() ??
                                _computeTotal(job),
                          );
                          final elderlyName =
                              job['elderly_name']?.toString() ?? '';

                          final paid = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder:
                                  (_) => PaymentPage(
                                    paymentDetails: paymentDetails,
                                    elderlyPersonName: elderlyName,
                                  ),
                            ),
                          );
                          if (paid == true) setState(() => _isPaid = true);
                        },
                        child: Text(
                          'ชำระเงิน  ฿${_computeTotal(job)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (!_isCompleted) ...[
                Row(
                  children: [
                    // After payment show a red octagon-style icon on the left (closes screen)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.report_problem,
                          color: Colors.white,
                        ),
                        tooltip: 'ปิด',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6EB715),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() => _isCompleted = true);
                        },
                        child: const Text(
                          'จบงาน',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6EB715),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReviewScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'ให้คะแนน',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ค่าจ้าง',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '฿ $price / คน',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ยอดสุทธิ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '฿ ${_computeTotal(job)}',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Text(
                'สถานที่ที่ทำงาน',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(job['location']?.toString() ?? ''),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('เปิดแผนที่'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
