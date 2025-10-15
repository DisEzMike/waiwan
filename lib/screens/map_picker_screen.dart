import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const MapPickerScreen({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  
  // Default location (Bangkok, Thailand)
  static const LatLng _defaultLocation = LatLng(13.7563, 100.5018);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    LatLng initialLocation = _defaultLocation;
    
    if (widget.initialLocation != null) {
      initialLocation = widget.initialLocation!;
      _selectedLocation = initialLocation;
      _selectedAddress = widget.initialAddress ?? '';
    } else {
      // Try to get current location
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          initialLocation = LatLng(position.latitude, position.longitude);
          _selectedLocation = initialLocation;
          await _updateAddressFromLocation(initialLocation);
        }
      } catch (e) {
        debugPrint('Error getting current location: $e');
        // Use default location if current location fails
        _selectedLocation = _defaultLocation;
        _selectedAddress = 'กรุงเทพมหานคร, ประเทศไทย';
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateAddressFromLocation(LatLng location) async {
    try {
      // Using Google Geocoding API for reverse geocoding
      const String apiKey = 'AIzaSyDcuOeURgjscvFaP2WN1nIT0hMNcw2-1u4';
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=${location.latitude},${location.longitude}'
          '&language=th'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        
        if (results.isNotEmpty) {
          final String formattedAddress = results[0]['formatted_address'] ?? '';
          setState(() {
            _selectedAddress = formattedAddress.isNotEmpty 
                ? formattedAddress 
                : 'ละติจูด: ${location.latitude.toStringAsFixed(6)}, ลองจิจูด: ${location.longitude.toStringAsFixed(6)}';
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    
    // Fallback to coordinates if API fails
    setState(() {
      _selectedAddress = 'ละติจูด: ${location.latitude.toStringAsFixed(6)}, '
                       'ลองจิจูด: ${location.longitude.toStringAsFixed(6)}';
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateAddressFromLocation(location);
  }

  void _onConfirm() {
    if (_selectedLocation != null) {
      Navigator.of(context).pop({
        'location': _selectedLocation,
        'address': _selectedAddress,
      });
    }
  }

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

  // Search places function using Google Places API
  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Using Google Places API Text Search
      const String apiKey = 'AIzaSyDcuOeURgjscvFaP2WN1nIT0hMNcw2-1u4'; // Your API key from AndroidManifest.xml
      
      // Use Bangkok as default center, fallback to current location if available
      String centerLocation = '13.7563,100.5018'; // Bangkok default
      
      try {
        final Position position = await _determinePosition();
        centerLocation = '${position.latitude},${position.longitude}';
      } catch (e) {
        debugPrint('Could not get current location, using Bangkok as center: $e');
        // Continue with Bangkok as center
      }
      
      final String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json'
          '?query=${Uri.encodeComponent(query)}'
          '&location=$centerLocation'
          '&radius=50000' // 50km radius
          '&language=th'
          '&key=$apiKey';

      debugPrint('Search URL: $url'); // Debug log
      
      final response = await http.get(Uri.parse(url));
      
      debugPrint('Response status: ${response.statusCode}'); // Debug log
      debugPrint('Response body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check for API errors
        if (data['status'] != 'OK') {
          debugPrint('Google Places API error: ${data['status']} - ${data['error_message'] ?? ''}');
          throw Exception('Google Places API error: ${data['status']}');
        }
        
        final List<dynamic> results = data['results'] ?? [];
        
        List<Map<String, dynamic>> searchResults = [];
        
        for (var result in results.take(5)) { // Limit to 5 results
          final geometry = result['geometry'];
          if (geometry != null && geometry['location'] != null) {
            final location = geometry['location'];
            final lat = location['lat'];
            final lng = location['lng'];
            
            searchResults.add({
              'name': result['name'] ?? 'ไม่ระบุชื่อ',
              'address': result['formatted_address'] ?? 'ไม่ระบุที่อยู่',
              'location': LatLng(lat.toDouble(), lng.toDouble()),
            });
          }
        }
        
        setState(() {
          _searchResults = searchResults;
          _isSearching = false;
        });
        
        debugPrint('Found ${searchResults.length} results'); // Debug log
      } else {
        throw Exception('Failed to search places: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      
      // Show error to user and fallback to simple search
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถค้นหาได้ กำลังใช้การค้นหาพื้นฐาน: $e')),
        );
      }
      
      // Fallback to simple coordinate-based search if API fails
      _fallbackSearch(query);
    }
  }

  // Fallback search method when API is not available
  void _fallbackSearch(String query) {
    debugPrint('Using fallback search for: $query');
    
    List<Map<String, dynamic>> results = [];
    
    // Create simple location suggestions based on query
    final queryLower = query.toLowerCase();
    
    // Common Bangkok areas
    if (queryLower.contains('สยาม') || queryLower.contains('siam')) {
      results.add({
        'name': 'สยาม',
        'address': 'พื้นที่สยาม ถ.พระราม 1 กรุงเทพฯ',
        'location': const LatLng(13.7460, 100.5348),
      });
    }
    
    if (queryLower.contains('จตุจักร') || queryLower.contains('chatuchak')) {
      results.add({
        'name': 'จตุจักร',
        'address': 'เขตจตุจักร กรุงเทพฯ',
        'location': const LatLng(13.8021, 100.5519),
      });
    }
    
    if (queryLower.contains('สนามบิน') || queryLower.contains('airport')) {
      results.add({
        'name': 'สนามบินสุวรรณภูมิ',
        'address': 'สนามบินสุวรรณภูมิ สมุทรปราการ',
        'location': const LatLng(13.6900, 100.7501),
      });
    }
    
    if (queryLower.contains('เซ็นทรัล') || queryLower.contains('central')) {
      results.add({
        'name': 'เซ็นทรัลเวิลด์',
        'address': '999/9 ถ.พระราม 1 แขวงปทุมวัน เขตปทุมวัน กรุงเทพฯ',
        'location': const LatLng(13.7472, 100.5361),
      });
    }
    
    if (queryLower.contains('บิ๊กซี') || queryLower.contains('bigc')) {
      results.add({
        'name': 'บิ๊กซี รัชดาภิเษก',
        'address': '97/11 ถ.รัชดาภิเษก แขวงดินแดง เขตดินแดง กรุงเทพฯ',
        'location': const LatLng(13.7683, 100.5434),
      });
    }
    
    // If no specific matches, create generic results around Bangkok
    if (results.isEmpty) {
      for (int i = 0; i < 3; i++) {
        final offsetLat = (i - 1) * 0.01; // Small offset for different locations
        final offsetLng = (i - 1) * 0.01;
        
        results.add({
          'name': '$query ผลลัพธ์ที่ ${i + 1}',
          'address': 'พื้นที่ใกล้เคียงกับ $query ในกรุงเทพฯ',
          'location': LatLng(
            13.7563 + offsetLat,
            100.5018 + offsetLng,
          ),
        });
      }
    }
    
    debugPrint('Fallback search found ${results.length} results');
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final location = result['location'] as LatLng;
    final address = result['address'] as String;
    
    setState(() {
      _selectedLocation = location;
      _selectedAddress = '${result['name']}, $address';
      _searchResults = [];
      _searchController.clear();
    });

    // Move camera to selected location
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16,
          ),
        ),
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        final currentLocation = LatLng(position.latitude, position.longitude);
        
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation,
                zoom: 16,
              ),
            ),
          );
        }
        
        // Optionally set as selected location
        setState(() {
          _selectedLocation = currentLocation;
        });
        await _updateAddressFromLocation(currentLocation);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณาอนุญาตการเข้าถึงตำแหน่งเพื่อใช้ฟีเจอร์นี้'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถหาตำแหน่งปัจจุบันได้'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกสถานที่'),
        backgroundColor: const Color(0xFF6EB715),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedLocation != null ? _onConfirm : null,
            child: const Text(
              'ตกลง',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาสถานที่...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show/hide clear button
                    if (value.length > 2) {
                      _searchPlaces(value);
                    } else {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                  onSubmitted: _searchPlaces,
                ),
                // Search results
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else if (_searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.red,
                          ),
                          title: Text(
                            result['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            result['address'],
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  )
                else if (_searchController.text.length > 2 && !_isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_off,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ไม่พบผลการค้นหาสำหรับ "${_searchController.text}"',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Address display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สถานที่ที่เลือก:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedAddress.isNotEmpty 
                    ? _selectedAddress 
                    : 'กรุณาแตะบนแผนที่หรือค้นหาเพื่อเลือกสถานที่',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedAddress.isNotEmpty 
                      ? Colors.black87 
                      : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Map
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? _defaultLocation,
                    zoom: 15,
                  ),
                  onTap: _onMapTap,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: _selectedLocation!,
                            infoWindow: const InfoWindow(title: 'สถานที่ที่เลือก'),
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // We'll add custom button
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),
                // Custom current location button
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          // Bottom instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ค้นหาสถานที่ด้านบนหรือแตะบนแผนที่เพื่อเลือกสถานที่',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}