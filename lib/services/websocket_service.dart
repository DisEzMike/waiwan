import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/utils/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../model/chat_message.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _currentRoomId;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const Duration pingInterval = Duration(seconds: 30);

  // Stream controllers for different message types
  final StreamController<ChatMessage> _messageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _userStatusController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController =
      StreamController.broadcast();

  // Getters for streams
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get userStatusStream =>
      _userStatusController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;
  String? get currentRoomId => _currentRoomId;

  Future<void> connect(String roomId) async {
    if (_isConnected && _currentRoomId == roomId) {
      log('Already connected to room: $roomId');
      return;
    }

    await disconnect();

    try {
      final token = localStorage.getItem("token");
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('ws://$HOST/chat/ws/$roomId?token=$token');
      log('Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);
      _currentRoomId = roomId;

      // Wait for connection to be established
      await _channel!.ready;

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);

      log('WebSocket connected to room: $roomId');

      // Start listening for messages
      _listen();

      // Start ping timer
      _startPingTimer();
    } catch (e) {
      log('WebSocket connection failed: $e');
      _isConnected = false;
      _connectionController.add(false);
      _scheduleReconnect(roomId);
    }
  }

  void _listen() {
    _channel?.stream.listen(
      (data) {
        try {
          final message = json.decode(data);
          _handleMessage(message);
        } catch (e) {
          log('Error parsing WebSocket message: $e');
        }
      },
      onError: (error) {
        log('WebSocket error: $error');
        _handleDisconnection();
      },
      onDone: () {
        log('WebSocket connection closed');
        _handleDisconnection();
      },
    );
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    switch (type) {
      case 'new_message':
        final userId = localStorage.getItem('userId') ?? '';
        final chatMessage = ChatMessage.fromJson({...message['message'], 'isMe': message['message']['sender_id'] == userId});
        _messageController.add(chatMessage);
        break;

      case 'user_online':
      case 'user_offline':
        _userStatusController.add(message);
        break;

      case 'typing_indicator':
        _typingController.add(message);
        break;

      case 'pong':
        // Handle pong response
        break;

      default:
        log('Unknown message type: $type');
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _connectionController.add(false);
    _stopPingTimer();

    if (_currentRoomId != null) {
      _scheduleReconnect(_currentRoomId!);
    }
  }

  void _scheduleReconnect(String roomId) {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      log('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    log(
      'Scheduling reconnection attempt $_reconnectAttempts in ${reconnectDelay.inSeconds} seconds',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      log('Attempting to reconnect...');
      connect(roomId);
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (timer) {
      if (_isConnected) {
        sendPing();
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void sendMessage(String content, String messageType) {
    if (!_isConnected || _channel == null) {
      log('Cannot send message: WebSocket not connected');
      return;
    }

    final message = {
      'type': 'message',
      'message': content,
      'message_type': messageType,
    };

    try {
      _channel!.sink.add(json.encode(message));
      log('Message sent: $content');
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  void sendTypingIndicator(bool isTyping) {
    if (!_isConnected || _channel == null) {
      return;
    }

    final message = {'type': 'typing_indicator', 'is_typing': isTyping};

    try {
      _channel!.sink.add(json.encode(message));
    } catch (e) {
      log('Error sending typing indicator: $e');
    }
  }

  void sendPing() {
    if (!_isConnected || _channel == null) {
      return;
    }

    final message = {'type': 'ping'};

    try {
      _channel!.sink.add(json.encode(message));
    } catch (e) {
      log('Error sending ping: $e');
    }
  }

  Future<void> disconnect() async {
    log('Disconnecting WebSocket');

    _reconnectTimer?.cancel();
    _stopPingTimer();

    _isConnected = false;
    _currentRoomId = null;
    _reconnectAttempts = 0;

    try {
      await _channel?.sink.close(status.normalClosure);
    } catch (e) {
      log('Error closing WebSocket: $e');
    }

    _channel = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _userStatusController.close();
    _typingController.close();
    _connectionController.close();
  }
}
