import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waiwan/model/elderly_person.dart';
import 'package:waiwan/model/group_job.dart';
import 'group_job_detail.dart';
import 'package:waiwan/services/search_service.dart';
import '../widgets/elderly_main/elderly_persons_grid.dart';

class GroupSearchResultsPage extends StatefulWidget {
  final String query;
  final GroupJobDetails? job;

  const GroupSearchResultsPage({Key? key, required this.query, this.job})
    : super(key: key);

  @override
  State<GroupSearchResultsPage> createState() => _GroupSearchResultsPageState();
}

class _GroupSearchResultsPageState extends State<GroupSearchResultsPage> {
  List<ElderlyPerson> results = [];
  final Set<String> selectedIds = {};
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  Future<void> _runSearch() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final pos = await Geolocator.getCurrentPosition();
      final svc = SearchService(accessToken: '');
      final list = await svc.searchByQuery(
        widget.query,
        pos.latitude,
        pos.longitude,
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
    setState(() {
      if (selectedIds.contains(id))
        selectedIds.remove(id);
      else
        selectedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหา'),
        backgroundColor: const Color(0xFF6EB715),
      ),
      body: SafeArea(
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      if (error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      Expanded(
                        child: ElderlyPersonsGrid(
                          elderlyPersons: results,
                          isLoading: loading,
                          isRefreshing: false,
                          errorMessage: '',
                          onRetry: _runSearch,
                          onPersonTap: (p) {
                            // open profile page if needed - for now toggle selection
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF1FA2FF),
              onPressed: () {
                // Navigate to group details page with selected seniors and job data
                final selected =
                    results.where((r) => selectedIds.contains(r.id)).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => GroupJobDetailPage(
                          job:
                              widget.job ??
                              GroupJobDetails(
                                title: widget.query,
                                description: '',
                                dateRange: '',
                                timeFrom: '',
                                timeTo: '',
                                location: '',
                                maxSeniors: 0,
                                pricePerPerson: 0,
                              ),
                          selectedSeniors: selected,
                        ),
                  ),
                );
              },
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
