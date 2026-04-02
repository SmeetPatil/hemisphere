import 'package:flutter/material.dart';

import '../../data/mock_database.dart';
import '../../theme/app_theme.dart';
import '../community/chat_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _userIdFromName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  void _sendNewMessage() {
    final recipient = _recipientController.text.trim();
    final message = _messageController.text.trim();

    if (recipient.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add recipient and message.')),
      );
      return;
    }

    final chat = MockDatabase.instance.getOrCreateChat(
      _userIdFromName(recipient),
      recipient,
    );
    MockDatabase.instance.sendMessage(chat.id, message);

    _recipientController.clear();
    _messageController.clear();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inbox',
                  style: AppTextStyles.displayLarge
                      .copyWith(color: context.h.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'View conversations and send new messages',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: context.h.textSecondary),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.h.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.h.cardShadow,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _recipientController,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Recipient name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: context.h.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: context.h.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          filled: true,
                          fillColor: context.h.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendNewMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: AppColors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: AnimatedBuilder(
              animation: MockDatabase.instance,
              builder: (context, _) {
                final chats = MockDatabase.instance.chats;

                if (chats.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations yet. Send a message above.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: context.h.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final lastMessage = chat.messages.isNotEmpty
                        ? chat.messages.last.text
                        : 'Start conversation';

                    return Container(
                      decoration: BoxDecoration(
                        color: context.h.card,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: context.h.cardShadow,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.yellow,
                          child: Text(
                            chat.otherUserName.substring(0, 1).toUpperCase(),
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.black),
                          ),
                        ),
                        title: Text(
                          chat.otherUserName,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: context.h.textPrimary),
                        ),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.h.textCaption),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: context.h.iconSubtle,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: chat.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
