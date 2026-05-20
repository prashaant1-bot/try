import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////
////////////////essay after submit screen////////////////////////////////////////////

class UserEssayDetailScreen extends StatelessWidget {
  final data;

  const UserEssayDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Essay Details")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOPIC
            Text(
              data['topic'] ?? "Essay",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // SCORE CARD
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.white),

                  SizedBox(width: 10),

                  Text(
                    "Score: ${data['score']}/20",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // ESSAY TITLE
            Text(
              "Your Essay",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),

              child: Text(
                data['essay'] ?? "",

                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            SizedBox(height: 25),

            // FEEDBACK TITLE
            Text(
              "AI Feedback",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(14),
              ),

              child: Text(
                data['feedback'] ?? "",

                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
