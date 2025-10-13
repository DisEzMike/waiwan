import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:developer';
import 'package:localstorage/localstorage.dart';

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

  Future<void> connectToRoom(String roomId) async {
    try {
      log('ChatProvider.connectToRoom called for room: $roomId');
      _setLoading(true);
      _clearError();

      // Get room details first
      log('Loading room details...');
      final room = await ChatService.getChatRoom(roomId);
      log('Room loaded: ${room.id}');
      
      // Disconnect from current room if different
      if (_currentRoom?.id != roomId && _isConnected) {
        log('Disconnecting from current room...');
        await _webSocketService.disconnect();
      }

      _currentRoom = room;

      // Load messages from the room data
      try {
        log('Loading room messages...');
        _messages = await ChatService.getRoomMessages(roomId);
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        log('Loaded ${_messages.length} messages');
      } catch (e) {
        log('Error loading messages: $e');
        _messages = [];
      }

      // Connect to WebSocket for real-time updates
      log('Connecting to WebSocket...');
      await _webSocketService.connect(roomId);

      log('Successfully connected to chat room: $roomId');
    } catch (e) {
      log('Error connecting to room: $e');
      _setError('Failed to connect to chat room: $e');
      rethrow; // Re-throw so the UI can handle it
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadChatRooms() async {
    try {
      _setLoading(true);
      _clearError();
      
      final rooms = await ChatService.getChatRooms();
      _chatRooms = rooms;
      
      log('Loaded ${_chatRooms.length} chat rooms');
      
      // Use addPostFrameCallback to avoid calling notifyListeners during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      log('Error loading chat rooms: $e');
      _setError('Failed to load chat rooms: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(
    String content, {
    String messageType = 'text',
  }) async {
    if (content.trim().isEmpty) {
      return;
    }

    if (_currentRoom == null) {
      _setError('Not connected to chat room');
      return;
    }

    final userId = localStorage.getItem('userId') ?? '';
    final currentUser = userId.startsWith('S') ? 'senior_user' : 'user';
    
    // Create a temporary message to show immediately in UI
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: _currentRoom!.id,
      senderId: userId,
      senderType: currentUser,
      message: content.trim(),
      isRead: false,
      createdAt: DateTime.now(),
      isMe: true,
    );

    // Add temporary message to UI immediately
    _addMessage(tempMessage);
    log('Added temporary message to UI: ${tempMessage.id}');

    try {
      // Try WebSocket first if connected
      if (_isConnected) {
        log('Sending message via WebSocket');
        _webSocketService.sendMessage(content, messageType: messageType);
        
        // Remove temp message after successful WebSocket send
        // (real message will come back via WebSocket stream)
        _removeMessage(tempMessage.id);
      } else {
        log('WebSocket not connected, using HTTP API');
        // Fallback to HTTP API
        final message = await ChatService.sendMessage(_currentRoom!.id, content, messageType: messageType);
        
        // Replace temp message with real message from API
        _removeMessage(tempMessage.id);
        _addMessage(message);
      }
    } catch (e) {
      log('Error sending message: $e');
      
      // Try HTTP API as fallback
      try {
        log('Trying HTTP API as fallback');
        final message = await ChatService.sendMessage(_currentRoom!.id, content, messageType: messageType);
        
        // Replace temp message with real message from API
        _removeMessage(tempMessage.id);
        _addMessage(message);
      } catch (fallbackError) {
        log('Fallback send message failed: $fallbackError');
        
        // Remove temp message and show error
        _removeMessage(tempMessage.id);
        _setError('Failed to send message: $fallbackError');
      }
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
    log('Adding message: ${message.id} - ${message.message}');
    
    // Check if message already exists (avoid duplicates)
    final existingIndex = _messages.indexWhere((msg) => msg.id == message.id);
    if (existingIndex != -1) {
      // Update existing message if needed
      _messages[existingIndex] = message;
      log('Updated existing message at index: $existingIndex');
    } else {
      // Add new message
      _messages.add(message);
      log('Added new message, total messages: ${_messages.length}');
    }

    // Sort messages by timestamp
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Update room's last message in chat rooms list
    if (_currentRoom != null) {
      final roomIndex = _chatRooms.indexWhere((room) => room.id == _currentRoom!.id);
      if (roomIndex != -1) {
        _chatRooms[roomIndex] = _chatRooms[roomIndex].copyWith(
          lastMessage: message,
        );
      }
    }

    // Notify listeners immediately for real-time updates
    notifyListeners();
    log('Message added and UI notified');
  }

  void _removeMessage(String messageId) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _messages.removeAt(index);
      notifyListeners();
      log('Removed message: $messageId');
    }
  }

  // Add mock message for demo purposes (bypasses WebSocket)
  void addMockMessage(ChatMessage message) {
    _addMessage(message);
  }

  void _handleUserStatusUpdate(Map<String, dynamic> statusData) {
    final type = statusData['type'];
    final userId = statusData['userId'];
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
