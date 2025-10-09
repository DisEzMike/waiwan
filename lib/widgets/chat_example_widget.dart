import 'package:flutter/material.dart';
import '../model/chat_room.dart';
import '../screens/chat_screen.dart';
import '../screens/chat_rooms_screen.dart';

// ตัวอย่างการสร้าง chat room และเปิด chat screen
class ChatExampleWidget extends StatelessWidget {
  const ChatExampleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตัวอย่างการใช้งาน WebSocket Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'WebSocket Chat System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // ปุ่มเปิดหน้ารายการแชท
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatRoomsScreen(),
                  ),
                );
              },
              child: const Text('รายการแชททั้งหมด'),
            ),
            
            const SizedBox(height: 16),
            
            // ปุ่มสร้างตัวอย่าง chat room
            ElevatedButton(
              onPressed: () => _openExampleChat(context),
              child: const Text('ตัวอย่างแชทห้อง'),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'ฟีเจอร์ที่รองรับ:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• การส่งข้อความแบบ Real-time'),
                Text('• การแสดงสถานะออนไลน์/ออฟไลน์'),
                Text('• Typing indicator'),
                Text('• การเชื่อมต่อ WebSocket อัตโนมัติ'),
                Text('• การเชื่อมต่อใหม่เมื่อขาดการเชื่อมต่อ'),
                Text('• การส่งข้อความแบบ Payment'),
                Text('• การแสดงผลข้อความตามเวลา'),
                Text('• การจัดเก็บข้อมูลใน Local Storage'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'การตั้งค่า WebSocket:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('URL: ws://localhost:8000/chat/ws/{room_id}'),
                  Text('Authentication: JWT Token'),
                  Text('Format: JSON Messages'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openExampleChat(BuildContext context) {
    // สร้างตัวอย่าง ChatRoom
    final exampleChatRoom = ChatRoom(
      id: 'example_room_1',
      jobId: 'job_123',
      jobTitle: 'ตัวอย่างงานดูแลผู้สูงอายุ',
      userId: 'user_1',
      userName: 'ผู้ใช้ทดสอบ',
      seniorId: 'senior_1',
      seniorName: 'คุณยาย สมหวัง',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
      lastMessageContent: 'สวัสดีครับ ผมสนใจงานนี้',
      unreadCount: 2,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoom: exampleChatRoom),
      ),
    );
  }
}