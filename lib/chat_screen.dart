import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_ui_kit.dart';

class ChatScreen extends StatefulWidget {
  final String dateId;

  const ChatScreen({super.key, required this.dateId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  String? _replyToMessageId;
  String? _replyToPreview;

  CollectionReference<Map<String, dynamic>> get _messagesRef {
    return FirebaseFirestore.instance
        .collection('discussion_rooms')
        .doc(widget.dateId)
        .collection('messages');
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;
    final replyToMessageId = _replyToMessageId;
    final replyToPreview = _replyToPreview;
    await _sendMessagePayload({
      'type': 'text',
      'message': text,
      'replyToMessageId': replyToMessageId,
      'replyToPreview': replyToPreview,
    });

    messageController.clear();
    setState(() {
      _replyToMessageId = null;
      _replyToPreview = null;
    });
  }

  Future<void> _sendMessagePayload(Map<String, dynamic> payload) async {
    final user = _currentUser;
    await _messagesRef.add({
      ...payload,
      'name': user?.displayName ?? "Aspirant",
      'uid': user?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _showMessageActions(
    DocumentReference docRef,
    Map<String, dynamic> data,
    bool isMe,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply_outlined),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyToMessageId = docRef.id;
                    _replyToPreview = _previewText(data);
                  });
                },
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditMessageDialog(docRef, data);
                  },
                ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await docRef.delete();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleReaction(
    DocumentReference docRef,
    String reaction,
  ) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    final currentReaction = (await docRef.get()).get('reactions.$uid');
    if (currentReaction == reaction) {
      await docRef.update({'reactions.$uid': FieldValue.delete()});
      return;
    }
    await docRef.update({'reactions.$uid': reaction});
  }

  Widget _buildReactionsRow(
    Map<String, dynamic> data,
    DocumentReference docRef,
    bool isMe,
  ) {
    final reactionMap = Map<String, dynamic>.from(data['reactions'] ?? {});
    final uid = _currentUser?.uid;
    final myReaction = uid == null ? null : reactionMap[uid]?.toString();

    final counts = <String, int>{'like': 0};
    for (final value in reactionMap.values) {
      if (value.toString() == 'like') {
        counts['like'] = counts['like']! + 1;
      }
    }

    final textColor = isMe ? Colors.white : Colors.black87;
    Widget reactionButton({
      required String keyName,
      required IconData icon,
      required Color activeColor,
    }) {
      final selected = myReaction == keyName;
      final scale = selected ? 1.1 : 1.0;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleReaction(docRef, keyName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withAlpha(45)
                : (isMe ? Colors.white24 : Colors.black12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? activeColor : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: scale),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: selected ? activeColor : textColor),
                const SizedBox(width: 4),
                Text(
                  '${counts[keyName] ?? 0}',
                  style: TextStyle(color: selected ? activeColor : textColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          reactionButton(
            keyName: 'like',
            icon: Icons.thumb_up_alt_rounded,
            activeColor: Colors.green.shade600,
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMessageDialog(
    DocumentReference docRef,
    Map<String, dynamic> data,
  ) async {
    final controller = TextEditingController(
      text: (data['message'] ?? '').toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit message'),
          content: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Edit text...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await docRef.update({
                  'message': controller.text.trim(),
                  'editedAt': FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _previewText(Map<String, dynamic> data) {
    final message = (data['message'] ?? '').toString();
    return message;
  }

  Widget _buildReplyPreview(Map<String, dynamic> data, bool isMe) {
    final replyToPreview = (data['replyToPreview'] ?? '').toString();
    if (replyToPreview.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white24 : Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        replyToPreview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMessageBody(Map<String, dynamic> data, bool isMe) {
    final textColor = isMe ? Colors.white : Colors.black;
    final message = (data['message'] ?? '').toString();
    return Text(message, style: TextStyle(color: textColor));
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Discussion Room")),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesRef
                  .orderBy('timestamp', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("Be the first to start discussion"),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docRef = docs[index].reference;
                    final isMe = data['uid'] == currentUid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () =>
                            _showMessageActions(docRef, data, isMe),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppChatPalette.bubbleMe
                                : AppChatPalette.bubbleOther,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? "User",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isMe
                                      ? AppChatPalette.bubbleMeText
                                      : AppChatPalette.bubbleOtherText,
                                ),
                              ),
                              const SizedBox(height: 5),
                              _buildReplyPreview(data, isMe),
                              _buildMessageBody(data, isMe),
                              _buildReactionsRow(data, docRef, isMe),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyToPreview != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.reply, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _replyToPreview!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _replyToMessageId = null;
                              _replyToPreview = null;
                            });
                          },
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Enter your thoughts...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.send, color: AppPalette.primary),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
