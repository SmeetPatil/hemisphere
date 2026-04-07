import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/community_event.dart';
import '../models/resource_listing.dart';
import '../models/feed_post.dart';
import '../models/map_marker.dart';
import 'package:latlong2/latlong.dart';

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
        'homeNeighborhoodId': null,
        'homeLatitude': null,
        'homeLongitude': null,
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
  Future<void> setHomeLocation(double latitude, double longitude, String? neighborhoodId) async {
    if (_uid == null) return;
    await _usersCol.doc(_uid).update({
      'homeLatitude': latitude,
      'homeLongitude': longitude,
      'homeNeighborhoodId': neighborhoodId,
    });
    notifyListeners();
  }
  // =========================================================================
  // EMISSIONS LOGS
  // =========================================================================
  CollectionReference get _emissionsCol => _db.collection('user_emissions');

  Future<void> logVehicleEmission({
    required double totalEmissionGrams,
    required String model,
    required String year,
    required double daysUsed,
    required double hoursPerDay,
  }) async {
    if (_uid == null) return;
    await _emissionsCol.add({
      'userId': _uid,
      'timestamp': FieldValue.serverTimestamp(),
      'totalEmissionGrams': totalEmissionGrams,
      'vehicleModel': model,
      'vehicleYear': year,
      'daysUsed': daysUsed,
      'hoursPerDay': hoursPerDay,
    });
  }

  Stream<QuerySnapshot> emissionsStream() {
    if (_uid == null) return const Stream.empty();
    return _emissionsCol
        .where('userId', isEqualTo: _uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
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

  Stream<List<CommunityEvent>> eventsStream({String? neighborhoodId}) {
    Query query = _eventsCol;
    if (neighborhoodId != null) {
      query = query.where('neighborhoodId', isEqualTo: neighborhoodId);
    }
    return query
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
                neighborhoodId: data['neighborhoodId'],
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
      'neighborhoodId': event.neighborhoodId,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'createdBy': _uid,
      'joinedBy': <String>[],
    });

    if (event.latitude != null && event.longitude != null) {
      await addMapMarker(MapMarkerData(
        id: '',
        title: event.title,
        description: event.description,
        position: LatLng(event.latitude!, event.longitude!),
        type: MarkerType.communityEvent,
        timestamp: DateTime.now(),
        reportedBy: event.organizer,
        neighborhoodId: event.neighborhoodId,
      ));
    }
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
  CollectionReference get _hobbiesCol => _db.collection('hobbies');

  Stream<List<ResourceListing>> resourcesStream({bool? hobbiesOnly, String? neighborhoodId}) {
    Query query = hobbiesOnly == true ? _hobbiesCol : _resourcesCol;
    if (neighborhoodId != null) {
      query = query.where('neighborhoodId', isEqualTo: neighborhoodId);
    }

    return query
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
          neighborhoodId: data['neighborhoodId'],
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
    final col = (resource.category == ResourceCategory.hobbies || resource.category == ResourceCategory.sports) 
        ? _hobbiesCol 
        : _resourcesCol;
    
    await col.add({
      'title': resource.title,
      'description': resource.description,
      'ownerName': resource.ownerName,
      'ownerAvatar': resource.ownerAvatar,
      'category': resource.category.name,
      'isAvailable': resource.isAvailable,
      'postedAt': Timestamp.fromDate(resource.postedAt),
      'neighborhoodId': resource.neighborhoodId,
      'latitude': resource.latitude,
      'longitude': resource.longitude,
      'createdBy': _uid,
    });

    if (resource.latitude != null && resource.longitude != null) {
      await addMapMarker(MapMarkerData(
        id: '',
        title: resource.title,
        description: resource.description,
        position: LatLng(resource.latitude!, resource.longitude!),
        type: (resource.category == ResourceCategory.hobbies || resource.category == ResourceCategory.sports) ? MarkerType.hobby : MarkerType.sharedResource,
        timestamp: DateTime.now(),
        reportedBy: resource.ownerName,
        neighborhoodId: resource.neighborhoodId,
      ));
    }
  }

  Future<List<CommunityEvent>> getUserEvents() async {
    if (_uid == null) return [];
    final snap = await _eventsCol.where('createdBy', isEqualTo: _uid).get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CommunityEvent(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        organizer: data['organizer'] ?? '',
        dateTime: (data['dateTime'] as Timestamp).toDate(),
        location: data['location'] ?? '',
        category: data['category'] ?? 'Social',
        attendees: data['attendees'] ?? 0,
        maxAttendees: data['maxAttendees'] ?? 20,
        neighborhoodId: data['neighborhoodId'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
      );
    }).toList();
  }

  Future<List<ResourceListing>> getUserResources() async {
    if (_uid == null) return [];
    final resSnap = await _resourcesCol.where('createdBy', isEqualTo: _uid).get();
    final hobSnap = await _hobbiesCol.where('createdBy', isEqualTo: _uid).get();
    
    final List<ResourceListing> combined = [];
    
    for (var doc in resSnap.docs) {
      combined.add(_parseResource(doc));
    }
    for (var doc in hobSnap.docs) {
      combined.add(_parseResource(doc));
    }
    
    return combined;
  }

  ResourceListing _parseResource(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceListing(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerName: data['ownerName'] ?? 'Unknown',
      ownerAvatar: data['ownerAvatar'] ?? '',
      category: ResourceCategory.values.firstWhere(
        (c) => c.name == (data['category'] ?? 'tools'),
        orElse: () => ResourceCategory.tools,
      ),
      isAvailable: data['isAvailable'] ?? true,
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      neighborhoodId: data['neighborhoodId'],
    );
  }

  Future<List<FeedPost>> getUserFeedPosts() async {
    if (_uid == null) return [];
    final snap = await _feedCol.where('createdBy', isEqualTo: _uid).get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FeedPost(
        id: doc.id,
        authorName: data['authorName'] ?? 'Anonymous',
        authorAvatar: data['authorAvatar'] ?? '',
        content: data['content'] ?? '',
        type: PostType.values.firstWhere(
          (t) => t.name == (data['type'] ?? 'update'),
          orElse: () => PostType.update,
        ),
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        likes: data['likes'] ?? 0,
        comments: data['comments'] ?? 0,
        location: data['location'],
      );
    }).toList();
  }

  Future<void> deleteUserPost(String docId, String type, {bool isHobby = false}) async {
    if (type == 'event') {
      await _eventsCol.doc(docId).delete();
    } else if (type == 'resource') {
      if (isHobby) {
        await _hobbiesCol.doc(docId).delete();
      } else {
        await _resourcesCol.doc(docId).delete();
      }
    } else if (type == 'feed') {
      await _feedCol.doc(docId).delete();
    }
  }

  // =========================================================================
  // FEED POSTS
  // =========================================================================
  CollectionReference get _feedCol => _db.collection('feed');

  Stream<List<FeedPost>> feedStream({String? neighborhoodId}) {
    Query query = _feedCol;
    if (neighborhoodId != null) {
      query = query.where('neighborhoodId', isEqualTo: neighborhoodId);
    }
    return query
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
                neighborhoodId: data['neighborhoodId'],
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
  // MAP MARKERS
  // =========================================================================
  CollectionReference get _mapMarkersCol => _db.collection('map_markers');

  Stream<List<MapMarkerData>> mapMarkersStream({String? neighborhoodId}) {
    Query query = _mapMarkersCol;
    if (neighborhoodId != null) {
      query = query.where('neighborhoodId', isEqualTo: neighborhoodId);
    }
    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data()! as Map<String, dynamic>;
              return MapMarkerData(
                id: d.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                position: LatLng(data['lat'] ?? 0.0, data['lng'] ?? 0.0),
                type: MarkerType.values.firstWhere(
                  (t) => t.name == (data['type'] ?? 'accident'),
                  orElse: () => MarkerType.accident,
                ),
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                reportedBy: data['reportedBy'] ?? 'Unknown',
                neighborhoodId: data['neighborhoodId'],
              );
            }).toList());
  }

  Future<void> addMapMarker(MapMarkerData marker) async {
    await _mapMarkersCol.add({
      'title': marker.title,
      'description': marker.description,
      'lat': marker.position.latitude,
      'lng': marker.position.longitude,
      'type': marker.type.name,
      'timestamp': Timestamp.fromDate(marker.timestamp),
      'reportedBy': marker.reportedBy,
      'neighborhoodId': marker.neighborhoodId,
      'createdBy': _uid,
    });
  }

  Future<void> addReportAndFeed({
    required String? neighborhoodId,
    required MapMarkerData markerData,
    required FeedPost feedData,
  }) async {
    final batch = _db.batch();

    final markerRef = _mapMarkersCol.doc();
    batch.set(markerRef, {
      'title': markerData.title,
      'description': markerData.description,
      'lat': markerData.position.latitude,
      'lng': markerData.position.longitude,
      'type': markerData.type.name,
      'timestamp': Timestamp.fromDate(markerData.timestamp),
      'reportedBy': markerData.reportedBy,
      'neighborhoodId': neighborhoodId,
      'createdBy': _uid,
    });

    final feedRef = _feedCol.doc();
    batch.set(feedRef, {
      'authorName': feedData.authorName,
      'authorAvatar': feedData.authorAvatar,
      'content': feedData.content,
      'type': feedData.type.name,
      'timestamp': Timestamp.fromDate(feedData.timestamp),
      'likes': feedData.likes,
      'comments': feedData.comments,
      'location': feedData.location,
      'neighborhoodId': neighborhoodId,
      'createdBy': _uid,
    });

    await batch.commit();
  }
}
