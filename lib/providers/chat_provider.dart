import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:developer';

import '../model/chat_message.dart';
import '../model/chat_room.dart';
import '../services/websocket_service.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();

  // Current chat state
  ChatRoom? _currentRoom;
  List<ChatMessage> _messages = [];
  List<ChatRoom> _chatRooms = [];
  bool _isConnected = false;
  bool _isLoading = false;
  String? _error;

  // Typing indicators
  Map<String, bool> _typingUsers = {};
  Map<String, List<String>> _onlineUsers = {};

  // Stream subscriptions
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _userStatusSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  // Getters
  ChatRoom? get currentRoom => _currentRoom;
  List<ChatMessage> get messages => _messages;
  List<ChatRoom> get chatRooms => _chatRooms;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get typingUsers => _typingUsers;
  Map<String, List<String>> get onlineUsers => _onlineUsers;

  ChatProvider() {
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // Listen to message stream
    _messageSubscription = _webSocketService.messageStream.listen(
      (message) {
        _addMessage(message);
      },
      onError: (error) {
        log('Message stream error: $error');
        _setError('Failed to receive messages: $error');
      },
    );

    // Listen to user status updates
    _userStatusSubscription = _webSocketService.userStatusStream.listen(
      (statusData) {
        _handleUserStatusUpdate(statusData);
      },
      onError: (error) {
        log('User status stream error: $error');
      },
    );

    // Listen to typing indicators
    _typingSubscription = _webSocketService.typingStream.listen(
      (typingData) {
        _handleTypingUpdate(typingData);
      },
      onError: (error) {
        log('Typing stream error: $error');
      },
    );

    // Listen to connection status
    _connectionSubscription = _webSocketService.connectionStream.listen(
      (connected) {
        _isConnected = connected;
        if (!connected) {
          _setError('Connection lost. Reconnecting...');
        } else {
          _clearError();
        }

        // Use addPostFrameCallback to avoid calling notifyListeners during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      },
      onError: (error) {
        log('Connection stream error: $error');
      },
    );
  }

  Future<void> connectToRoom(ChatRoom room) async {
    if (_currentRoom?.id == room.id && _isConnected) {
      return; // Already connected to this room
    }

    try {
      _setLoading(true);
      _clearError();

      // Disconnect from current room if any
      if (_currentRoom != null) {
        await _webSocketService.disconnect();
      }

      _currentRoom = room;
      _messages.clear();

      // Load initial messages from API
      try {
        final initialMessages = await ChatService.getRoomMessages(room.id);
        _messages.addAll(initialMessages);
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        log(
          'Loaded ${initialMessages.length} initial messages for room: ${room.id}',
        );
      } catch (e) {
        log('Error loading initial messages: $e');
        // Continue with WebSocket connection even if loading messages fails
      }

      // Connect to WebSocket for real-time updates
      await _webSocketService.connect(room.id);

      log('Connected to chat room: ${room.id}');
    } catch (e) {
      log('Error connecting to room: $e');
      _setError('Failed to connect to chat room: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(
    String content, {
    String messageType = 'text',
  }) async {
    if (!_isConnected || _currentRoom == null) {
      _setError('Not connected to chat room');
      return;
    }

    if (content.trim().isEmpty) {
      return;
    }

    try {
      // Send message via WebSocket
      _webSocketService.sendMessage(content, messageType);
    } catch (e) {
      log('Error sending message: $e');
      _setError('Failed to send message: $e');
    }
  }

  void startTyping() {
    if (_isConnected && _currentRoom != null) {
      _webSocketService.sendTypingIndicator(true);
    }
  }

  void stopTyping() {
    if (_isConnected && _currentRoom != null) {
      _webSocketService.sendTypingIndicator(false);
    }
  }

  Future<void> refreshMessages() async {
    if (_currentRoom == null) return;

    try {
      _setLoading(true);
      final messages = await ChatService.getRoomMessages(_currentRoom!.id);
      _messages.clear();
      _messages.addAll(messages);
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      log(
        'Refreshed ${messages.length} messages for room: ${_currentRoom!.id}',
      );
      notifyListeners();
    } catch (e) {
      log('Error refreshing messages: $e');
      _setError('Failed to refresh messages: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _addMessage(ChatMessage message) {
    // Check if message already exists (avoid duplicates)
    final existingIndex = _messages.indexWhere((msg) => msg.id == message.id);
    if (existingIndex != -1) {
      // Update existing message if needed
      _messages[existingIndex] = message;
    } else {
      // Add new message
      _messages.add(message);
    }

    // Sort messages by timestamp
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Update room's last message
    if (_currentRoom != null) {
      _currentRoom = _currentRoom!.copyWith(
        lastMessageAt: message.createdAt,
        lastMessageContent: message.message,
        lastMessageSenderId: message.senderId,
      );
    }

    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Add mock message for demo purposes (bypasses WebSocket)
  void addMockMessage(ChatMessage message) {
    _addMessage(message);
  }

  void _handleUserStatusUpdate(Map<String, dynamic> statusData) {
    final type = statusData['type'];
    final userId = statusData['user_id'];
    final roomId = _currentRoom?.id;

    if (roomId == null || userId == null) return;

    if (type == 'user_online') {
      _onlineUsers[roomId] ??= [];
      if (!_onlineUsers[roomId]!.contains(userId)) {
        _onlineUsers[roomId]!.add(userId);
      }
    } else if (type == 'user_offline') {
      _onlineUsers[roomId]?.remove(userId);
      if (_onlineUsers[roomId]?.isEmpty == true) {
        _onlineUsers.remove(roomId);
      }
    }

    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _handleTypingUpdate(Map<String, dynamic> typingData) {
    final userId = typingData['user_id'];
    final isTyping = typingData['is_typing'] ?? false;

    if (userId != null) {
      if (isTyping) {
        _typingUsers[userId] = true;
      } else {
        _typingUsers.remove(userId);
      }

      // Use addPostFrameCallback to avoid calling notifyListeners during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void setChatRooms(List<ChatRoom> rooms) {
    _chatRooms = rooms;

    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void addChatRoom(ChatRoom room) {
    _chatRooms.add(room);

    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateChatRoom(ChatRoom room) {
    final index = _chatRooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _chatRooms[index] = room;

      // Use addPostFrameCallback to avoid calling notifyListeners during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;

    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String errorMessage) {
    _error = errorMessage;

    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _error = null;

    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> disconnect() async {
    try {
      await _webSocketService.disconnect();
      _currentRoom = null;
      _messages.clear();
      _typingUsers.clear();
      _onlineUsers.clear();
      _isConnected = false;

      // Use addPostFrameCallback to avoid calling notifyListeners during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      log('Error disconnecting: $e');
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _userStatusSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
