import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/community_event.dart';
import '../models/resource_listing.dart';
import '../models/feed_post.dart';

// ---------------------------------------------------------------------------
// Firestore Service – replaces MockDatabase with real Cloud Firestore data.
// ---------------------------------------------------------------------------
class FirestoreService extends ChangeNotifier {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // =========================================================================
  // USER PROFILE
  // =========================================================================
  CollectionReference get _usersCol => _db.collection('users');

  /// Ensures a Firestore profile doc exists for the signed-in user.
  Future<void> ensureProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = _usersCol.doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'displayName': user.displayName ?? user.email?.split('@').first ?? 'User',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'photoUrl': user.photoURL ?? '',
        'bio': '',
        'joinedAt': FieldValue.serverTimestamp(),
        'followers': <String>[],
        'following': <String>[],
      });
    }
  }

  Future<Map<String, dynamic>?> getProfile([String? uid]) async {
    final id = uid ?? _uid;
    if (id == null) return null;
    final snap = await _usersCol.doc(id).get();
    if (!snap.exists) return null;
    return {'id': snap.id, ...snap.data()! as Map<String, dynamic>};
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_uid == null) return;
    await _usersCol.doc(_uid).update(data);
    // Also update Auth display name if provided
    final user = FirebaseAuth.instance.currentUser;
    if (data.containsKey('displayName') && user != null) {
      await user.updateDisplayName(data['displayName']);
    }
    notifyListeners();
  }

  // =========================================================================
  // FOLLOWERS / FOLLOWING
  // =========================================================================
  Future<void> followUser(String targetUid) async {
    if (_uid == null || _uid == targetUid) return;
    final batch = _db.batch();
    batch.update(_usersCol.doc(_uid), {
      'following': FieldValue.arrayUnion([targetUid]),
    });
    batch.update(_usersCol.doc(targetUid), {
      'followers': FieldValue.arrayUnion([_uid]),
    });
    await batch.commit();
    notifyListeners();
  }

  Future<void> unfollowUser(String targetUid) async {
    if (_uid == null) return;
    final batch = _db.batch();
    batch.update(_usersCol.doc(_uid), {
      'following': FieldValue.arrayRemove([targetUid]),
    });
    batch.update(_usersCol.doc(targetUid), {
      'followers': FieldValue.arrayRemove([_uid]),
    });
    await batch.commit();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getFollowers([String? uid]) async {
    final profile = await getProfile(uid);
    if (profile == null) return [];
    final ids = List<String>.from(profile['followers'] ?? []);
    final results = <Map<String, dynamic>>[];
    for (final id in ids) {
      final p = await getProfile(id);
      if (p != null) results.add(p);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getFollowing([String? uid]) async {
    final profile = await getProfile(uid);
    if (profile == null) return [];
    final ids = List<String>.from(profile['following'] ?? []);
    final results = <Map<String, dynamic>>[];
    for (final id in ids) {
      final p = await getProfile(id);
      if (p != null) results.add(p);
    }
    return results;
  }

  // =========================================================================
  // EVENTS
  // =========================================================================
  CollectionReference get _eventsCol => _db.collection('events');

  Stream<List<CommunityEvent>> eventsStream() {
    return _eventsCol
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data()! as Map<String, dynamic>;
              return CommunityEvent(
                id: d.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                organizer: data['organizer'] ?? '',
                dateTime: (data['dateTime'] as Timestamp).toDate(),
                location: data['location'] ?? '',
                category: data['category'] ?? 'Social',
                attendees: data['attendees'] ?? 0,
                maxAttendees: data['maxAttendees'] ?? 20,
              );
            }).toList());
  }

  Future<void> addEvent(CommunityEvent event) async {
    await _eventsCol.add({
      'title': event.title,
      'description': event.description,
      'organizer': event.organizer,
      'dateTime': Timestamp.fromDate(event.dateTime),
      'location': event.location,
      'category': event.category,
      'attendees': event.attendees,
      'maxAttendees': event.maxAttendees,
      'createdBy': _uid,
      'joinedBy': <String>[],
    });
  }

  Future<void> toggleEventJoin(String eventId) async {
    if (_uid == null) return;
    final ref = _eventsCol.doc(eventId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data()! as Map<String, dynamic>;
    final joined = List<String>.from(data['joinedBy'] ?? []);
    if (joined.contains(_uid)) {
      joined.remove(_uid);
    } else {
      joined.add(_uid!);
    }
    await ref.update({'joinedBy': joined, 'attendees': joined.length});
  }

  bool hasJoinedEvent(Map<String, dynamic> eventData) {
    final joined = List<String>.from(eventData['joinedBy'] ?? []);
    return joined.contains(_uid);
  }

  Stream<List<String>> joinedEventIdsStream() {
    return _eventsCol.snapshots().map((snap) {
      return snap.docs
          .where((d) {
            final data = d.data()! as Map<String, dynamic>;
            final joined = List<String>.from(data['joinedBy'] ?? []);
            return joined.contains(_uid);
          })
          .map((d) => d.id)
          .toList();
    });
  }

  // =========================================================================
  // RESOURCES & HOBBIES
  // =========================================================================
  CollectionReference get _resourcesCol => _db.collection('resources');

  Stream<List<ResourceListing>> resourcesStream({bool? hobbiesOnly}) {
    return _resourcesCol
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) {
      var list = snap.docs.map((d) {
        final data = d.data()! as Map<String, dynamic>;
        return ResourceListing(
          id: d.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          ownerName: data['ownerName'] ?? '',
          ownerAvatar: data['ownerAvatar'] ?? '',
          category: ResourceCategory.values.firstWhere(
            (c) => c.name == (data['category'] ?? 'tools'),
            orElse: () => ResourceCategory.tools,
          ),
          isAvailable: data['isAvailable'] ?? true,
          postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      if (hobbiesOnly == true) {
        list = list
            .where((r) =>
                r.category == ResourceCategory.hobbies ||
                r.category == ResourceCategory.sports)
            .toList();
      } else if (hobbiesOnly == false) {
        list = list
            .where((r) =>
                r.category != ResourceCategory.hobbies &&
                r.category != ResourceCategory.sports)
            .toList();
      }
      return list;
    });
  }

  Future<void> addResource(ResourceListing resource) async {
    await _resourcesCol.add({
      'title': resource.title,
      'description': resource.description,
      'ownerName': resource.ownerName,
      'ownerAvatar': resource.ownerAvatar,
      'category': resource.category.name,
      'isAvailable': resource.isAvailable,
      'postedAt': Timestamp.fromDate(resource.postedAt),
      'createdBy': _uid,
    });
  }

  // =========================================================================
  // FEED POSTS
  // =========================================================================
  CollectionReference get _feedCol => _db.collection('feed');

  Stream<List<FeedPost>> feedStream() {
    return _feedCol
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data()! as Map<String, dynamic>;
              return FeedPost(
                id: d.id,
                authorName: data['authorName'] ?? '',
                authorAvatar: data['authorAvatar'] ?? '',
                content: data['content'] ?? '',
                type: PostType.values.firstWhere(
                  (t) => t.name == (data['type'] ?? 'update'),
                  orElse: () => PostType.update,
                ),
                timestamp:
                    (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                likes: data['likes'] ?? 0,
                comments: data['comments'] ?? 0,
                location: data['location'],
              );
            }).toList());
  }

  // =========================================================================
  // CHATS
  // =========================================================================
  CollectionReference get _chatsCol => _db.collection('chats');

  /// Get or create a 1-to-1 chat thread.
  Future<String> getOrCreateChat(String otherUserName,
      {String? relatedListingId}) async {
    if (_uid == null) throw Exception('Not signed in');

    // Check for existing chat with this person name (simple approach)
    final existing = await _chatsCol
        .where('participants', arrayContains: _uid)
        .get();

    for (final doc in existing.docs) {
      final data = doc.data()! as Map<String, dynamic>;
      if (data['otherUserName'] == otherUserName &&
          data['createdBy'] == _uid) {
        return doc.id;
      }
    }

    // Create new chat
    final ref = await _chatsCol.add({
      'createdBy': _uid,
      'participants': [_uid],
      'otherUserName': otherUserName,
      'relatedListingId': relatedListingId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot> chatsStream() {
    if (_uid == null) return const Stream.empty();
    return _chatsCol
        .where('participants', arrayContains: _uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getChatById(String chatId) async {
    final snap = await _chatsCol.doc(chatId).get();
    if (!snap.exists) return null;
    return {'id': snap.id, ...snap.data()! as Map<String, dynamic>};
  }

  Stream<QuerySnapshot> messagesStream(String chatId) {
    return _chatsCol
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String text) async {
    if (_uid == null) return;
    final user = FirebaseAuth.instance.currentUser;
    await _chatsCol.doc(chatId).collection('messages').add({
      'senderId': _uid,
      'senderName': user?.displayName ?? 'Me',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _chatsCol.doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================================
  // SEED — Populate Firestore with initial data (one-time)
  // =========================================================================
  Future<void> seedIfEmpty() async {
    // Check if events already seeded
    final eventsSnap = await _eventsCol.limit(1).get();
    if (eventsSnap.docs.isNotEmpty) return; // Already seeded

    debugPrint('FirestoreService: Seeding initial data...');

    // Seed events
    final events = [
      CommunityEvent(id: '1', title: 'Morning Yoga in the Park', description: 'Free yoga session for all ages. Bring your own mat.', organizer: 'Wellness Circle', dateTime: DateTime.now().add(const Duration(days: 1, hours: 6)), location: 'Central Park Lawn', category: 'Health & Wellness', attendees: 18, maxAttendees: 30),
      CommunityEvent(id: '2', title: 'Weekend Farmers Market', description: 'Fresh organic produce, homemade preserves, artisan bread.', organizer: 'Green Earth Co-op', dateTime: DateTime.now().add(const Duration(days: 2, hours: 7)), location: 'Community Ground', category: 'Market', attendees: 45, maxAttendees: 100),
      CommunityEvent(id: '3', title: 'Kids Art Workshop', description: 'Painting and craft for children ages 5-12. Materials provided.', organizer: 'Creative Minds Studio', dateTime: DateTime.now().add(const Duration(days: 3, hours: 10)), location: 'Community Hall - Room B', category: 'Education', attendees: 12, maxAttendees: 15),
      CommunityEvent(id: '4', title: 'Neighborhood Cleanup Drive', description: 'Monthly cleanup. Gloves, bags, and refreshments provided.', organizer: 'Clean Streets Initiative', dateTime: DateTime.now().add(const Duration(days: 5, hours: 8)), location: 'Starting Point: Main Gate', category: 'Civic', attendees: 22, maxAttendees: 50),
    ];
    for (final e in events) {
      await addEvent(e);
    }

    // Seed resources
    final resources = [
      ResourceListing(id: '1', title: 'Power Drill & Bit Set', description: 'Bosch cordless drill available for borrowing.', ownerName: 'Suresh P.', ownerAvatar: 'SP', category: ResourceCategory.tools, isAvailable: true, postedAt: DateTime.now().subtract(const Duration(days: 2))),
      ResourceListing(id: '2', title: 'Guitar Lessons', description: 'Free acoustic guitar lessons for beginners on weekends.', ownerName: 'Aditya M.', ownerAvatar: 'AM', category: ResourceCategory.skills, isAvailable: true, postedAt: DateTime.now().subtract(const Duration(days: 1))),
      ResourceListing(id: '3', title: 'Photography Walk Group', description: 'Looking for fellow photography enthusiasts for weekend walks.', ownerName: 'Kavya S.', ownerAvatar: 'KS', category: ResourceCategory.hobbies, isAvailable: true, postedAt: DateTime.now().subtract(const Duration(days: 3))),
      ResourceListing(id: '4', title: 'Book Collection - Fiction', description: '50+ novels available for exchange. Mostly literary fiction.', ownerName: 'Nandini R.', ownerAvatar: 'NR', category: ResourceCategory.books, isAvailable: true, postedAt: DateTime.now().subtract(const Duration(days: 5))),
      ResourceListing(id: '5', title: 'Badminton Partner Wanted', description: 'Looking for a regular badminton partner. Community court 6-7 PM.', ownerName: 'Ajay T.', ownerAvatar: 'AT', category: ResourceCategory.sports, isAvailable: true, postedAt: DateTime.now().subtract(const Duration(days: 1))),
    ];
    for (final r in resources) {
      await addResource(r);
    }

    // Seed feed posts
    final posts = [
      {'authorName': 'Meera Joshi', 'authorAvatar': 'MJ', 'content': 'Water supply will be disrupted tomorrow from 10 AM to 4 PM in Block C and D. Please store water.', 'type': 'alert', 'likes': 34, 'comments': 12, 'location': 'Block C & D'},
      {'authorName': 'Arjun Nair', 'authorAvatar': 'AN', 'content': 'Does anyone have a ladder I could borrow for the weekend? Need to fix my terrace railing.', 'type': 'helpRequest', 'likes': 8, 'comments': 5, 'location': 'Sector 4'},
      {'authorName': 'Lakshmi Reddy', 'authorAvatar': 'LR', 'content': 'The new pedestrian crossing near the school on 3rd Main has been completed! Great work.', 'type': 'news', 'likes': 67, 'comments': 15, 'location': '3rd Main Road'},
      {'authorName': 'Vikram Singh', 'authorAvatar': 'VS', 'content': 'Stray dog pack alert near the park entrance on 7th Cross. Please be careful.', 'type': 'alert', 'likes': 45, 'comments': 22, 'location': '7th Cross Park'},
      {'authorName': 'Deepa Menon', 'authorAvatar': 'DM', 'content': 'Started a small herb garden on my balcony! Happy to share basil and mint saplings.', 'type': 'update', 'likes': 52, 'comments': 18, 'location': null},
    ];
    for (final p in posts) {
      await _feedCol.add({
        ...p,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    debugPrint('FirestoreService: Seeding complete.');
  }
}
