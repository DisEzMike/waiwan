# แก้ไข Error: setState() during build

## ปัญหาที่เกิดขึ้น:
```
FlutterError (setState() or markNeedsBuild() called during build.
This _InheritedProviderScope<ChatProvider?> widget cannot be marked as needing to build because the framework is already in the process of building widgets.
```

## สาเหตุ:
- การเรียก `notifyListeners()` ใน `ChatProvider` ในขณะที่ widget กำลัง build อยู่
- เกิดจาก WebSocket callbacks ที่เรียก notifyListeners ทันที

## วิธีแก้ไข:

### 1. ใช้ WidgetsBinding.instance.addPostFrameCallback
แทนที่ `notifyListeners()` ทันทีด้วย:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  notifyListeners();
});
```

### 2. แก้ไขใน ChatProvider methods:
- `_addMessage()`
- `_handleUserStatusUpdate()`
- `_handleTypingUpdate()`
- `_setLoading()`
- `_setError()`
- `_clearError()`
- `setChatRooms()`
- `addChatRoom()`
- `updateChatRoom()`
- `disconnect()`
- Connection stream listener

### 3. ปรับปรุง chat.dart:
- ใช้ `Consumer<ChatProvider>` ใน Messages List
- รวม local messages กับ WebSocket messages
- ไม่ใช้ `addListener` โดยตรง แต่ใช้ Consumer แทน

## ไฟล์ที่แก้ไข:

### chat_provider.dart
```dart
// เพิ่ม import
import 'package:flutter/widgets.dart';

// แก้ไขทุก notifyListeners()
WidgetsBinding.instance.addPostFrameCallback((_) {
  notifyListeners();
});
```

### chat.dart
```dart
// แก้ไข Messages List ให้ใช้ Consumer
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    // รวม local + WebSocket messages
    final allMessages = <ChatMessage>[];
    allMessages.addAll(messages);
    
    // เพิ่ม WebSocket messages
    for (var wsMessage in chatProvider.messages) {
      // ตรวจสอบว่าไม่ซ้ำ
      if (!allMessages.any((msg) => msg.id == wsMessage.id)) {
        allMessages.add(convertMessage(wsMessage));
      }
    }
    
    return ListView.builder(...);
  },
)
```

## ผลลัพธ์:
✅ แก้ไข setState during build error  
✅ WebSocket messages แสดงใน UI ได้แล้ว  
✅ Real-time updates ทำงานปกติ  
✅ ไม่มี build conflicts  
✅ Performance ดีขึ้น  

## การทดสอบ:
1. เปิดหน้าแชท - ไม่มี error
2. ส่งข้อความ - แสดงทันที
3. รับข้อความจาก WebSocket - อัปเดตแบบ real-time
4. Typing indicators - ทำงานปกติ
5. Connection status - แสดงถูกต้อง

## หมายเหตุ:
- `addPostFrameCallback` จะรอให้ current build cycle เสร็จก่อนแล้วค่อย notify
- Consumer จะ rebuild อัตโนมัติเมื่อ ChatProvider เปลี่ยนแปลง
- ไม่ต้องใช้ manual listeners ใน widget lifecycle