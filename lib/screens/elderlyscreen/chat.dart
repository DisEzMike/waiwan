import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/services/chat_service.dart';
import 'dart:async';
import '../../model/elderly_person.dart';
import '../../model/chat_message.dart';
import '../../model/chat_room.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/attachment_options_sheet.dart';

class ChatScreen extends StatefulWidget {
  final ElderlyPerson person;
  final String chatroomId;
  const ChatScreen({super.key, required this.person, required this.chatroomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;
  final userId = localStorage.getItem('user_id');

  // Local chat messages - API implementation to be added later
  List<ChatMessage> messages = [];

  // WebSocket related
  ChatRoom? _chatRoom;
  bool _isWebSocketInitialized = false;
  ChatProvider? _chatProvider; // เก็บ reference ของ ChatProvider

  // Preset messages for quick replies
  final List<String> presetMessages = ['เสนอราคาใหม่'];

  @override
  void initState() {
    super.initState();
    _initializeLocalMessages();
    _initializeWebSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // เก็บ reference ของ ChatProvider ไว้ใช้ใน dispose()
    final newChatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Add listener only once when ChatProvider changes
    if (_chatProvider != newChatProvider) {
      _chatProvider?.removeListener(_onMessagesChanged);
      _chatProvider = newChatProvider;
      _chatProvider?.addListener(_onMessagesChanged);
    }
  }

  void _onMessagesChanged() {
    // Auto scroll to bottom when new messages are received
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatProvider?.removeListener(_onMessagesChanged);
    if (_isWebSocketInitialized && _chatProvider != null) {
      _chatProvider!.disconnect();
    }
    super.dispose();
  }

  void _initializeWebSocket() async {
    // สร้าง ChatRoom จาก ElderlyPerson data
    _chatRoom = await ChatService.getChatRoom(widget.chatroomId);

    try {
      // เชื่อมต่อ WebSocket ผ่าน ChatProvider
      if (_chatProvider != null) {
        await _chatProvider!.connectToRoom(_chatRoom!);

        setState(() {
          _isWebSocketInitialized = true;
        });

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('Error initializing WebSocket: $e');
    }
  }

  void _onTyping() {
    if (_isWebSocketInitialized && _chatProvider != null) {
      if (!_isTyping) {
        _isTyping = true;
        _chatProvider!.startTyping();
      }

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _stopTyping();
      });
    }
  }

  void _stopTyping() {
    if (_isTyping && _isWebSocketInitialized && _chatProvider != null) {
      _isTyping = false;
      _chatProvider!.stopTyping();
    }
    _typingTimer?.cancel();
  }

  void _initializeLocalMessages() {
    // Local messages are now loaded from the database via ChatProvider
    // This method can be removed or used for any app-specific initialization
    setState(() {
      messages = [];
    });
  }

  // auto scroll to bottom when new message is added
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Add a small delay to ensure the ListView has been updated
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // send message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();

    // ส่งข้อความผ่าน WebSocket ถ้า WebSocket เชื่อมต่อแล้ว
    if (_isWebSocketInitialized && _chatProvider != null) {
      _chatProvider!.sendMessage(content);
    } else {
      // Fallback: เพิ่มข้อความใน local list ถ้า WebSocket ยังไม่พร้อม
      setState(() {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: widget.chatroomId,
            senderId: userId!,
            sender_type: 'user',
            message: content,
            is_read: false,
            createdAt: DateTime.now(),
            isMe: true,
          ),
        );
      });
    }

    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Handle typing indicator
    _stopTyping();
  }

  void _sendPresetMessage(String message) {
    // ส่งข้อความผ่าน WebSocket ถ้า WebSocket เชื่อมต่อแล้ว
    if (_isWebSocketInitialized && _chatProvider != null) {
      _chatProvider!.sendMessage(message);
    } else {
      // Fallback: เพิ่มข้อความใน local list ถ้า WebSocket ยังไม่พร้อม
      setState(() {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: widget.chatroomId,
            senderId: userId!,
            sender_type: 'user',
            message: message,
            is_read: false,
            createdAt: DateTime.now(),
            isMe: true,
          ),
        );
      });
    }

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Demo function to simulate elderly person sending payment message
  void _sendPaymentMessage() {
    final paymentDetails = PaymentDetails(
      jobTitle: 'จับคู่ผู้สูงอายุ - ${widget.person.displayName}',
      payment: '1,200 บาท',
      workType: 'งานแปรงฟัน, อาบน้ำ, เช็ดตัว',
      paymentMethod: 'QR Code',
      code:
          'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      totalAmount: '1,200 บาท',
    );

    // Create a mock payment message from elderly person (not using WebSocket)
    final paymentMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: widget.chatroomId,
      senderId: widget.person.id,
      sender_type: 'senior_user',
      message: 'ได้รับการชำระเงินแล้ว',
      is_read: false,
      createdAt: DateTime.now(),
      isMe: false,
      isPayment: true,
      paymentDetails: paymentDetails,
    );

    // Add message directly to ChatProvider (bypassing WebSocket)
    if (_chatProvider != null) {
      _chatProvider!.addMockMessage(paymentMessage);
    } else {
      // Fallback: add to local messages if ChatProvider is not available
      setState(() {
        messages.add(paymentMessage);
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => AttachmentOptionsSheet(
            onCameraPressed: _pickImageFromCamera,
            onGalleryPressed: _pickImageFromGallery,
            onFilePressed: _pickFile,
          ),
    );
  }

  void _pickImageFromCamera() {
    // TODO: Implement camera image picker
    print('Opening camera...');
    // _sendSystemMessage('📷 ถ่ายรูปจากกล้อง');
  }

  void _pickImageFromGallery() {
    // TODO: Implement gallery image picker
    print('Opening gallery...');
    // _sendSystemMessage('🖼️ เลือกภาพจากคลังภาพ');
  }

  void _pickFile() {
    // TODO: Implement file picker
    print('Opening file picker...');
    // _sendSystemMessage('📁 เลือกไฟล์');
  }

  // After payment is done, send completion message and map button
  void _sendPaymentCompletionMessage() {
    // Create completion message from user
    final completionMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: widget.chatroomId,
      senderId: 'current_user_id',
      sender_type: 'user',
      message: 'คุณชำระเงินเสร็จสิน',
      is_read: false,
      createdAt: DateTime.now(),
      isMe: true, // This comes from user
    );

    // Add completion message
    if (_chatProvider != null) {
      _chatProvider!.addMockMessage(completionMessage);
    } else {
      setState(() {
        messages.add(completionMessage);
      });
    }

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Auto send map button message after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final mapMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          roomId: widget.chatroomId,
          senderId: 'current_user_id',
          sender_type: 'user',
          message: 'แผนที่ตำแหน่งของคุณ',
          is_read: false,
          createdAt: DateTime.now(),
          isMe: true, // This also comes from user
          isMap: true,
        );

        if (_chatProvider != null) {
          _chatProvider!.addMockMessage(mapMessage);
        } else {
          setState(() {
            messages.add(mapMessage);
          });
        }
      }
    });

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return ChatMessageBubble(
      message: message,
      elderlyPersonName: widget.person.displayName,
      address: widget.person.profile.currentAddress,
      onPaymentCompleted: _sendPaymentCompletionMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.person.profile.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.person.displayName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      final isOnline =
                          chatProvider.isConnected &&
                          (chatProvider.onlineUsers[_chatRoom?.id]?.contains(
                                widget.person.id,
                              ) ??
                              false);

                      return Text(
                        isOnline
                            ? 'ออนไลน์'
                            : (_isWebSocketInitialized
                                ? 'ออฟไลน์'
                                : 'กำลังเชื่อมต่อ...'),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isOnline ? Colors.green[300] : Colors.grey[300],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (widget.person.isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 20),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // WebSocket connection status indicator
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      chatProvider.isConnected ? Icons.wifi : Icons.wifi_off,
                      color:
                          chatProvider.isConnected ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      chatProvider.isConnected
                          ? 'เชื่อมต่อ'
                          : 'ขาดการเชื่อมต่อ',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            chatProvider.isConnected
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Demo button to simulate elderly person sending payment
          IconButton(
            onPressed: () {
              _sendPaymentMessage();
            },
            icon: const Icon(Icons.payment, color: Colors.white),
            tooltip: 'Demo: ผู้สูงอายุส่งการชำระเงิน',
          ),
        ],
      ),
      body: Column(
        children: [
          // WebSocket Error Banner
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.error != null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.red.shade100,
                  child: Text(
                    chatProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Typing Indicator
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              final typingUsers =
                  chatProvider.typingUsers.keys
                      .where((userId) => userId != 'current_user_id')
                      .toList();

              if (typingUsers.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${widget.person.displayName} กำลังพิมพ์...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // Use messages directly from ChatProvider (includes both DB and WebSocket messages)
                final allMessages = chatProvider.messages;

                if (chatProvider.isLoading && allMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (allMessages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ยังไม่มีข้อความ',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'เริ่มสนทนาโดยการส่งข้อความ',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(allMessages[index]);
                  },
                );
              },
            ),
          ),
          // Preset Messages
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.grey[100],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: presetMessages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: () => _sendPresetMessage(presetMessages[index]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      presetMessages[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6EB715), // Green background like in image
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Plus button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _showAttachmentOptions,
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFF6EB715),
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        onChanged: (_) => _onTyping(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Microphone button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Handle voice recording
                        print('Microphone button pressed');
                      },
                      icon: const Icon(
                        Icons.mic,
                        color: Color(0xFF6EB715),
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
