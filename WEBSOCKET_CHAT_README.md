# WebSocket Chat System for Flutter

ระบบแชทแบบ Real-time สำหรับแอป Waiwan ที่ใช้ WebSocket เชื่อมต่อกับ FastAPI Backend

## Features

- ✅ Real-time messaging
- ✅ Typing indicators
- ✅ Online/Offline status
- ✅ Auto-reconnection
- ✅ Message persistence
- ✅ Payment message support
- ✅ File upload support
- ✅ JWT Authentication
- ✅ Error handling
- ✅ Connection status

## Installation

### 1. Dependencies

เพิ่ม dependencies ใน `pubspec.yaml`:

```yaml
dependencies:
  web_socket_channel: ^3.0.0
  shared_preferences: ^2.3.2
  provider: ^6.1.5+1
```

### 2. Setup Providers

เพิ่ม `ChatProvider` ใน `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    // ... other providers
  ],
  child: MyApp(),
)
```

## Usage

### 1. Basic Chat Implementation

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../model/chat_room.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  
  const ChatScreen({required this.chatRoom});
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.connectToRoom(widget.chatRoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.chatRoom.seniorName),
            subtitle: Text(
              chatProvider.isConnected ? 'เชื่อมต่อแล้ว' : 'ไม่เชื่อมต่อ'
            ),
          ),
          body: Column(
            children: [
              // Messages List
              Expanded(
                child: ListView.builder(
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return MessageBubble(message: message);
                  },
                ),
              ),
              
              // Message Input
              MessageInput(
                onSendMessage: (text) {
                  chatProvider.sendMessage(text);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 2. Sending Messages

```dart
// ส่งข้อความธรรมดา
chatProvider.sendMessage('สวัสดีครับ');

// ส่งข้อความแบบ Payment
chatProvider.sendMessage('ข้อมูลการจ่ายเงิน', messageType: 'payment');

// Typing indicators
chatProvider.startTyping();
chatProvider.stopTyping();
```

### 3. Listening to Events

```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    return Column(
      children: [
        // Connection Status
        Text(chatProvider.isConnected ? 'เชื่อมต่อแล้ว' : 'ไม่เชื่อมต่อ'),
        
        // Error Display
        if (chatProvider.error != null)
          Container(
            color: Colors.red.shade100,
            child: Text(chatProvider.error!),
          ),
        
        // Typing Indicator
        if (chatProvider.typingUsers.isNotEmpty)
          Text('${chatProvider.typingUsers.keys.first} กำลังพิมพ์...'),
        
        // Online Status
        Text('ออนไลน์: ${chatProvider.onlineUsers[roomId]?.length ?? 0} คน'),
      ],
    );
  },
)
```

## API Integration

### 1. WebSocket Connection

WebSocket URL: `ws://localhost:8000/chat/ws/{room_id}?token={jwt_token}`

### 2. Message Types

#### Client -> Server

```json
{
  "type": "send_message",
  "content": "ข้อความ",
  "message_type": "text"
}
```

```json
{
  "type": "typing_indicator",
  "is_typing": true
}
```

#### Server -> Client

```json
{
  "type": "new_message",
  "data": {
    "id": "msg_123",
    "room_id": "room_456",
    "sender_id": "user_789",
    "sender_name": "ชื่อผู้ส่ง",
    "content": "ข้อความ",
    "message_type": "text",
    "created_at": "2023-01-01T00:00:00Z"
  }
}
```

```json
{
  "type": "user_online",
  "user_id": "user_123"
}
```

```json
{
  "type": "typing_indicator",
  "user_id": "user_123",
  "is_typing": true
}
```

### 3. HTTP API Endpoints

```dart
// Get chat rooms
GET /chat/rooms

// Get messages
GET /chat/rooms/{room_id}/messages?limit=50&offset=0

// Create chat room
POST /chat/rooms
{
  "job_id": "job_123",
  "senior_id": "senior_456"
}

// Send message (fallback)
POST /chat/rooms/{room_id}/messages
{
  "content": "ข้อความ",
  "message_type": "text"
}

// Upload file
POST /chat/rooms/{room_id}/upload
FormData: file

// Mark as read
PATCH /chat/rooms/{room_id}/messages/read
{
  "message_ids": ["msg_1", "msg_2"]
}
```

## Configuration

### 1. Backend URL

แก้ไขใน `lib/services/websocket_service.dart`:

```dart
final uri = Uri.parse('ws://your-domain.com/chat/ws/$roomId?token=$token');
```

แก้ไขใน `lib/services/chat_service.dart`:

```dart
static const String baseUrl = 'http://your-domain.com';
```

### 2. Authentication

บันทึก JWT Token:

```dart
await StorageHelper.saveToken('your_jwt_token');
```

WebSocket จะใช้ token นี้ในการเชื่อมต่อโดยอัตโนมัติ

## Error Handling

### 1. Connection Errors

```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    if (chatProvider.error != null) {
      return AlertDialog(
        title: Text('เกิดข้อผิดพลาด'),
        content: Text(chatProvider.error!),
        actions: [
          TextButton(
            onPressed: () {
              chatProvider.connectToRoom(chatRoom);
            },
            child: Text('ลองใหม่'),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  },
)
```

### 2. Auto Reconnection

ระบบจะพยายามเชื่อมต่อใหม่โดยอัตโนมัติ:
- จำนวนครั้งสูงสุด: 5 ครั้ง
- หน่วงเวลา: 3 วินาที
- Ping interval: 30 วินาที

## File Structure

```
lib/
├── model/
│   ├── chat_message.dart      # ChatMessage & PaymentDetails models
│   └── chat_room.dart         # ChatRoom model
├── providers/
│   └── chat_provider.dart     # Chat state management
├── services/
│   ├── chat_service.dart      # HTTP API calls
│   └── websocket_service.dart # WebSocket connection
├── screens/
│   ├── chat_screen.dart       # Individual chat screen
│   └── chat_rooms_screen.dart # Chat rooms list
├── utils/
│   ├── storage_helper.dart    # Local storage utilities
│   └── chat_usage_examples.dart # Usage examples
└── widgets/
    └── chat_example_widget.dart # Example implementation
```

## Testing

### 1. WebSocket Connection Test

```dart
void testWebSocketConnection() async {
  final wsService = WebSocketService();
  
  try {
    await wsService.connect('test_room_id');
    print('Connected: ${wsService.isConnected}');
    
    wsService.sendMessage('Test message', 'text');
    
    await wsService.disconnect();
  } catch (e) {
    print('Error: $e');
  }
}
```

### 2. Chat Flow Test

```dart
void testChatFlow() async {
  final chatProvider = ChatProvider();
  
  final testRoom = ChatRoom(
    id: 'test_room',
    jobId: 'test_job',
    userId: 'test_user',
    userName: 'Test User',
    seniorId: 'test_senior',
    seniorName: 'Test Senior',
    createdAt: DateTime.now(),
  );
  
  await chatProvider.connectToRoom(testRoom);
  chatProvider.sendMessage('Hello, World!');
  
  // Listen to messages
  chatProvider.messageStream.listen((message) {
    print('Received: ${message.message}');
  });
}
```

## Troubleshooting

### 1. Connection Issues

- ตรวจสอบ JWT Token
- ตรวจสอบ Backend URL
- ตรวจสอบ Network connectivity
- ดู logs ใน Console

### 2. Message Not Received

- ตรวจสอบ WebSocket connection status
- ตรวจสอบ room_id ถูกต้อง
- ตรวจสอบ Backend WebSocket handler

### 3. Performance Issues

- จำกัดจำนวนข้อความใน ListView
- ใช้ pagination สำหรับข้อความเก่า
- ตั้งค่า proper dispose methods

## License

MIT License