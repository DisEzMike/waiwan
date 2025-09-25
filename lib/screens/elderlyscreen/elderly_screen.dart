import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'elderlypersonclass.dart';
import 'card.dart';
import 'elderly_profile.dart';

class ElderlyScreen extends StatefulWidget {
  const ElderlyScreen({super.key});

  @override
  State<ElderlyScreen> createState() => _ElderlyScreenState();
}

class _ElderlyScreenState extends State<ElderlyScreen> {
  List<ElderlyPerson> elderlyPersons = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadElderlyPersons();
  }

  Future<void> _loadElderlyPersons({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        setState(() {
          isRefreshing = true;
          errorMessage = '';
        });
      } else {
        setState(() {
          isLoading = true;
          errorMessage = '';
        });
      }

      final persons = await ApiService.getElderlyPersons();
      
      if (mounted) {
        setState(() {
          elderlyPersons = persons;
          isLoading = false;
          isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
          errorMessage = e.toString();
          // Keep existing data if available, otherwise show empty list
          if (elderlyPersons.isEmpty) {
            elderlyPersons = [];
          }
        });
      }
      print('Error loading elderly persons: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadElderlyPersons(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SearchBar(
                  hintText: 'พบกล่อง',
                  leading: const Icon(Icons.search, size: 30),
                  constraints: const BoxConstraints(
                    maxHeight: 60,
                    minHeight: 50,
                  ),
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 24.0),
                  ),
                  hintStyle: WidgetStatePropertyAll<TextStyle>(
                    TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  elevation: const WidgetStatePropertyAll<double>(1.0),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.star),
                      label: const Text('คะแนนของฉัน'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: Image.asset('assets/images/p.png', width: 24, height: 24),
                      label: const Text(
                        '1000 คะแนน',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildElderlyPersonsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElderlyPersonsGrid() {
    // Show loading indicator for initial load
    if (isLoading && !isRefreshing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show loading indicator during refresh when list is empty
    if (isRefreshing && elderlyPersons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off,
                size: 64,
                color: Color(0xFF6EB715),
              ),
              const SizedBox(height: 16),
              Text(
                'ไม่สามารถเชื่อมต่อได้',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้\nกรุณาตรวจสอบการเชื่อมต่อและลองใหม่',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadElderlyPersons(isRefresh: false),
                icon: const Icon(Icons.refresh),
                label: const Text('ลองเชื่อมต่อใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF6EB715),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Don't show "no data found" message, just show empty grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: elderlyPersons.length,
      itemBuilder: (context, index) {
        final person = elderlyPersons[index];
        return ElderlyPersonCard(
          person: person,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ElderlyProfilePage(person: person),
              ),
            );
          },
        );
      },
    );
  }
}