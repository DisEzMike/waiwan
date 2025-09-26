import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../model/elderly_person.dart';
import 'elderly_profile.dart';
import '../../widgets/elderly_main/custom_search_bar.dart';
import '../../widgets/elderly_main/points_buttons.dart';
import '../../widgets/elderly_main/elderly_persons_grid.dart';

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
              CustomSearchBar(
                hintText: 'พบกล่อง',
                onTap: () {
                  // TODO: Handle search tap
                },
              ),
              const SizedBox(height: 16),
              PointsButtons(
                onCouponTap: () {
                  // TODO: Handle coupon tap
                },
                onPointsTap: () {
                  // TODO: Handle points tap
                },
                pointsText: '100 คะแนน',
              ),
              const SizedBox(height: 16),
              ElderlyPersonsGrid(
                elderlyPersons: elderlyPersons,
                isLoading: isLoading,
                isRefreshing: isRefreshing,
                errorMessage: errorMessage,
                onRetry: () => _loadElderlyPersons(isRefresh: false),
                onPersonTap: (person) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ElderlyProfilePage(person: person),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}