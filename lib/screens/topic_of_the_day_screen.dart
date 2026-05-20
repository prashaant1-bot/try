import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/chat_screen.dart';
import 'package:my_first_app/screens/full_essay_screen.dart';
import 'package:my_first_app/submission.dart';

////////////////////////////////////////////////////////////
/// 📝 TOPIC OF THE DAY SCREEN//////////////////////////////////
////////////////////////////////////////////////////////////

class EssayDetailScreen extends StatelessWidget {
  final String date;

  const EssayDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(date)),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Topic Card
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Topic of the Day",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 8),

                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('topics')
                          .doc(date)
                          .get(),

                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final data = snapshot.data!.data();

                        if (data == null) {
                          return Text("No topic available");
                        }

                        final topic = data['topic'] ?? "";

                        final dimensions = List<String>.from(
                          data['dimensions'] ?? [],
                        );

                        final currentAffairs = List<String>.from(
                          data['currentAffairs'] ?? [],
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔥 TOPIC
                            Text(
                              topic,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            // 🔥 DIMENSIONS
                            Text(
                              "Suggested Dimensions",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            SizedBox(height: 5),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: dimensions.map((dimension) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "• ",
                                        style: TextStyle(fontSize: 13),
                                      ),

                                      Expanded(
                                        child: Text(
                                          dimension,
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                            SizedBox(height: 10),

                            // 🔥 CURRENT AFFAIRS
                            Text(
                              "Current Affairs Connections",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            SizedBox(height: 5),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: currentAffairs.map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 0),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("• "),

                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 5),

              // 🔥 Upload Button
              Row(
                children: [
                  // 🔥 Upload Essay Button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.upload_file),
                      label: Text("Upload Essay"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EssayScreen(date: date),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 10),

                  // 🔥 Community Chat Button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.chat),
                      label: Text("Discussion Room"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(dateId: date),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3),

              // 🔥 TOP SCORERS TITLE
              Text(
                "Top Scorers",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              // 🔥 TOP SCORERS LIST
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('essays')
                    .doc(date)
                    .collection('submissions')
                    .orderBy('score', descending: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No submissions yet"),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),

                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      final data = docs[index];

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 1),

                        padding: EdgeInsets.all(1),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),

                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5),
                          ],
                        ),

                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullEssayScreen(data: data),
                              ),
                            );
                          },

                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text("${index + 1}"),
                          ),

                          title: Text(
                            data['name'] ?? "User",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text(
                            data['essay'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          trailing: Text(
                            "${data['score']}/20",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
