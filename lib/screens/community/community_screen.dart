import 'package:flutter/material.dart';
import '../../data/mock_database.dart';
import '../../models/resource_listing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/resource_card.dart';
import 'create_post_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Community', style: AppTextStyles.displayLarge.copyWith(color: context.h.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        'Connect, share, and grow together',
                        style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreatePostScreen(), fullscreenDialog: true),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.black, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.h.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
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
          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: AnimatedBuilder(
              animation: MockDatabase.instance,
              builder: (context, _) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _EventsTab(),
                    _ResourcesTab(),
                    _HobbiesTab(),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final events = MockDatabase.instance.events;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(
          event: events[index],
          onJoin: () {
            MockDatabase.instance.toggleEventJoin(events[index].id);
            final isJoined = MockDatabase.instance.hasJoinedEvent(events[index].id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isJoined ? 'Joined "${events[index].title}"!' : 'Left event'),
              ),
            );
          },
        );
      },
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final resources = MockDatabase.instance.resources
        .where((r) =>
            r.category != ResourceCategory.hobbies &&
            r.category != ResourceCategory.sports)
        .toList();
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        return ResourceCard(resource: resources[index]);
      },
    );
  }
}

class _HobbiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hobbies = MockDatabase.instance.resources
        .where((r) =>
            r.category == ResourceCategory.hobbies ||
            r.category == ResourceCategory.sports)
        .toList();
    return hobbies.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.palette_outlined, size: 64, color: context.h.divider),
                const SizedBox(height: 16),
                Text('No hobbies posted yet', style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Share a Hobby'),
                ),
              ],
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: hobbies.length,
            itemBuilder: (context, index) {
              return ResourceCard(resource: hobbies[index]);
            },
          );
  }
}
