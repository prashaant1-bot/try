import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/screens/topic_of_the_day_screen.dart';

////////////////////////////////////////////////////////////
/// 📅 DATE SCREEN//////////////////////////////////////////
////////////////////////////////////////////////////////////

class DateScreen extends StatelessWidget {
  const DateScreen({super.key});

  List<String> generateDates() {
    List<String> dates = [];

    DateTime today = DateTime.now();

    for (int i = 0; i < 10; i++) {
      DateTime date = today.subtract(Duration(days: i));

      String formatted = "${date.day} ${_monthName(date.month)} ${date.year}";

      dates.add(formatted);
    }

    return dates;
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dates = generateDates();

    return Scaffold(
      appBar: AppBar(title: Text("Select Date")),

      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: dates.length,

        itemBuilder: (context, index) {
          final currentDate = dates[index];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('topics')
                .doc(currentDate)
                .get(),

            builder: (context, snapshot) {
              String topic = "Loading topic...";

              if (snapshot.hasData && snapshot.data!.data() != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>;

                topic = data['topic'] ?? "No topic available";
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                elevation: 4,

                margin: EdgeInsets.only(bottom: 14),

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
                    padding: EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 DATE ROW
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                              size: 18,
                            ),

                            SizedBox(width: 8),

                            Text(
                              currentDate,

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),

                            Spacer(),

                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                        SizedBox(height: 14),

                        // 🔥 TOPIC
                        Text(
                          topic,

                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
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
