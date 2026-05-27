import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/screens/essay_history_screen.dart';

//////////////////////////////////////////////////////////
//////////////dashboard screen//////////////////////////

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = fetchUserStats();
  }

  Future<Map<String, dynamic>> fetchUserStats() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    double total = 0;
    int count = 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('essays')
        .get();

    for (var doc in snapshot.docs) {
      final score = double.tryParse(doc['score'].toString()) ?? 0;

      total += score;
      count++;
    }

    double avg = count == 0 ? 0 : total / count;

    return {'total': total, 'count': count, 'avg': avg.toStringAsFixed(1)};
  }

  Future<void> refreshData() async {
    setState(() {
      statsFuture = fetchUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Dashboard")),

      body: RefreshIndicator(
        onRefresh: refreshData,

        child: FutureBuilder(
          future: statsFuture,
          builder: (context, snapshot) {
            // 🔄 LOADING
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // ❌ ERROR
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            // ⚠️ NO DATA
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("No data found"));
            }

            final data = snapshot.data as Map<String, dynamic>;

            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 TITLE
                  Text(
                    "Your Performance",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  // 🔥 CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _buildCard(
                          "Total Score",
                          data['total'],
                          Colors.blue,
                          Icons.bar_chart,
                        ),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: _buildCard(
                          "Essays",
                          data['count'],
                          Colors.green,
                          Icons.edit_note,
                        ),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: _buildCard(
                          "Average",
                          data['avg'],
                          Colors.orange,
                          Icons.trending_up,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.history),
                      label: Text("Essay History"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EssayHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔥 INSIGHT BOX
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Keep practicing daily. Consistency is your biggest advantage.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(String title, dynamic value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),

          SizedBox(height: 10),

          Text(
            "$value",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(title, style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
