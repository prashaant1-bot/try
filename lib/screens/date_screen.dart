import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/screens/topic_of_the_day_screen.dart';

////////////////////////////////////////////////////////////
/// 📅 DATE SCREEN
////////////////////////////////////////////////////////////

class DateScreen extends StatelessWidget {
  const DateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Date")),

      ////////////////////////////////////////////////////////////
      /// 🔥 FETCH TOPICS IN LATEST-FIRST ORDER
      ////////////////////////////////////////////////////////////
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('topics')
            // 🔥 NEWEST DATE FIRST
            .orderBy('timestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          ////////////////////////////////////////////////////////////
          /// 🔄 LOADING
          ////////////////////////////////////////////////////////////

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          ////////////////////////////////////////////////////////////
          /// ❌ ERROR
          ////////////////////////////////////////////////////////////

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          ////////////////////////////////////////////////////////////
          /// 📭 EMPTY
          ////////////////////////////////////////////////////////////

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No topics available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          ////////////////////////////////////////////////////////////
          /// 📚 FIRESTORE DOCS
          ////////////////////////////////////////////////////////////

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),

            itemCount: docs.length,

            itemBuilder: (context, index) {
              final doc = docs[index];

              final data = doc.data() as Map<String, dynamic>;

              //////////////////////////////////////////////////////
              /// 📅 DATE FROM DOCUMENT ID
              //////////////////////////////////////////////////////

              final String currentDate = doc.id;

              //////////////////////////////////////////////////////
              /// 📝 TOPIC
              //////////////////////////////////////////////////////

              final String topic = data['topic'] ?? "No topic available";

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                elevation: 4,

                margin: const EdgeInsets.only(bottom: 14),

                child: InkWell(
                  borderRadius: BorderRadius.circular(18),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EssayDetailScreen(date: currentDate),
                      ),
                    );
                  },

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        ////////////////////////////////////////////////////
                        /// 📅 DATE ROW
                        ////////////////////////////////////////////////////
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                              size: 18,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              currentDate,

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        ////////////////////////////////////////////////////
                        /// 📝 TOPIC TEXT
                        ////////////////////////////////////////////////////
                        Text(
                          topic,

                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
