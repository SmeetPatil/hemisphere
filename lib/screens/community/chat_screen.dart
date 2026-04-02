import 'package:flutter/material.dart';
import '../../data/mock_database.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _send() {
    if (_msgController.text.trim().isEmpty) return;
    MockDatabase.instance.sendMessage(widget.chatId, _msgController.text.trim());
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockDatabase.instance,
      builder: (context, _) {
        final chat = MockDatabase.instance.chats.firstWhere((c) => c.id == widget.chatId);
        
        return Scaffold(
          backgroundColor: context.h.surface,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: context.h.surface,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
                  radius: 18,
                  child: Text(
                    chat.otherUserName[0].toUpperCase(),
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.yellow),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.otherUserName,
                      style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Online',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.h.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chat.messages[index];
                    final isMe = msg.senderId == MockDatabase.instance.currentUserId;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.yellow : context.h.card,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomRight: isMe ? const Radius.circular(4) : null,
                                bottomLeft: !isMe ? const Radius.circular(4) : null,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              msg.text,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isMe ? AppColors.black : context.h.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4).copyWith(bottom: 12),
                            child: Text(
                              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.caption.copyWith(
                                color: context.h.textCaption,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12).copyWith(
                  bottom: 12 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: context.h.card,
                  border: Border(top: BorderSide(color: context.h.divider)),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: context.h.surface,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add_rounded, color: context.h.textSecondary),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.h.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: context.h.divider),
                        ),
                        child: TextField(
                          controller: _msgController,
                          style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.h.textCaption),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.black, size: 20),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
