import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/community_event.dart';
import '../../models/resource_listing.dart';
import '../../models/feed_post.dart';
import 'dummy_data.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}

class ChatThread {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final List<ChatMessage> messages;
  final String? relatedListingId; // to know if chat started from a specific listing

  ChatThread({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.messages,
    this.relatedListingId,
  });
}

class MockDatabase extends ChangeNotifier {
  static final MockDatabase instance = MockDatabase._internal();

  static const List<String> _sampleNames = [
    'Aarav Sharma',
    'Riya Kapoor',
    'Kabir Mehta',
    'Naina Verma',
    'Ishaan Rao',
    'Diya Malhotra',
    'Arjun Sinha',
    'Maya Patel',
  ];

  MockDatabase._internal()
      : currentUserName = _sampleNames[Random().nextInt(_sampleNames.length)] {
    _events = List.from(DummyData.events);
    _resources = List.from(DummyData.resources);
    _feedPosts = List.from(DummyData.feedPosts);
  }

  final String currentUserId = 'my_user_id';
  String currentUserName;
  bool _isNewUser = true;

  List<CommunityEvent> _events = [];
  List<ResourceListing> _resources = [];
  List<FeedPost> _feedPosts = [];
  
  // Track joined events
  final Set<String> _joinedEventIds = {};

  // Mock chat state
  final List<ChatThread> _chats = [];

  List<CommunityEvent> get events => _events;
  List<ResourceListing> get resources => _resources;
  List<FeedPost> get feedPosts => _feedPosts;
  List<ChatThread> get chats => _chats;
  bool get isNewUser => _isNewUser;

  List<CommunityEvent> get joinedEvents => _events.where((e) => _joinedEventIds.contains(e.id)).toList();

  bool hasJoinedEvent(String eventId) => _joinedEventIds.contains(eventId);

  void completeOnboarding() {
    _isNewUser = false;
    notifyListeners();
  }

  void resetAsNewUser() {
    _isNewUser = true;
    notifyListeners();
  }

  void toggleEventJoin(String eventId) {
    if (_joinedEventIds.contains(eventId)) {
      _joinedEventIds.remove(eventId);
    } else {
      _joinedEventIds.add(eventId);
    }
    notifyListeners();
  }

  void addEvent(CommunityEvent event) {
    _events.insert(0, event);
    notifyListeners();
  }

  void addResourceOrHobby(ResourceListing resource) {
    _resources.insert(0, resource);
    notifyListeners();
  }

  // Chat functions
  ChatThread getOrCreateChat(String otherUserId, String otherUserName, {String? relatedListingId}) {
    final existingParams = _chats.where((c) => c.otherUserId == otherUserId);
    if (existingParams.isNotEmpty) {
      return existingParams.first;
    }
    
    final newChat = ChatThread(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      messages: [],
      relatedListingId: relatedListingId,
    );
    _chats.insert(0, newChat);
    notifyListeners();
    return newChat;
  }

  void sendMessage(String chatId, String text) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      final chat = _chats[chatIndex];
      chat.messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        text: text,
        timestamp: DateTime.now(),
      ));
      
      // Auto reply mock
      Future.delayed(const Duration(seconds: 1), () {
        chat.messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: chat.otherUserId,
          text: 'Got it! Thanks for reaching out.',
          timestamp: DateTime.now(),
        ));
        notifyListeners();
      });

      notifyListeners();
    }
  }
}
