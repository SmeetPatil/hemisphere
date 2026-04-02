import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../community/chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.instance.chatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No messages yet.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: context.h.textSecondary),
              ),
            );
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => Divider(color: context.h.divider),
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final chatId = docs[index].id;
              final otherName = data['otherUserName'] ?? 'User';
              final lastMsg = (data['lastMessage'] ?? '').toString();
              final display = lastMsg.isEmpty ? 'New chat started' : lastMsg;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.yellow,
                  child: Text(
                    otherName.isNotEmpty
                        ? otherName.substring(0, 1).toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(
                  otherName,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: context.h.textPrimary),
                ),
                subtitle: Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption
                      .copyWith(color: context.h.textCaption),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chatId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
