import 'package:flutter/material.dart';
import '../../widgets/map/map_container.dart';
import '../../widgets/map/address_card.dart';
import '../../widgets/map/complete_job_button.dart';
import '../../widgets/map/action_buttons_row.dart';
import '../../widgets/map/job_completion_dialog.dart';
import '../../widgets/map/sos_button.dart';
import '../../widgets/map/location_button.dart';
import 'review_screen.dart';

class MapPage extends StatefulWidget {
  final String elderlyPersonName;
  final String address;

  const MapPage({
    super.key,
    required this.elderlyPersonName,
    required this.address,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EB715),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'แผนที่',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Full-screen Map Background (no edges/padding)
          Positioned.fill(
            child: MapContainer(
              onLocationPressed: () {
                // Center on user location
                print('Center on location');
              },
              onZoomIn: () {
                // Zoom in
                print('Zoom in');
              },
              onZoomOut: () {
                // Zoom out
                print('Zoom out');
              },
            ),
          ),
          
          // Bottom UI Elements
          SafeArea(
            child: Column(
              children: [
                const Spacer(), // Push content to bottom
                
                // SOS Button positioned above the address card
                SosButton(
                  onPressed: () {
                    // SOS emergency action
                    print('SOS Emergency!');
                    // Add your emergency logic here
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('ฉุกเฉิน'),
                        content: const Text('กำลังส่งสัญญาณขอความช่วยเหลือ...'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('ตกลง'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Location button below SOS button
                LocationButton(
                  onPressed: () {
                    // Center on user location
                    print('Center on location');
                  },
                ),
                
                // Address Card - no background wrapper
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: AddressCard(
                    elderlyPersonName: widget.elderlyPersonName,
                    address: widget.address,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Complete Job Button - no background wrapper
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: CompleteJobButton(
                    onPressed: _completeJob,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Action Buttons - no background wrapper
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ActionButtonsRow(
                    onCallPressed: () {
                      // Call phone
                      print('Calling...');
                    },
                    onMessagePressed: () {
                      // Send message
                      Navigator.pop(context);
                    },
                    onMorePressed: () {
                      // More options
                      print('More options...');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _completeJob() {
    JobCompletionDialog.show(
      context,
      widget.elderlyPersonName,
      () {
        Navigator.of(context).pop(); // Close dialog
        
        // Navigate to review screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReviewScreen(),
          ),
        );
      },
    );
  }

 
}
