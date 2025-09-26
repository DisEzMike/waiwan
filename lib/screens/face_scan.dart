import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waiwan/screens/main_screen.dart';
// removed google_mlkit_face_detection - using simple file-size heuristic for object detection

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? _cameras;
  bool _permissionGranted = false;
  bool _permissionPermanentlyDenied = false;
  // whether camera is fully ready (permission + controller initialized)
  bool get _isCameraReady =>
      _permissionGranted &&
      _controller != null &&
      _controller!.value.isInitialized;
  // no image stream; we'll consider any non-empty captured photo as an object detection

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (kIsWeb) {
        // browser will request camera access when trying to open the stream
        _permissionGranted = true;
      } else {
        final status = await Permission.camera.request();
        if (!mounted) return;
        if (status.isGranted) {
          _permissionGranted = true;
        } else if (status.isPermanentlyDenied) {
          _permissionGranted = false;
          _permissionPermanentlyDenied = true;
        }
      }

      if (_permissionGranted) {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
          final front = _cameras!.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          );
          _controller = CameraController(
            front,
            ResolutionPreset.medium,
            enableAudio: false,
          );
          _initializeControllerFuture = _controller!.initialize();
          // no image stream; we'll perform detection after capturing a photo
          await _initializeControllerFuture;
          setState(() {});
        }
      }
    } catch (e) {
      // plugin not available on this platform or camera init failed
      debugPrint('Camera init failed: $e');
      _permissionGranted = false;
      setState(() {});
    }
  }

  Future<void> _takePictureAndProceed() async {
    // capture these before any awaits to avoid using BuildContext across async gaps
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (!_permissionGranted) {
        // no permission
        messenger.showSnackBar(
          const SnackBar(content: Text('ไม่มีสิทธิ์ใช้กล้อง')),
        );
        if (_permissionPermanentlyDenied) {
          // suggest opening settings
          showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('ไม่สามารถใช้กล้องได้'),
                  content: const Text(
                    'แอปไม่มีสิทธิ์ใช้กล้อง กรุณาเปิดอนุญาตในการตั้งค่า',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () {
                        openAppSettings();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('ไปที่การตั้งค่า'),
                    ),
                  ],
                ),
          );
        }
        return;
      }

      if (_controller == null || !_controller!.value.isInitialized) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('กล้องยังไม่พร้อม ลองรอสักครู่แล้วกดอีกครั้ง'),
          ),
        );
        return;
      }
      final XFile file = await _controller!.takePicture();
      if (!mounted) return;
      // simple object detection: use file size as a heuristic for 'something present'
      try {
        final int fileSize = await file.length();
        debugPrint('Captured file size: $fileSize bytes');
        // threshold (5 KB) - adjust if needed
        if (fileSize > 5000) {
          // Navigate to main screen and remove all previous routes
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MyMainPage()),
            (route) => false,
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'ไม่พบวัตถุ — ลองยกกล้องใกล้วัตถุหรือเพิ่มแสงแล้วถ่ายใหม่',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('ประมวลผลภาพล้มเหลว: $e')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('ถ่ายรูปล้มเหลว: $e')));
    }
  }

  @override
  void dispose() {
    // no active image stream to stop
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FDEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EB715),
        title: const Text('ตรวจสอบใบหน้า'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // camera preview area with circular overlay
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_permissionGranted) ...[
                          Container(color: Colors.black12),
                          const Center(child: Text('ขออนุญาตใช้กล้อง')),
                        ] else if (_controller == null) ...[
                          Container(color: Colors.black12),
                          const Center(child: CircularProgressIndicator()),
                        ] else ...[
                          FutureBuilder<void>(
                            future: _initializeControllerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return CameraPreview(_controller!);
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ],
                        // circular overlay in center
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: Center(
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF6EB715),
                                    width: 6,
                                  ),
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          child: Text(
                            'ยกขึ้นให้อยู่ในกรอบและสว่าง',
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // confirm button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCameraReady ? _takePictureAndProceed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6EB715),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('ยืนยัน'),
                ),
              ),
            ),
            // helper hint when camera not ready
            if (!_isCameraReady)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                child: Text(
                  _permissionGranted
                      ? 'กำลังเตรียมกล้อง.. รอสักครู่แล้วกดยืนยันอีกครั้ง'
                      : 'ยังไม่ได้รับอนุญาตใช้กล้อง กดอนุญาตที่ระบบหรือแอปตั้งค่า',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}