import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  String _otherUserName = '...';
  String? _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser?.uid;
    _loadChatInfo();
  }

  Future<void> _loadChatInfo() async {
    final chat = await FirestoreService.instance.getChatById(widget.chatId);
    if (!mounted || chat == null) return;
    setState(() {
      _otherUserName = chat['otherUserName'] ?? 'User';
    });
  }

  void _send() {
    if (_msgController.text.trim().isEmpty) return;
    FirestoreService.instance.sendMessage(widget.chatId, _msgController.text.trim());
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.h.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.h.surface,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.yellow,
              radius: 22,
              child: Text(
                _otherUserName.isNotEmpty
                    ? _otherUserName[0].toUpperCase()
                    : '?',
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.black),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _otherUserName,
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 22, color: context.h.textPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online',
                      style: AppTextStyles.labelMedium.copyWith(
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
          icon: Icon(Icons.arrow_back_rounded,
              color: context.h.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.instance.messagesStream(widget.chatId),
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
                      'No messages yet. Say hi!',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: context.h.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    final isMe = data['senderId'] == _myUid;
                    final timestamp =
                        (data['timestamp'] as Timestamp?)?.toDate();

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppColors.yellow
                                  : context.h.card,
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
                            child: Text(
                              data['text'] ?? '',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isMe
                                    ? AppColors.black
                                    : context.h.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (timestamp != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                      horizontal: 4)
                                  .copyWith(bottom: 12),
                              child: Text(
                                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
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
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16).copyWith(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: context.h.card,
              border: Border(top: BorderSide(color: AppColors.black, width: 2)),
              boxShadow: const [
                BoxShadow(color: AppColors.black, offset: Offset(0, -4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.h.inputFill,
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
                    child: TextField(
                      controller: _msgController,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: context.h.textPrimary, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.bodyLarge
                            .copyWith(color: context.h.textCaption),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.black,
                        blurRadius: 0,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: AppColors.black, size: 22),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
