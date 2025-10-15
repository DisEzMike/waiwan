import 'package:flutter/material.dart';
import 'package:waiwan/model/job.dart';
import 'package:waiwan/screens/elderlyscreen/chat.dart';
import 'package:waiwan/screens/elderlyscreen/payment_page.dart';
import 'package:waiwan/screens/elderlyscreen/review_screen.dart';
import 'package:waiwan/model/chat_message.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/services/job_service.dart';
import 'package:waiwan/utils/config.dart';
import 'package:waiwan/utils/font_size_helper.dart';
import 'package:waiwan/utils/format_time.dart';
import 'package:waiwan/utils/helper.dart';
import 'package:waiwan/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = false;
  bool _isConfirmed = false;
  bool _isPaid = false;
  bool _isCompleted = false;
  late JobDetail _job;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadJob();
  }

  void _loadJob() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final job = await JobService().getJobById(widget.jobId);
      setState(() {
        _job = job;
        _isLoading = false;

        if (job.status == "in_progress") {
          _isConfirmed = true;
          _isPaid = true;
        } else if (job.status == "completed") {
          _isConfirmed = true;
          _isPaid = true;
          _isCompleted = true;
        } else if (job.status == "accepted") {
          _isConfirmed = true;
        }
      });
    } catch (e) {
      debugPrint('Error loading job: $e');
      showErrorSnackBar(context, 'เกิดข้อผิดพลาดในการโหลดข้อมูลงาน');
    }
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
    // increase base multipliers to make icons larger
    final radius = (24 * scale).clamp(14.0, 48.0);
    final iconSize = (20 * scale).clamp(12.0, 44.0);
    final spacing = (8 * scale).clamp(6.0, 20.0);

    return Column(
      children: [
        CircleAvatar(
          radius: radius.toDouble(),
          backgroundColor: active ? const Color(0xFF6EB715) : Colors.grey[200],
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
    // match the radius used in _buildStepIcon (base 24)
    final radius = (24 * scale).clamp(14.0, 48.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // reduce available width used for spacing so icons are closer together
        final spacingFactor =
            0.78; // <1.0 brings icons closer; increase toward 1.0 to spread
        final availableWidth = (((constraints.maxWidth) * spacingFactor)).clamp(
          0.0,
          constraints.maxWidth,
        );
        final stepSpacing =
            totalSteps > 1
                ? (availableWidth / (totalSteps - 1))
                : availableWidth;
        final progressWidth = stepSpacing * (activeCount - 1);

        // compute total track width (distance between first and last centers)
        final trackWidth = (stepSpacing * (totalSteps - 1)).toDouble();
        // center the track horizontally inside available constraints
        final startLeft =
            ((constraints.maxWidth - trackWidth) / 2)
                .clamp(0.0, constraints.maxWidth)
                .toDouble();

        // track height and vertical position: center on icon centers
        final trackHeight = 2.0;
        final trackTop = radius.toDouble() - (trackHeight / 2);

        return SizedBox(
          height: radius * 2 + 8,
          child: Stack(
            children: [
              // base track starting at first icon center and ending at last icon center
              Positioned(
                left: startLeft,
                top: trackTop,
                width: trackWidth,
                child: Container(
                  height: trackHeight,
                  color: const Color(0xFFDDDDDD),
                ),
              ),
              // progress fill from first icon center (clamped to not exceed track width)
              if (progressWidth > 0)
                Positioned(
                  left: startLeft,
                  top: trackTop,
                  width:
                      (progressWidth > trackWidth ? trackWidth : progressWidth)
                          .toDouble(),
                  child: Container(
                    height: trackHeight,
                    color: const Color(0xFF6EB715),
                  ),
                ),
              // positioned icons
              for (var i = 0; i < totalSteps; i++)
                Positioned(
                  left: (startLeft + stepSpacing * i) - radius.toDouble(),
                  top: 0,
                  width: radius.toDouble() * 2,
                  child: Center(
                    child: _buildStepIcon(
                      i == 0
                          ? Icons.person
                          : i == 1
                          ? Icons.attach_money
                          : i == 2
                          ? Icons.laptop
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

  Widget _buildChatButton(String chatRoomId) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        minimumSize: const Size.fromHeight(48),
      ),
      onPressed: () {
        // Navigate to chat screen with job context
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatroomId: chatRoomId, jobId: _job.id),
          ),
        );
      },
      icon: const Icon(Icons.chat),
      label: Text(
        'แชทกับผู้สูงอายุ',
        style: FontSizeHelper.createTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    final lat = _job.location['lat'];
    final lng = _job.location['lng'];

    if (lat != null && lng != null) {
      try {
        // ลองใช้ Google Maps URL ก่อน
        final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
        
        // ใช้ launchUrl โดยตรงโดยไม่ตรวจสอบ canLaunchUrl ก่อน
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Google Maps URL failed: $e');
        
        try {
          // Fallback 1: ลอง geo URI
          final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
          await launchUrl(geoUrl);
        } catch (e2) {
          debugPrint('Geo URL failed: $e2');
          
          try {
            // Fallback 2: ลอง browser URL
            final browserUrl = Uri.parse('https://maps.google.com/?q=$lat,$lng');
            await launchUrl(
              browserUrl,
              mode: LaunchMode.externalApplication,
            );
          } catch (e3) {
            debugPrint('Browser URL failed: $e3');
            
            // แสดง error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ไม่สามารถเปิดแผนที่ได้ กรุณาตรวจสอบการติดตั้ง Google Maps'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบข้อมูลตำแหน่งสถานที่'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingWidget()
        : Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF6EB715),
            title: Text(
              'สถานะงาน',
              style: FontSizeHelper.createTextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
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
                  // title removed (AppBar already shows page title)

                  // Combined single card: status + process + elderly + date/time + job details + actions
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // STATUS / PROCESS / ELDERLY / DATE-TIME (previously first card)
                        Text(
                          _currentStatusText(),
                          style: FontSizeHelper.createTextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildProcessRow(),
                        const SizedBox(height: 12),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFBBBBBB),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ผู้สูงอายุ',
                          style: FontSizeHelper.createTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final scale = FontSizeProvider
                                .instance
                                .fontSizeScale
                                .clamp(0.8, 1.6);
                            final avatarRadius = (28 * scale).clamp(16.0, 48.0);
                            final gap = (8 * scale).clamp(6.0, 20.0);

                            return SizedBox(
                              height:
                                  (FontSizeProvider.instance.getScaledFontSize(
                                                avatarRadius,
                                              ) *
                                              2 +
                                          40)
                                      .toDouble(), // Increased height for text
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _job.applications.length,
                                separatorBuilder:
                                    (context, index) =>
                                        SizedBox(width: gap.toDouble()),
                                itemBuilder: (context, index) {
                                  final senior = _job.applications[index];
                                  final imageUrl =
                                      senior['image_url'] != null
                                          ? API_URL + senior['image_url']
                                          : 'https://placehold.co/600x400.png';

                                  // Status text logic (currently using icons instead)
                                  // final String status =
                                  //     senior['status'] != null
                                  //         ? senior['status'] == "pending"
                                  //             ? "รอการยืนยัน"
                                  //             : senior['status'] == "accepted"
                                  //             ? "ยืนยันแล้ว"
                                  //             : senior['status'] == "declined"
                                  //             ? "ปฏิเสธ"
                                  //             : "ไม่ระบุสถานะ"
                                  //         : "ไม่ระบุสถานะ";

                                  final statusIcon =
                                      senior['status'] != null
                                          ? senior['status'] == "pending"
                                              ? Icons.hourglass_top
                                              : senior['status'] == "accepted"
                                              ? Icons.check_circle
                                              : senior['status'] == "declined"
                                              ? Icons.cancel
                                              : Icons.help_outline
                                          : Icons.help_outline;

                                  return SizedBox(
                                    width:
                                        (avatarRadius * 2 + 16)
                                            .toDouble(), // Fixed width to prevent overflow
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: avatarRadius.toDouble(),
                                          backgroundImage: NetworkImage(
                                            imageUrl,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Flexible(
                                        //   child: Text(
                                        //     status,
                                        //     textAlign: TextAlign.center,
                                        //     overflow: TextOverflow.ellipsis,
                                        //     maxLines: 2,
                                        //     style:
                                        //         FontSizeHelper.createTextStyle(
                                        //           fontSize: 12,
                                        //         ),
                                        //   ),
                                        Flexible(
                                          child: Icon(
                                            statusIcon,
                                            color:
                                                senior['status'] == "accepted"
                                                    ? Colors.green
                                                    : senior['status'] ==
                                                        "declined"
                                                    ? Colors.red
                                                    : Colors.orange,
                                            size: FontSizeProvider.instance
                                                .getScaledFontSize(16),
                                          ),
                                        ),
                                        // const SizedBox(height: 2),
                                        Flexible(
                                          child: Text(
                                            senior['senior_name'] ??
                                                'ไม่ระบุชื่อ',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style:
                                                FontSizeHelper.createTextStyle(
                                                  fontSize: (12 * scale).clamp(
                                                    8.0,
                                                    16.0,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFBBBBBB),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'วันที่ :',
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                start2EndDateTime(
                                  _job.startedAt,
                                  _job.endedAt,
                                ).split(",")[0],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'เวลา :',
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                start2EndDateTime(
                                  _job.startedAt,
                                  _job.endedAt,
                                ).split(",")[1],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // JOB DETAILS / ACTIONS / PAYMENT / LOCATION (previously second card)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'งานที่จ้าง',
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _job.title,
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'รายละเอียดงาน',
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _job.description,
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 12),
                        // Action area (flow)
                        if (_job.status == "accepted" && !_isPaid) ...[
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 18,
                                  ),
                                  minimumSize: const Size(56, 48),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6EB715),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  onPressed: () async {
                                    final paymentDetails = PaymentDetails(
                                      jobTitle: _job.title,
                                      payment: _job.price.toString(),
                                      workType: _job.workType,
                                      paymentMethod: 'card',
                                      code: '3dsf4fgdgsd',
                                      totalAmount:
                                          (_job.price *
                                                  _job.acceptedSeniors.length)
                                              .toString(),
                                    );
                                    final elderlyName = '';

                                    final paid = await Navigator.of(
                                      context,
                                    ).push<bool>(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => PaymentPage(
                                              paymentDetails: paymentDetails,
                                              elderlyPersonName: elderlyName,
                                            ),
                                      ),
                                    );
                                    if (paid == true)
                                      setState(() => _isPaid = true);
                                  },
                                  child: Text(
                                    'ชำระเงิน  ฿${_job.price * _job.acceptedSeniors.length}',
                                    style: FontSizeHelper.createTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_job.chatRoom != null &&
                              _job.chatRoom?['id'] != null)
                            _buildChatButton(_job.chatRoom?['id'] ?? ""),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'กรุณาชำระเงินก่อนวันเริ่มงานอย่างน้อย 1 วัน',
                                  style: FontSizeHelper.createTextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (_job.status == "accepted" &&
                            !_isCompleted) ...[
                          Row(
                            children: [
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  onPressed: () {
                                    setState(() => _isCompleted = true);
                                  },
                                  child: Text(
                                    'จบงาน',
                                    style: FontSizeHelper.createTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_job.chatRoom != null &&
                              _job.chatRoom?['id'] != null)
                            _buildChatButton(_job.chatRoom?['id'] ?? ""),
                        ] else ...[
                          if (_job.status != "proposed" && _isCompleted)
                            Row(
                              children: [
                                const SizedBox(width: 4),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6EB715),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      minimumSize: const Size.fromHeight(52),
                                    ),
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const ReviewScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'ให้คะแนน',
                                      style: FontSizeHelper.createTextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFBBBBBB),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ค่าจ้าง',
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '฿${_job.price} / คน',
                              style: FontSizeHelper.createTextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ยอดสุทธิ',
                                style: FontSizeHelper.createTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '฿${_job.price * _job.acceptedSeniors.length}',
                              style: FontSizeHelper.createTextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'สถานที่ทำงาน',
                          style: FontSizeHelper.createTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _job.location['address'].toString(),
                          style: FontSizeHelper.createTextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'หมายเหตุ',
                          style: FontSizeHelper.createTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _job.location['note'].toString(),
                          style: FontSizeHelper.createTextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.location_on_outlined),
                          label: const Text('เปิดแผนที่'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
  }
}
