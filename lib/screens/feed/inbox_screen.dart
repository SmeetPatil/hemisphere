import 'package:flutter/material.dart';
import '../../data/mock_database.dart';
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
      body: AnimatedBuilder(
        animation: MockDatabase.instance,
        builder: (context, _) {
          final chats = MockDatabase.instance.chats;
          if (chats.isEmpty) {
            return Center(
              child: Text(
                'No messages yet.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
              ),
            );
          }
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => Divider(color: context.h.divider),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final lastMsg = chat.messages.isNotEmpty ? chat.messages.last.text : 'New chat started';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.yellow,
                  child: Text(chat.otherUserName.substring(0, 1).toUpperCase()),
                ),
                title: Text(
                  chat.otherUserName,
                  style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary),
                ),
                subtitle: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreen(chatId: chat.id),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
