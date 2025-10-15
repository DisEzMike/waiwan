import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/screens/job_detail.dart';
import 'package:waiwan/utils/font_size_helper.dart';
import 'package:waiwan/utils/helper.dart';
import 'dart:async';
import '../../model/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/attachment_options_sheet.dart';

class ChatScreen extends StatefulWidget {
  final String chatroomId;
  final int jobId; // เพิ่ม jobId เพื่อใช้ในปุ่มแชท
  const ChatScreen({super.key, required this.chatroomId, required this.jobId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;
  final userId = localStorage.getItem('userId');

  // WebSocket related
  bool _isWebSocketInitialized = false;
  ChatProvider? _chatProvider; // เก็บ reference ของ ChatProvider

  // Preset messages for quick replies
  final List<String> presetMessages = ['เสนอราคาใหม่'];

  @override
  void initState() {
    super.initState();
    _initializeLocalMessages();
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

      // Initialize WebSocket after ChatProvider is available
      if (!_isWebSocketInitialized && _chatProvider != null) {
        _initializeWebSocket();
      }
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
    try {
      debugPrint('Initializing WebSocket for room: ${widget.chatroomId}');
      debugPrint('ChatProvider available: ${_chatProvider != null}');

      if (_chatProvider == null) {
        debugPrint('ChatProvider is null, cannot connect to WebSocket');
        return;
      }

      await _chatProvider!.connectToRoom(widget.chatroomId);
      _isWebSocketInitialized = true;
      debugPrint('WebSocket initialization successful');
    } catch (e) {
      debugPrint('WebSocket initialization error: ${e.toString()}');
      if (mounted) {
        showErrorSnackBar(context, e.toString());
      }
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
    // No longer needed - messages come from ChatProvider
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
    debugPrint('Sending message: $content');

    // ส่งข้อความผ่าน ChatProvider (WebSocket + HTTP fallback)
    if (_chatProvider != null) {
      _chatProvider!.sendMessage(content);
      debugPrint('Message sent via ChatProvider');
    } else {
      debugPrint('ChatProvider is null, cannot send message');
    }

    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Handle typing indicator
    _stopTyping();
  }

  void _sendPresetMessage(String message) {
    debugPrint('Sending preset message: $message');

    // ส่งข้อความผ่าน ChatProvider (WebSocket + HTTP fallback)
    if (_chatProvider != null) {
      _chatProvider!.sendMessage(message);
      debugPrint('Preset message sent via ChatProvider');
    } else {
      debugPrint('ChatProvider is null, cannot send preset message');
    }

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // // Demo function to simulate elderly person sending payment message
  // void _sendPaymentMessage() {
  //   final currentRoom = _chatProvider?.currentRoom;
  //   final seniorName =
  //       currentRoom?.seniors.isNotEmpty == true
  //           ? currentRoom!.seniors.first.displayname
  //           : 'ผู้สูงอายุ';

  //   final paymentDetails = PaymentDetails(
  //     jobTitle: 'จับคู่ผู้สูงอายุ - $seniorName',
  //     payment: '1,200 บาท',
  //     workType: 'งานแปรงฟัน, อาบน้ำ, เช็ดตัว',
  //     paymentMethod: 'QR Code',
  //     code:
  //         'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
  //     totalAmount: '1,200 บาท',
  //   );

  //   // Create a mock payment message from elderly person (not using WebSocket)
  //   final paymentMessage = ChatMessage(
  //     id: DateTime.now().millisecondsSinceEpoch.toString(),
  //     roomId: widget.chatroomId,
  //     senderId:
  //         currentRoom?.seniors.isNotEmpty == true
  //             ? currentRoom!.seniors.first.id
  //             : 'mock_senior_id',
  //     senderType: 'senior_user',
  //     message: 'ได้รับการชำระเงินแล้ว',
  //     isRead: false,
  //     createdAt: DateTime.now(),
  //     isMe: false,
  //     isPayment: true,
  //     paymentDetails: paymentDetails,
  //   );

  //   // Add message directly to ChatProvider (bypassing WebSocket)
  //   if (_chatProvider != null) {
  //     _chatProvider!.addMockMessage(paymentMessage);
  //   }
  //   // Note: No fallback needed as we always have ChatProvider
  // }

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
      senderId: userId ?? 'current_user_id',
      senderType: 'user',
      message: 'คุณชำระเงินเสร็จสิน',
      isRead: false,
      createdAt: DateTime.now(),
      isMe: true, // This comes from user
    );

    // Add completion message
    if (_chatProvider != null) {
      _chatProvider!.addMockMessage(completionMessage);
    }
    // Note: No fallback needed as we always have ChatProvider

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
          senderId: userId ?? 'current_user_id',
          senderType: 'user',
          message: 'แผนที่ตำแหน่งของคุณ',
          isRead: false,
          createdAt: DateTime.now(),
          isMe: true, // This also comes from user
          isMap: true,
        );

        if (_chatProvider != null) {
          _chatProvider!.addMockMessage(mapMessage);
        }
        // Note: No fallback needed as we always have ChatProvider
      }
    });

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final currentRoom = _chatProvider?.currentRoom;
    final seniorName =
        currentRoom?.seniors.isNotEmpty == true
            ? currentRoom!.seniors.first.displayname
            : 'ผู้สูงอายุ';

    return ChatMessageBubble(
      message: message,
      elderlyPersonName: seniorName,
      address: 'ที่อยู่ไม่ระบุ', // ใน API ใหม่ไม่มี address field
      onPaymentCompleted: _sendPaymentCompletionMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            // Show loading indicator while room is loading
            if (chatProvider.isLoading && chatProvider.currentRoom == null) {
              return Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'กำลังโหลด...',
                    style: FontSizeHelper.createTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }

            // Show job title when room is loaded
            final currentRoom = chatProvider.currentRoom;
            final jobTitle = currentRoom?.jobTitle ?? 'แชท';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    jobTitle,
                    style: FontSizeHelper.createTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // WebSocket connection status indicator
          // Consumer<ChatProvider>(
          //   builder: (context, chatProvider, child) {
          //     return Container(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Row(
          //         children: [
          //           Icon(
          //             chatProvider.isConnected ? Icons.wifi : Icons.wifi_off,
          //             color:
          //                 chatProvider.isConnected ? Colors.green : Colors.red,
          //             size: 16,
          //           ),
          //           const SizedBox(width: 4),
          //           Text(
          //             chatProvider.isConnected
          //                 ? 'เชื่อมต่อ'
          //                 : 'ขาดการเชื่อมต่อ',
          //             style: TextStyle(
          //               fontSize: 10,
          //               color:
          //                   chatProvider.isConnected
          //                       ? Colors.green
          //                       : Colors.red,
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
          // Demo button to simulate elderly person sending payment
          IconButton(
            onPressed: () {
              // _sendPaymentMessage();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailScreen(jobId: widget.jobId),
                ),
              );
            },
            icon: const Icon(Icons.work, color: Colors.white),
            // tooltip: 'Demo: ผู้สูงอายุส่งการชำระเงิน',
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
                      .where((userIds) => userIds != userId)
                      .toList();

              if (typingUsers.isNotEmpty) {
                final currentRoom = _chatProvider?.currentRoom;
                final seniorName =
                    currentRoom?.seniors.isNotEmpty == true
                        ? currentRoom!.seniors.first.displayname
                        : 'ผู้สูงอายุ';

                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$seniorName กำลังพิมพ์...',
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
                // Show loading indicator if room is not loaded yet
                if (chatProvider.isLoading &&
                    chatProvider.currentRoom == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'กำลังโหลดข้อมูลแชท...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

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
