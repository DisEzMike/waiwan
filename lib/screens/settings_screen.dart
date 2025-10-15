import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
      backgroundColor: const Color(0xFFF3FDEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EB715),
        title: Text(
          'การตั้งค่า',
          style: TextStyle(
            fontSize: fontProvider.getScaledFontSize(20),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Font Size Settings Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Row(
                          children: [
                            Icon(
                              Icons.text_fields,
                              color: const Color(0xFF6EB715),
                              size: fontProvider.getScaledFontSize(24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'ขนาดตัวอักษร',
                              style: TextStyle(
                                fontSize: fontProvider.getScaledFontSize(18),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Current Font Size Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3FDEC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ขนาดปัจจุบัน:',
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(16),
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                fontProvider.fontSizeDescription,
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6EB715),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Font Size Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Decrease Button
                            _buildFontSizeButton(
                              context,
                              fontProvider,
                              icon: Icons.remove,
                              label: 'เล็กลง',
                              onPressed: fontProvider.fontSizeScale > 0.8
                                  ? fontProvider.decreaseFontSize
                                  : null,
                            ),
                            
                            // Reset Button
                            _buildFontSizeButton(
                              context,
                              fontProvider,
                              icon: Icons.refresh,
                              label: 'รีเซ็ต',
                              onPressed: fontProvider.resetFontSize,
                            ),
                            
                            // Increase Button
                            _buildFontSizeButton(
                              context,
                              fontProvider,
                              icon: Icons.add,
                              label: 'ใหญ่ขึ้น',
                              onPressed: fontProvider.fontSizeScale < 1.6
                                  ? fontProvider.increaseFontSize
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Preview Text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ตัวอย่างข้อความ',
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'นี่คือตัวอย่างข้อความที่จะแสดงในแอพพลิเคชัน คุณสามารถปรับขนาดตัวอักษรได้ตามต้องการ',
                                style: TextStyle(
                                  fontSize: fontProvider.getScaledFontSize(16),
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Additional Settings (Future Features)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: const Color(0xFF6EB715),
                              size: fontProvider.getScaledFontSize(24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'การตั้งค่าอื่นๆ',
                              style: TextStyle(
                                fontSize: fontProvider.getScaledFontSize(18),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'การตั้งค่าเพิ่มเติมจะมีในอนาคต',
                          style: TextStyle(
                            fontSize: fontProvider.getScaledFontSize(16),
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildFontSizeButton(
    BuildContext context,
    FontSizeProvider fontProvider, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null
                ? const Color(0xFF6EB715)
                : Colors.grey.shade300,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            elevation: onPressed != null ? 2 : 0,
          ),
          child: Icon(
            icon,
            size: fontProvider.getScaledFontSize(24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: fontProvider.getScaledFontSize(12),
            color: onPressed != null ? Colors.black87 : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}