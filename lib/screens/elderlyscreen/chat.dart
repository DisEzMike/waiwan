import 'package:flutter/material.dart';
import '../../model/elderly_person.dart';
import '../../model/chat_message.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/attachment_options_sheet.dart';



class ChatPage extends StatefulWidget {
  final ElderlyPerson person;

  const ChatPage({
    super.key,
    required this.person,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Local chat messages - API implementation to be added later
  List<ChatMessage> messages = [];

  // Preset messages for quick replies
  final List<String> presetMessages = [
    'เสนอราคาใหม่',
  ];

  @override
  void initState() {
    super.initState();
    // _initializeLocalMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void _initializeLocalMessages() {
  //   // Add some sample messages - you can remove these later
  //   setState(() {
  //     messages = [
  //       ChatMessage(
  //         message: "สวัสดีค่ะ ยาย ${widget.person.name}",
  //         isMe: false,
  //         timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
  //         senderName: widget.person.name,
  //       ),
  //       ChatMessage(
  //         message: "สวัสดีจ้ะ หลาน",
  //         isMe: true,
  //         timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
  //         senderName: "ฉัน",
  //       ),
  //       ChatMessage(
  //         message: "วันนี้สบายดีมั้ยคะ",
  //         isMe: false,
  //         timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
  //         senderName: widget.person.name,
  //       ),
  //     ];
  //   });
  // }


  // auto scroll to bottom when new message is added
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // send message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        message: _messageController.text.trim(),
        isMe: true,
        timestamp: DateTime.now(),
        senderName: "ฉัน",
      ));
    });
    _messageController.clear();    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // TODO: Send message via WebSocket
    // _webSocketService.sendMessage(_messageController.text.trim());
  }

  void _sendPresetMessage(String message) {
    // Send regular preset message
    setState(() {
      messages.add(ChatMessage(
        message: message,
        isMe: true,
        timestamp: DateTime.now(),
        senderName: "ฉัน",
      ));
    });
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // TODO: Send message via WebSocket
    // _webSocketService.sendMessage(message);
  }


  // Demo function to simulate elderly person sending payment message
  void _sendPaymentMessage() {

    final paymentDetails = PaymentDetails(
      jobTitle: 'จับคู่ผู้สูงอายุ - ${widget.person.name}',
      payment: '1,200 บาท',
      workType: 'งานแปรงฟัน, อาบน้ำ, เช็ดตัว',
      paymentMethod: 'QR Code',
      code: 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      totalAmount: '1,200 บาท',
    );

    setState(() {
      messages.add(ChatMessage(
        message: 'ได้รับการชำระเงินแล้ว',
        isMe: false, // This comes from elderly person, not user
        timestamp: DateTime.now(),
        senderName: widget.person.name,
        isPayment: true,
        paymentDetails: paymentDetails,
      ));
    });
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AttachmentOptionsSheet(
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
    // Add completion message from user
    setState(() {
      messages.add(ChatMessage(
        message: 'คุณชำระเงินเสร็จสิน',
        isMe: true, // This comes from user
        timestamp: DateTime.now(),
        senderName: "ฉัน",
      ));
    });
    
    // Auto send map button message after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          messages.add(ChatMessage(
            message: 'แผนที่ตำแหน่งของคุณ',
            isMe: true, // This also comes from user
            timestamp: DateTime.now(),
            senderName: "ฉัน",
            isMap: true,
          ));
        });
        
        // Scroll to bottom after sending message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
    
    // Scroll to bottom after sending first message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return ChatMessageBubble(
      message: message,
      elderlyPersonName: widget.person.name,
      address: widget.person.address,
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
              backgroundImage: AssetImage(widget.person.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.person.name,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ออนไลน์',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.person.isVerified)
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Demo button to simulate elderly person sending payment
          IconButton(
            onPressed: () {
              _sendPaymentMessage();
            },
            icon: const Icon(
              Icons.payment,
              color: Colors.white,
            ),
            tooltip: 'Demo: ผู้สูงอายุส่งการชำระเงิน',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
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
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ElevatedButton(
                    onPressed: () => _sendPresetMessage(presetMessages[index]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
