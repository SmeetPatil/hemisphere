import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../community/chat_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/tab_entry_animator.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool _isEditMode = false;
  List<String> _customOrder = [];

  void _showNewMessageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewMessageSheet(),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _isEditMode
            ? GestureDetector(
                onTap: _toggleEditMode,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.black,
                        blurRadius: 0,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
              )
            : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: 60,
                  top: -40,
                  child: SizedBox(
                    width: 150,
                    height:
                        155, // Clips the bottom to prevent overlapping the list
                    child: TabEntryAnimator(
                      tabIndex: 3,
                      delayMs: 50,
                      child: SvgPicture.asset(
                        'assets/images/inbox.svg',
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
                              tabIndex: 3,
                              child: Text(
                                'Messages',
                                style: AppTextStyles.displayLarge.copyWith(
                                  color: context.h.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TabEntryAnimator(
                              tabIndex: 3,
                              delayMs: 40,
                              child: Text(
                                'Connect with new People',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.h.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _showNewMessageSheet,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.black,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.black,
                                blurRadius: 0,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
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
            Expanded(
              child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, authSnap) {
                  if (authSnap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.yellow),
                    );
                  }
                  if (!authSnap.hasData) {
                    return const Center(
                      child: Text(
                        'Please log in to see messages.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService.instance.chatsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.yellow,
                          ),
                        );
                      }
                      final unsortedDocs = snapshot.data?.docs ?? [];
                      final docs = unsortedDocs.toList()
                        ..sort((a, b) {
                          final aData = a.data()! as Map<String, dynamic>;
                          final bData = b.data()! as Map<String, dynamic>;
                          final aTime = aData['lastMessageAt'] as Timestamp?;
                          final bTime = bData['lastMessageAt'] as Timestamp?;
                          return (bTime ?? Timestamp(0, 0)).compareTo(
                            aTime ?? Timestamp(0, 0),
                          );
                        });

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: context.h.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: context.h.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a conversation',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.h.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Align with custom order
                      final List<QueryDocumentSnapshot> customOrderedDocs = [];
                      final docMap = {for (var d in docs) d.id: d};
                      for (final id in _customOrder) {
                        if (docMap.containsKey(id)) {
                          customOrderedDocs.add(docMap[id]!);
                          docMap.remove(id);
                        }
                      }
                      customOrderedDocs.addAll(docMap.values);

                      // Update the local list strictly without triggering setState here
                      _customOrder = customOrderedDocs
                          .map((d) => d.id)
                          .toList();

                      Widget buildItem(BuildContext context, int index) {
                        final data =
                            customOrderedDocs[index].data()!
                                as Map<String, dynamic>;
                        final chatId = customOrderedDocs[index].id;

                        String otherName = 'User';
                        final pNames =
                            data['participantNames'] as Map<String, dynamic>?;
                        if (pNames != null) {
                          final myUid = FirebaseAuth.instance.currentUser?.uid;
                          final parts = List<String>.from(
                            data['participants'] ?? [],
                          );
                          final otherId = parts.firstWhere(
                            (p) => p != myUid,
                            orElse: () => '',
                          );
                          if (otherId.isNotEmpty) {
                            otherName = pNames[otherId] ?? 'User';
                          }
                        } else {
                          otherName = data['otherUserName'] ?? 'User';
                        }

                        final lastMsg = (data['lastMessage'] ?? '').toString();
                        final display = lastMsg.isEmpty
                            ? 'Start conversation'
                            : lastMsg;

                        Future<void> showNeoDialog() async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: context.h.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.black,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.black,
                                      blurRadius: 0,
                                      offset: Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delete Chat',
                                      style: AppTextStyles.headlineSmall
                                          .copyWith(
                                            color: context.h.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Are you sure you want to delete this conversation?',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: context.h.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: context.h.textSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.red,
                                            foregroundColor: AppColors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: const BorderSide(
                                                color: AppColors.black,
                                                width: 2,
                                              ),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          if (confirm == true) {
                            await FirestoreService.instance.deleteChat(chatId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Chat deleted')),
                              );
                            }
                          }
                        }

                        return InkWell(
                          key: ValueKey(chatId),
                          onTap: () {
                            if (_isEditMode) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(chatId: chatId),
                              ),
                            );
                          },
                          onLongPress: _isEditMode ? null : _toggleEditMode,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: context.h.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.black,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.black,
                                  blurRadius: 0,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                if (_isEditMode) ...[
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(
                                      Icons.drag_handle_rounded,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.yellow,
                                  child: Text(
                                    otherName.isNotEmpty
                                        ? otherName
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : '?',
                                    style: AppTextStyles.headlineMedium
                                        .copyWith(color: AppColors.black),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        otherName,
                                        style: AppTextStyles.labelLarge
                                            .copyWith(
                                              color: context.h.textPrimary,
                                              fontSize: 16,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        display,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: context.h.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isEditMode)
                                  GestureDetector(
                                    onTap: showNeoDialog,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.black,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: context.h.iconSubtle,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (_isEditMode) {
                        return ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: customOrderedDocs.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final item = _customOrder.removeAt(oldIndex);
                              _customOrder.insert(newIndex, item);
                            });
                          },
                          itemBuilder: buildItem,
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        itemCount: customOrderedDocs.length,
                        itemBuilder: buildItem,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewMessageSheet extends StatefulWidget {
  @override
  _NewMessageSheetState createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  Map<String, dynamic>? _selectedUser;
  bool _isLoading = false;

  Future<void> _startConversation() async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final otherUserId = _selectedUser!['id'] as String;
      final otherUserName =
          (_selectedUser!['displayName'] as String?)?.isNotEmpty == true
          ? _selectedUser!['displayName'] as String
          : (_selectedUser!['email'] as String?)?.split('@').first ?? 'User';

      final chatId = await FirestoreService.instance.getOrCreateChat(
        otherUserId,
        otherUserName,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close the bottom sheet
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: context.h.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Conversation',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: context.h.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: context.h.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) =>
                Autocomplete<Map<String, dynamic>>(
                  displayStringForOption: (option) =>
                      (option['displayName'] as String?)?.isNotEmpty == true
                      ? option['displayName'] as String
                      : (option['email'] as String? ?? 'User'),
                  optionsBuilder: (textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    return await FirestoreService.instance.searchUsers(
                      textEditingValue.text,
                    );
                  },
                  onSelected: (selection) {
                    setState(() {
                      _selectedUser = selection;
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.h.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search User by Name/Email...',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: context.h.iconSubtle,
                            ),
                            filled: true,
                            fillColor: context.h.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (val) {
                            if (_selectedUser != null) {
                              _selectedUser = null;
                            }
                          },
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.h.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.black,
                              blurRadius: 0,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              maxWidth: constraints.maxWidth,
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(8.0),
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: context.h.divider, height: 1),
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                final name =
                                    (option['displayName'] as String?)
                                            ?.isNotEmpty ==
                                        true
                                    ? option['displayName'] as String
                                    : (option['email'] as String? ?? 'User');

                                return ListTile(
                                  title: Text(
                                    name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: context.h.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    option['email'] ?? '',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: context.h.textSecondary,
                                    ),
                                  ),
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _startConversation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.black, width: 2),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Start Conversation',
                    style: AppTextStyles.buttonLarge.copyWith(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}
