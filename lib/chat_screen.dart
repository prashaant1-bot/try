import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String dateId;

  const ChatScreen({super.key, required this.dateId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('discussion_rooms')
        .doc(widget.dateId)
        .collection('messages')
        .add({
          'message': text,
          'name': user?.displayName ?? "Aspirant",
          'uid': user?.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Discussion Room")),

      body: Column(
        children: [
          // 🔥 MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('discussion_rooms')
                  .doc(widget.dateId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Text("Be the first to start discussion"),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final isMe = data['uid'] == currentUid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        padding: EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              data['name'] ?? "User",

                              style: TextStyle(
                                fontWeight: FontWeight.bold,

                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              data['message'] ?? "",

                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔥 MESSAGE INPUT
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,

                    decoration: InputDecoration(
                      hintText: "Enter your thoughts...",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10),

                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),

                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
