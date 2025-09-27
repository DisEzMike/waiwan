import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/services/search_service.dart';
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
  final String token = localStorage.getItem('token') ?? '';

  @override
  void initState() {
    super.initState();
    _loadElderlyPersons();
  }

  // void _getCurrentLocation() async {
  //   Position position = await _determinePosition();
  //   setState(() {
  //     _position = position;
  //   });
  // }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
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

      Position position = await _determinePosition();
      final persons = await SearchService(
        accessToken: token,
      ).searchNearby(position.latitude, position.longitude);
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

  void _onSearch(String query) async {
    // Implement search functionality here
    try {
      setState(() {
        isLoading = true;
        elderlyPersons = [];
        errorMessage = '';
      });
      Position position = await _determinePosition();
      final persons = await SearchService(accessToken: token).searchByQuery(query, position.latitude, position.longitude);
      setState(() {
        elderlyPersons = persons;
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      print('Error searching elderly persons: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
        elderlyPersons = [];
      });
    }
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
                hintText: 'ค้นหางาน',
                onTap: () {
                  // TODO: Handle search tap
                },
                onChanged: (value) {
                  // TODO: Handle search input change
                },
                onSubmitted: _onSearch,
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
