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
  void _showNewMessageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewMessageSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                    height: 155, // Clips the bottom to prevent overlapping the list
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
                                style: AppTextStyles.displayLarge
                                    .copyWith(color: context.h.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TabEntryAnimator(
                              tabIndex: 3,
                              delayMs: 40,
                              child: Text(
                                'Connect with new People',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: context.h.textSecondary),
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
                            border: Border.all(color: AppColors.black, width: 2),
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
                      child: Text('Please log in to see messages.', style: TextStyle(color: Colors.white)),
                    );
                  }
                  
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService.instance.chatsStream(),
                    builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.yellow),
                    );
                  }
                  final unsortedDocs = snapshot.data?.docs ?? [];
                  final docs = unsortedDocs.toList()
                    ..sort((a, b) {
                      final aData = a.data()! as Map<String, dynamic>;
                      final bData = b.data()! as Map<String, dynamic>;
                      final aTime = aData['lastMessageAt'] as Timestamp?;
                      final bTime = bData['lastMessageAt'] as Timestamp?;
                      return (bTime ?? Timestamp(0, 0)).compareTo(aTime ?? Timestamp(0, 0));
                    });

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: context.h.textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: AppTextStyles.headlineSmall
                                .copyWith(color: context.h.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: context.h.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final data = docs[index].data()! as Map<String, dynamic>;
                      final chatId = docs[index].id;
                      final otherName = data['otherUserName'] ?? 'User';
                      final lastMsg = (data['lastMessage'] ?? '').toString();
                      final display = lastMsg.isEmpty ? 'Start conversation' : lastMsg;
                      
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: chatId),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: context.h.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.black, width: 2),
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
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.yellow,
                                child: Text(
                                  otherName.isNotEmpty
                                      ? otherName.substring(0, 1).toUpperCase()
                                      : '?',
                                  style: AppTextStyles.headlineMedium
                                      .copyWith(color: AppColors.black),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      otherName,
                                      style: AppTextStyles.labelLarge
                                          .copyWith(color: context.h.textPrimary, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      display,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(color: context.h.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: context.h.iconSubtle,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
  __NewMessageSheetState createState() => __NewMessageSheetState();
}

class __NewMessageSheetState extends State<_NewMessageSheet> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendNewMessage() async {
    final recipient = _recipientController.text.trim();
    final message = _messageController.text.trim();

    if (recipient.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipient and message.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final chatId = await FirestoreService.instance.getOrCreateChat(recipient);
      await FirestoreService.instance.sendMessage(chatId, message);
      
      if (!mounted) return;
      Navigator.pop(context); // Close the bottom sheet
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
        color: context.h.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.h.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Message',
                style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary),
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
          TextField(
            controller: _recipientController,
            style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
            decoration: InputDecoration(
              hintText: 'Recipient Username',
              prefixIcon: Icon(Icons.person_outline_rounded, color: context.h.iconSubtle),
              filled: true,
              fillColor: context.h.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Type your message...',
              filled: true,
              fillColor: context.h.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendNewMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
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
                    'Send Message',
                    style: AppTextStyles.buttonLarge.copyWith(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}
