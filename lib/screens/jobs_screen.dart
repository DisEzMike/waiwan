import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/model/job.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/screens/job_detail.dart';
import 'package:waiwan/services/job_service.dart';
import 'package:waiwan/utils/format_time.dart';
import 'package:waiwan/utils/helper.dart';
import 'package:waiwan/widgets/loading_widget.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  bool _isLoading = false;
  int _selectedIndex = 0;
  // 0 = คำขอจ้างงาน, 1 = กำลังดำเนินงาน, 2 = ประวัติการจ้าง, 3 = ยกเลิก/ปฏิเสธ

  final _jobs_completed = <MyJob>[];
  final _jobs_pending = <MyJob>[];
  final _jobs_accepted = <MyJob>[];
  final _jobs_ongoing = <MyJob>[];
  final _jobs_delined = <MyJob>[];
  final _jobs_cancelled = <MyJob>[];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void didUpdateWidget(covariant JobScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadJobs();
  }

  void _loadJobs() {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    JobService()
        .getMyJobs()
        .then((jobs) {
          final pendingJobs = <MyJob>[];
          final acceptedJobs = <MyJob>[];
          final ongoingJobs = <MyJob>[];
          final declinedJobs = <MyJob>[];
          final cancelledJobs = <MyJob>[];
          final completedJobs = <MyJob>[];
          debugPrint('Jobs loaded: ${jobs.length}');
          for (var job in jobs) {
            if (job.status == 'proposed') {
              pendingJobs.add(job);
            } else if (job.status == 'accepted' ||
                job.status == 'payment_pending') {
              acceptedJobs.add(job);
            } else if (job.status == 'in_progress') {
              ongoingJobs.add(job);
            } else if (job.status == 'completed') {
              completedJobs.add(job);
            } else if (job.status == 'cancelled') {
              cancelledJobs.add(job);
            }

            setState(() {
              _jobs_completed.clear();
              _jobs_completed.addAll(completedJobs);
              _jobs_accepted.clear();
              _jobs_accepted.addAll(acceptedJobs);
              _jobs_pending.clear();
              _jobs_pending.addAll(pendingJobs);
              _jobs_delined.clear();
              _jobs_delined.addAll(declinedJobs);
              _jobs_cancelled.clear();
              _jobs_cancelled.addAll(cancelledJobs);
              _jobs_ongoing.clear();
              _jobs_ongoing.addAll(ongoingJobs);
              _isLoading = false;
            });
          }
        })
        .catchError((e) {
          debugPrint('eee : ${e.toString()}');
          showErrorSnackBar(context, e.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return _isLoading
            ? LoadingWidget()
            : RefreshIndicator(
              onRefresh: () async {
                _loadJobs();
              },
              child: Column(
                children: [
                  // ปุ่มแท็บใต้ Top App Bar
                  _buildTabButtons(fontProvider),
                  // เนื้อหาตามแท็บที่เลือก
                  Expanded(child: _buildTabContent(fontProvider)),
                ],
              ),
            );
      },
    );
  }

  Widget _buildTabButtons(FontSizeProvider fontProvider) {
    final tabs = [
      'เสนอ / รอยืนยัน',
      'ยืนยันแล้ว / รอชำระ',
      'กำลังดำเนินการ',
      'เสร็จสิ้น',
      'ยกเลิก',
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      height: fontProvider.getScaledFontSize(50), // Make height responsive
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // เลื่อนแนวนอน
        child: Row(
          children:
              tabs.asMap().entries.map((entry) {
                int index = entry.key;
                String title = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    right:
                        index < tabs.length - 1
                            ? 8.0
                            : 0, // เว้นระยะระหว่างปุ่ม
                  ),
                  child: _buildTabButton(index, title, fontProvider),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabButton(
    int index,
    String title,
    FontSizeProvider fontProvider,
  ) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: fontProvider.getScaledFontSize(12),
          horizontal: fontProvider.getScaledFontSize(20),
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontProvider.getScaledFontSize(14),
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(FontSizeProvider fontProvider) {
    switch (_selectedIndex) {
      case 0:
        return _buildJobRequestsContent(fontProvider);
      case 1:
        return _buildAcceptedJobsContent();
      case 2:
        return _buildOngoingJobsContent();
      case 3:
        return _buildJobHistoryContent();
      case 4:
        return _buildCancelledJobsContent();
      default:
        return _buildJobRequestsContent(fontProvider);
    }
  }

  Widget _buildJobCard(MyJob job, IconData icon) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return GestureDetector(
          onTap: () async {
            debugPrint('Card tapped: ${job.id}'); // Debug print
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(jobId: job.id),
              ),
            );

            // ถ้ากดปุ่ม "ไม่สนใจ" จะได้ result = 3
            if (result == 3) {
              setState(() {
                _selectedIndex = 3; // เปลี่ยนไปที่ tab ยกเลิก/ปฏิเสธ
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // ไอคอนกระเป๋าสีเขียว
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  // ข้อมูลงาน
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // วันที่และเวลา
                        Text(
                          start2EndDateTime(job.startedAt, job.endedAt),
                          style: TextStyle(
                            fontSize: fontProvider.getScaledFontSize(14),
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: fontProvider.getScaledFontSize(14),
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // การยืนยัน
                        Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                'ยืนยันแล้ว',
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(14),
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 3,
                              child: Text(
                                "${job.AcceptedSeniorsCount} / ${job.maxSeniors} คน",
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(14),
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // ราคาต่อคน
                        Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                'ค่าจ้าง',
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(14),
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 3,
                              child: Text(
                                "฿${job.price} / คน",
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(14),
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // ค่าจ้าง
                        if (job.AcceptedSeniorsCount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  'รวม ฿${(job.price * job.AcceptedSeniorsCount).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: fontProvider.getScaledFontSize(
                                      16,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobRequestsContent(FontSizeProvider fontProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child:
          _jobs_pending.isNotEmpty
              ? Column(
                children: [
                  Column(
                    children:
                        _jobs_pending.map((job) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildJobCard(job, Icons.mail),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              )
              : _buildNodataContent(
                Icons.mail_outline,
                'ไม่มีคำขอจ้างงาน',
                'คุณยังไม่มีคำขอจ้างงานในขณะนี้',
              ),
    );
  }

  Widget _buildAcceptedJobsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child:
          _jobs_accepted.isNotEmpty
              ? Column(
                children:
                    _jobs_accepted.map((job) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildJobCard(
                          job,
                          Icons.access_time_filled_outlined,
                        ),
                      );
                    }).toList(),
              )
              : _buildNodataContent(
                Icons.access_time,
                'ไม่มีงานที่รอเริ่ม',
                'คุณยังไม่มีงานที่รอเริ่มในขณะนี้',
              ),
    );
  }

  Widget _buildOngoingJobsContent() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:
              _jobs_ongoing.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children:
                          _jobs_ongoing.map((job) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildJobCard(job, Icons.work),
                            );
                          }).toList(),
                    ),
                  )
                  : _buildNodataContent(
                    Icons.work,
                    'ไม่มีงานที่กำลังดำเนินการ',
                    'คุณยังไม่มีงานที่กำลังดำเนินการในขณะนี้',
                  ),
        );
      },
    );
  }

  Widget _buildJobHistoryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child:
          _jobs_completed.isNotEmpty
              ? Column(
                children: [
                  Column(
                    children:
                        _jobs_completed.map((job) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildJobCard(job, Icons.history),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              )
              : _buildNodataContent(
                Icons.history,
                'ไม่มีประวัติการจ้างงาน',
                'คุณยังไม่มีประวัติการจ้างงานในขณะนี้',
              ),
    );
  }

  Widget _buildCancelledJobsContent() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:
              _jobs_cancelled.isNotEmpty
                  ? Column(
                    children:
                        _jobs_cancelled.map((job) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildJobCard(job, Icons.cancel),
                          );
                        }).toList(),
                  )
                  : _buildNodataContent(
                    Icons.cancel_outlined,
                    'ไม่มีงานที่ยกเลิก',
                    'คุณยังไม่มีงานที่ยกเลิกในขณะนี้',
                  ),
        );
      },
    );
  }

  Widget _buildNodataContent(IconData icon, String title, String description) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: fontProvider.getScaledFontSize(64),
                color: Colors.grey,
              ),
              SizedBox(height: fontProvider.getScaledFontSize(16)),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontProvider.getScaledFontSize(18),
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: fontProvider.getScaledFontSize(8)),
              Text(
                description,
                style: TextStyle(
                  fontSize: fontProvider.getScaledFontSize(14),
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
