import 'package:flutter/material.dart';
import 'package:waiwan/model/elderly_person.dart';
import 'package:waiwan/model/job.dart';
import 'package:waiwan/screens/job_detail.dart';
import 'package:waiwan/screens/main_screen.dart';
import 'package:waiwan/services/job_service.dart';
import 'package:waiwan/services/search_service.dart';
import 'package:waiwan/utils/helper.dart';
import 'package:waiwan/widgets/elderly_main/elderly_persons_grid.dart';
import 'package:waiwan/widgets/loading_widget.dart';

class GroupSearchResultsPage extends StatefulWidget {
  final MyJob job;

  const GroupSearchResultsPage({Key? key, required this.job}) : super(key: key);

  @override
  State<GroupSearchResultsPage> createState() => _GroupSearchResultsPageState();
}

class _GroupSearchResultsPageState extends State<GroupSearchResultsPage> {
  List<ElderlyPerson> results = [];
  bool loading = false;
  String error = '';
  Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  @override
  void dispose() {
    // Any cleanup if needed
    super.dispose();
  }

  Future<void> _runSearch() async {
    if (!mounted) return;
    
    setState(() {
      loading = true;
      error = '';
    });

    final query = "${widget.job.title} ${widget.job.description}";

    try {
      // final pos = await Geolocator.getCurrentPosition();
      final svc = SearchService();
      final list = await svc.searchByQuery(
        query,
        widget.job.location['lat'],
        widget.job.location['lng'],
      );
      if (mounted) {
        setState(() {
          results = list;
          loading = false;
        });
      }
    } catch (e) {
      // fallback to sample data for offline/testing
      final sample = List.generate(4, (i) {
        return ElderlyPerson(
          id: 'sample_$i',
          displayName: i == 0 ? 'นายบางมี' : 'นายสมชาย',
          profile: SeniorProfile(
            id: 'p_$i',
            firstName: 'ชื่อ$i',
            lastName: 'นามสกุล$i',
            idCard: '',
            iDaddress: '',
            currentAddress: 'ที่อยู่ตัวอย่าง',
            chronicDiseases: '',
            contactPerson: '',
            contactPhone: '',
            phone: '08123456',
            gender: 'ชาย',
            imageUrl: 'https://placehold.co/300x300.png',
          ),
          ability: SeniorAbility(
            id: 'a_$i',
            type: 'รับคิว',
            workExperience: 'มีประสบการณ์',
            otherAbility: i == 0 ? 'รับคิว' : 'งานบ้าน',
            vehicle: false,
            offsiteWork: true,
          ),
        );
      });
      if (mounted) {
        setState(() {
          results = sample;
          loading = false;
          error = 'Offline: sample data loaded';
        });
      }
    }
  }

  void _toggle(String id) {
    if (!mounted) return;
    
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else if (selectedIds.length < widget.job.maxSeniors) {
        selectedIds.add(id);
      }
    });
  }

  void _sendInvites() async {
    // Implement sending invites to selected seniors
    // For now, just print the selected IDs
    try {
      for (var id in selectedIds) {
        print('Inviting senior ID: $id to job ID: ${widget.job.id}');
        final payload = {
          'senior_id': id,
          'message': 'คุณได้รับเชิญให้เข้าร่วมงาน ${widget.job.title}',
        };
        await JobService().inviteSenior(widget.job.id, payload);
      }

      if (mounted) {
        showSuccessSnackBar(context, 'ส่งคำเชิญเรียบร้อยแล้ว');
        setState(() {
          selectedIds.clear();
        });

        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyMainPage(initialIndex: 2,)),
          (route) => false,
        );
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailScreen(jobId: widget.job.id)),
          );
        }
      }
    } catch (e) {
      print('Error sending invites: $e');
      if (mounted) {
        showErrorSnackBar(context, e.toString());
      }
    }

    // JobService().inviteSenior(widget.job.id, payload)
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'ไม่พบผู้สูงอายุ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองปรับเปลี่ยนเงื่อนไขการค้นหา',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _runSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('ค้นหาใหม่'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหา'),
        backgroundColor: const Color(0xFF6EB715),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading ? null : _runSearch,
            tooltip: 'รีเฟรช',
          ),
        ],
      ),
      body: SafeArea(
        child:
            loading
                ? LoadingWidget()
                : RefreshIndicator(
                  onRefresh: _runSearch,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        if (error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    error.contains('Offline')
                                        ? Colors.orange[50]
                                        : Colors.red[50],
                                border: Border.all(
                                  color:
                                      error.contains('Offline')
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    error.contains('Offline')
                                        ? Icons.wifi_off
                                        : Icons.error_outline,
                                    color:
                                        error.contains('Offline')
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: TextStyle(
                                        color:
                                            error.contains('Offline')
                                                ? Colors.orange[800]
                                                : Colors.red[800],
                                      ),
                                    ),
                                  ),
                                  if (!loading)
                                    TextButton(
                                      onPressed: _runSearch,
                                      child: const Text('ลองใหม่'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        // Summary card
                        Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'งาน: ${widget.job.title}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'พบผู้สูงอายุ ${results.length} คน',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'เลือกแล้ว ${selectedIds.length}/${widget.job.maxSeniors} คน',
                                      style: TextStyle(
                                        color:
                                            selectedIds.length ==
                                                    widget.job.maxSeniors
                                                ? Colors.green
                                                : Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                              results.isEmpty
                                  ? _buildEmptyState()
                                  : ElderlyPersonsGrid(
                                    elderlyPersons: results,
                                    isLoading: loading,
                                    isRefreshing: false,
                                    errorMessage: '',
                                    onRetry: _runSearch,
                                    onPersonTap: (p) {
                                      _toggle(p.id);
                                    },
                                    selectedIds: selectedIds,
                                    onAdd: (p) => _toggle(p.id),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF1FA2FF),
              onPressed: () => selectedIds.isEmpty ? null : _sendInvites(),
              child: const Icon(Icons.group),
            ),
          ),
          if (selectedIds.isNotEmpty)
            Positioned(
              bottom: 60,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${selectedIds.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
