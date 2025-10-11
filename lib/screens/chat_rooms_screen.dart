import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/model/elderly_person.dart';
import 'package:waiwan/services/user_service.dart';
import 'package:waiwan/utils/helper.dart';

import '../model/chat_room.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import 'elderlyscreen/chat.dart';
// import 'elderlyscreen/chat.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final chatRooms = await ChatService.getChatRooms();
      if (mounted) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.setChatRooms(chatRooms);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        snackBarErrorMessage(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshChatRooms() async {
    await _loadChatRooms();
  }

  void _navigateToChat(ElderlyPerson senior, ChatRoom chatRoom) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(person: senior, chatroomId: chatRoom.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: _refreshChatRooms, child: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาด',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshChatRooms,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final chatRooms = chatProvider.chatRooms;
        if (chatRooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'ยังไม่มีการสนทนา',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'เริ่มสนทนาด้วยการสมัครงาน',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            return FutureBuilder<Widget>(
              future: _buildChatRoomTile(chatRoom),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                } else if (snapshot.hasError) {
                  return ListTile(title: Text('Error: ${snapshot.error}'));
                } else {
                  return const ListTile(
                    leading: CircleAvatar(child: CircularProgressIndicator()),
                    title: Text('Loading...'),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Future<Widget> _buildChatRoomTile(ChatRoom chatRoom) async {
    try {
      final res = await UserService().getSenior(chatRoom.seniorId);
      final senior = ElderlyPerson.fromJson(res);
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(senior.profile.imageUrl),
          radius: 24,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatRoom.seniorName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (chatRoom.jobTitle != null)
              Text(
                chatRoom.jobTitle!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chatRoom.lastMessageContent != null) ...[
              Text(
                chatRoom.lastMessageContent!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
            ],
            if (chatRoom.lastMessageAt != null)
              Text(
                _formatTime(chatRoom.lastMessageAt!),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (chatRoom.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chatRoom.unreadCount > 99
                      ? '99+'
                      : chatRoom.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final isOnline =
                    chatProvider.onlineUsers[chatRoom.id]?.contains(
                      chatRoom.seniorId,
                    ) ??
                    false;

                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () => _navigateToChat(senior, chatRoom),
      );
    } catch (e) {
      debugPrint(e.toString());
      snackBarErrorMessage(context, e.toString());
      return ListTile(title: Text('Error loading user: ${e.toString()}'));
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'เมื่อวาน';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} วันที่แล้ว';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชม.';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาที';
    } else {
      return 'เมื่อสักครู่';
    }
  }
}
