import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/community_event.dart';
import '../../models/resource_listing.dart';
import '../../providers/map_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/resource_card.dart';
import 'chat_screen.dart';
import 'create_post_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/tab_entry_animator.dart';
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  void _openChatWith(String personName, {String? relatedListingId}) async {
    final chatId = await FirestoreService.instance
        .getOrCreateChat(personName, relatedListingId: relatedListingId);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 50,
                top: -30,
                child: SizedBox(
                  width: 175,
                  height: 145, // Clips the bottom to prevent overlapping the Events tab
                  child: TabEntryAnimator(
                    tabIndex: 1,
                    delayMs: 50,
                    child: SvgPicture.asset(
                      'assets/images/community.svg',
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabEntryAnimator(
                            tabIndex: 1,
                            child: Text(
                              'Community',
                              style: AppTextStyles.displayLarge
                                  .copyWith(color: context.h.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          TabEntryAnimator(
                            tabIndex: 1,
                            delayMs: 40,
                            child: Text(
                              'Connect and grow together',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: context.h.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const CreatePostScreen(),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.black,
                              blurRadius: 0,
                              offset: Offset(4, 4),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.black,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.h.card,
              borderRadius: BorderRadius.circular(10), // Bento rounded
              border: Border.all(color: AppColors.black, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black,
                  blurRadius: 0,
                  offset: Offset(4, 4), // Sharp heavy bento drop shadow
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.black,
              unselectedLabelColor: context.h.textCaption,
              labelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 13),
              unselectedLabelStyle: AppTextStyles.labelMedium,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Events'),
                Tab(text: 'Resources'),
                Tab(text: 'Hobbies'),
              ],
            ),
          ),



          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EventsTab(
                  extraTopPadding: 8,
                  onMessageTap: (name, id) =>
                      _openChatWith(name, relatedListingId: id),
                ),
                _ResourcesTab(
                  extraTopPadding: 8,
                  onMessageTap: (name, id) =>
                      _openChatWith(name, relatedListingId: id),
                ),
                _HobbiesTab(
                  extraTopPadding: 8,
                  onMessageTap: (name, id) =>
                      _openChatWith(name, relatedListingId: id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tabs — now use Firestore streams
// ---------------------------------------------------------------------------

class _EventsTab extends StatelessWidget {
  final double extraTopPadding;
  final void Function(String personName, String relatedId) onMessageTap;

  const _EventsTab({required this.extraTopPadding, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityEvent>>(
      stream: FirestoreService.instance.eventsStream(
          neighborhoodId: MapProvider.instance.currentNeighborhoodId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Text('No events yet. Host one above.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20, extraTopPadding, 20, 18),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Column(
              children: [
                EventCard(
                  event: event,
                  isJoined: false,
                  messageText: 'Message ${event.organizer}',
                  onMessageTap: () => onMessageTap(event.organizer, event.id),
                  onJoin: () async {
                    await FirestoreService.instance.toggleEventJoin(event.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Toggled join for "${event.title}"')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  final double extraTopPadding;
  final void Function(String personName, String relatedId) onMessageTap;

  const _ResourcesTab({required this.extraTopPadding, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ResourceListing>>(
      stream: FirestoreService.instance.resourcesStream(
          hobbiesOnly: false,
          neighborhoodId: MapProvider.instance.currentNeighborhoodId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final resources = snapshot.data ?? [];
        if (resources.isEmpty) {
          return Center(
            child: Text('No resources shared yet.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20, extraTopPadding, 20, 18),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return ResourceCard(
              resource: resource,
              messageText: 'Message ${resource.ownerName}',
              onMessageTap: () => onMessageTap(resource.ownerName, resource.id),
            );
          },
        );
      },
    );
  }
}

class _HobbiesTab extends StatelessWidget {
  final double extraTopPadding;
  final void Function(String personName, String relatedId) onMessageTap;

  const _HobbiesTab({required this.extraTopPadding, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ResourceListing>>(
      stream: FirestoreService.instance.resourcesStream(
          hobbiesOnly: true,
          neighborhoodId: MapProvider.instance.currentNeighborhoodId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final hobbies = snapshot.data ?? [];
        if (hobbies.isEmpty) {
          return Center(
            child: Text('No hobbies shared yet.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20, extraTopPadding, 20, 18),
          itemCount: hobbies.length,
          itemBuilder: (context, index) {
            final hobby = hobbies[index];
            return ResourceCard(
              resource: hobby,
              messageText: 'Message ${hobby.ownerName}',
              onMessageTap: () => onMessageTap(hobby.ownerName, hobby.id),
            );
          },
        );
      },
    );
  }
}

