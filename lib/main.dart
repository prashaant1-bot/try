import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("🔥 AUTH STATE CHANGED");
        print("========== UID: ${user.uid} ==========");
        print("Email: ${user.email}");
      } else {
        print("❌ User is logged out");
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F7FB),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : HomeScreen(),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////
///////////////////////login screen//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class LoginScreen extends StatelessWidget {
  Future<User?> signInWithGoogle() async {
    print("🔥 Google Sign-In function started");

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final user = userCredential.user;

    if (user != null) {
      final uid = user.uid;

      print("UID: $uid");
      print("Name: ${user.displayName}");
      print("Email: ${user.email}");

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      final doc = await userRef.get();

      if (!doc.exists) {
        await userRef.set({
          'name': user.displayName ?? "",
          'email': user.email ?? "",
          'photoUrl': user.photoURL ?? "",
          'createdAt': FieldValue.serverTimestamp(),
          'totalScore': 0,
        });

        print("✅ User saved in Firestore");
      } else {
        print("ℹ️ User already exists");
      }
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await signInWithGoogle();

            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          },
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🏠 HOME SCREEN
////////////////////////////////////////////////////////////

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Practice"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 Icon
              Icon(Icons.edit_note, size: 60, color: Colors.blue),

              SizedBox(height: 16),

              // 🔥 Title//////////
              Text(
                "Essay Practice",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              // 🔥 Subtitle////////
              Text(
                "Practice daily UPSC essays and get feedback",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),

              SizedBox(height: 20),

              // 🔥 Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateScreen()),
                    );
                  },
                  child: Text("Start Practice", style: TextStyle(fontSize: 16)),
                ),
              ),
              ////////dashboard button/////
              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(),
                      ),
                    );
                  },
                  child: Text("My Dashboard", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//////////////////////////////////////////////////////////
//////////////dashboard screen//////////////////////////

class DashboardScreen extends StatefulWidget {
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

    int total = 0;
    int count = 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('essays')
        .get();

    for (var doc in snapshot.docs) {
      total += int.tryParse(doc['score'].toString()) ?? 0;
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

////////////////////////////////////////////////////////////
///////////////// ESSAY HISTORY SCREEN /////////////////////
////////////////////////////////////////////////////////////

class EssayHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Essay History")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('essays')
            .orderBy('timestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No essays submitted yet"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data = docs[index];

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),

                child: ListTile(
                  contentPadding: EdgeInsets.zero,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserEssayDetailScreen(data: data),
                      ),
                    );
                  },

                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      "${data['score']}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  title: Text(
                    data['topic'] ?? "Essay",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 6),

                    child: Text(
                      data['essay'] ?? "",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

////////////////////////////////////////////////////////////
/////////////// USER ESSAY DETAIL SCREEN ///////////////////
////////////////////////////////////////////////////////////

class UserEssayDetailScreen extends StatelessWidget {
  final data;

  UserEssayDetailScreen({required this.data});

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
////////////////////////////////////////////////////////////
/// 📅 DATE SCREEN//////////////////////////////////////////
////////////////////////////////////////////////////////////

class DateScreen extends StatelessWidget {
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

////////////////////////////////////////////////////////////
/// 📝 TOPIC OF THE DAY SCREEN//////////////////////////////////
////////////////////////////////////////////////////////////

class EssayDetailScreen extends StatelessWidget {
  final String date;

  EssayDetailScreen({required this.date});

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
////////////////////////////////////////////////////////////
//////////////full essay screen/////////////////////////////

class FullEssayScreen extends StatelessWidget {
  final data;

  FullEssayScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Essay Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Essay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(data['essay'] ?? ""),

              SizedBox(height: 20),

              Text(
                "Feedback",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(data['feedback'] ?? ""),

              SizedBox(height: 20),

              Text(
                "Score: ${data['score']}/20",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
////////////////////////////////////////////////////////////
/// 🤖 YOUR ORIGINAL ESSAY SCREEN (UNCHANGED LOGIC)
////////////////////////////////////////////////////////////

class EssayScreen extends StatefulWidget {
  final String date;

  EssayScreen({required this.date});

  @override
  _EssayScreenState createState() => _EssayScreenState();
}

class _EssayScreenState extends State<EssayScreen> {
  List<File> _images = [];
  String feedback = "";
  String essayText = "";
  bool loading = false;

  final picker = ImagePicker();

  Future pickImages() async {
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((e) => File(e.path)).toList();
        feedback = "";
      });

      await sendToGPT(_images);
    }
  }

  int extractScore(String text) {
    final regex = RegExp(r'(\d+)/20');

    final match = regex.firstMatch(text);

    if (match != null) {
      return int.parse(match.group(1)!);
    }

    return 0;
  }

  Future sendToGPT(List<File> imageFiles) async {
    print("🚀 STEP 0: sendToGPT started");

    setState(() {
      loading = true;
    });

    try {
      List<Map<String, dynamic>> imageMessages = [];

      for (var file in imageFiles) {
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        imageMessages.add({
          "type": "image_url",
          "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
        });
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('training_feedback')
          .limit(4)
          .get();

      String trainingData = "";

      for (var doc in snapshot.docs) {
        trainingData +=
            """
Example Essay:
${doc['essay']}

Example Feedback:
${doc['feedback']}

---
""";
      }

      final topicDoc = await FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.date)
          .get();

      final topicData = topicDoc.data() ?? {};

      final topic = topicData['topic'] ?? "";
      final contextInfo = topicData['context'] ?? "";

      final dimensionsList = List<String>.from(topicData['dimensions'] ?? []);

      final currentAffairsList = List<String>.from(
        topicData['currentAffairs'] ?? [],
      );

      final dimensions = dimensionsList.join(", ");
      final currentAffairs = currentAffairsList.join(", ");

      final apiKey = "paste key";
      print("📡 STEP 1: Sending request to OpenAI...");
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content":
                  """
            You are a strict and experienced UPSC CAPF paper 2 evaluator who has checked 1000+ copies.

            You follow my personal evaluation style.

            From the examples below, learn:
            - Tone: constructive, honest, mentor-like (not robotic)
            - Depth: specific, not generic
            - Approach: always justify marks and give actionable feedback

            Do NOT copy phrases from examples.
            Do NOT repeat patterns blindly.
            Apply the same thinking style to a NEW essay.

            ------------------------
            TRAINING EXAMPLES:
            $trainingData
            ------------------------

            CURRENT ESSAY TOPIC:
            $topic

            TOPIC CONTEXT:
            $contextInfo

            EXPECTED DIMENSIONS:
            $dimensions

            CURRENT AFFAIRS CONNECTIONS:
            $currentAffairs

            TASK:

            These are multiple pages of a single UPSC essay.
            The images are in order. Combine them into one continuous essay.
            Ignore page breaks.

            First extract and write:

            ESSAY:
            <clean essay text>

            ------------------------

            EVALUATION LOGIC:

            Step 1: Evaluate the essay quality internally:
            - STRONG
            - AVERAGE
            - WEAK

            Step 2:
            - HIGH → mostly strengths, minimal suggestions
            - AVERAGE → balanced feedback
            - WEAK → detailed improvements

            Step 3:
            Before suggesting anything, check:
            “Is this missing?”

            If NOT missing → DO NOT suggest.

            ------------------------
            TOPIC RELEVANCE RULES:

            - Evaluate whether the essay actually addresses the core demand of the topic.
            - Check whether the candidate understands the contemporary relevance of the topic.
            - Reward essays that connect with current affairs naturally.
            - Reward multidimensional analysis.
            - Penalize essays that become generic and could fit any topic.
            - Penalize repetition and vague philosophical writing disconnected from topic demand.
            - Check whether important dimensions are missing.
            - Do not expect every dimension, but major missing dimensions should affect marks.

                 A strong CAPF essay usually contains:
                 - social awareness
                 - administrative understanding
                 - contemporary relevance
                 - examples/current affairs
                 - clear structure
                 - practical solutions
                 - mature conclusion

                 Weak essays are:
                 - generic
                 - repetitive
                 - emotionally shallow 
                 - lacking examples
                 - disconnected from current realities
                 - overly philosophical without substance

            ------------------------

            MARKING SCHEME:

            STRUCTURE (0–8)
            QUALITY OF CONTENT (0–8)
            LANGUAGE (0–4)

            TOTAL = 20

            ------------------------

            SCORING CALIBRATION:

            06–09 = weak essay
            10–13 = average essay
            14–16 = strong essay
            17–20 = exceptional essay rarely achieved

            Do not inflate marks.
            Be realistic and strict like actual CAPF evaluation.

            ----------------------------


            FORMAT:

            STRUCTURE (x/8):
            ...

            ---

            QUALITY OF CONTENT (x/8):
            ...

            ---

            LANGUAGE (x/4):
            ...

            ---

            STRENGTHS:
            ...

            ---

            MISTAKES:
            ...

            ---

            HOW TO IMPROVE:
            ...

            ---

            FINAL SCORE: __/20

            ------------------------

            RULES:

            - Do NOT suggest things already present in the essay.
            - Before giving any criticism, first verify whether that weakness genuinely exists.
            - Avoid generic feedback and vague observations.
            - Every criticism must directly connect to the actual essay.

            - Do not invent weaknesses simply to make the feedback look detailed.
            - Be specific, evidence-based, and evaluator-like.

            - If the candidate introduces relevant, meaningful, and non-generic dimensions beyond the provided topic guidance, reward originality.
            - Do not rigidly expect exact dimensions listed in topic guidance.
            - Do not penalize creative or unconventional approaches if they remain connected to the topic.

            - Strong essays should receive mostly strengths with limited corrections.
            - Weak essays should receive detailed, practical, and actionable improvement suggestions.

            - Maintain a constructive, mentor-like, and realistic evaluation tone.
            - Be honest, balanced, and strict like an actual CAPF evaluator.
        
            ------------------------

            FINAL OUTPUT RULE (VERY IMPORTANT):

            You must return your response ONLY in valid JSON format.

            Do NOT write anything before or after JSON.

            Format strictly like this:

            {
              "essay": "<clean extracted essay text>",
              "feedback": "<full evaluation exactly as per format above>",
              "score": <final score number only>
            }

            Rules:
            - "score" must be a number (not string)
            - Do NOT write "/20" inside score
            - Do NOT add extra text outside JSON
            - Ensure valid JSON (no trailing commas, proper quotes)
            

            If you fail to follow JSON format, the response is invalid.
            """,
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text":
                      "These are multiple pages of one essay. Read them in order and evaluate as a single essay. Evaluate this UPSC capf essay strictly as per instructions",
                },
                ...imageMessages,
              ],
            },
          ],
          "max_tokens": 1500,
        }),
      );
      print("✅ STEP 2: API response received");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body.substring(0, 200)}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🧠 STEP 3: JSON parsed");

        print("📝 STEP 4: Full response extracted");
        String fullResponse = data["choices"]?[0]?["message"]?["content"] ?? "";

        // Clean JSON wrappers if present
        fullResponse = fullResponse
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();

        String essay = "";
        String feedbackText = "";
        int score = 0;

        try {
          final parsed = jsonDecode(fullResponse);

          essay = parsed['essay'] ?? "";
          feedbackText = parsed['feedback'] ?? "";

          score = (parsed['score'] is int)
              ? parsed['score']
              : int.tryParse(parsed['score'].toString()) ?? 0;

          print("✅ JSON PARSED");
        } catch (e) {
          print("❌ JSON FAILED: $e");

          // fallback (your original logic)
          if (fullResponse.contains("STRUCTURE")) {
            final parts = fullResponse.split("STRUCTURE");
            essay = parts[0].replaceFirst("ESSAY:", "").trim();
            feedbackText = "STRUCTURE" + parts[1];
          } else {
            feedbackText = fullResponse;
          }

          score = extractScore(fullResponse);
        }
        print("🖥️ STEP 6: Updating UI");
        setState(() {
          feedback = feedbackText;
          essayText = essay; // ✅ add this line
          loading = false;
        });

        // 🔥 USER FETCH
        print("🔥 STEP 7: Starting Firestore operations");
        final user = FirebaseAuth.instance.currentUser;
        final uid = user!.uid;

        // 📅 Create dayId (one essay per day)
        final now = DateTime.now();
        final dayId = "${now.year}-${now.month}-${now.day}";

        // 📄 Global submission reference (for leaderboard etc.)
        final submissionRef = FirebaseFirestore.instance
            .collection('essays')
            .doc(widget.date)
            .collection('submissions')
            .doc(uid);

        // 📄 User daily essay reference
        final userEssayRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('essays')
            .doc(dayId);

        // 🔍 Get previous score (IMPORTANT: before writing)
        final userDoc = await userEssayRef.get();

        int previousScore = 0;
        if (userDoc.exists) {
          previousScore = userDoc.data()?['score'] ?? 0;
        }

        // 💾 Save global submission (overwrite for same day/topic)
        await submissionRef.set({
          'essay': essay,
          'feedback': feedbackText,
          'score': score,
          'name': user.displayName ?? "Anonymous",
          'uid': uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 💾 Save / overwrite daily essay (ONE PER DAY)
        await userEssayRef.set({
          'score': score,
          'essay': essay,
          'feedback': feedbackText,

          // 👇 topic metadata used during evaluation
          'topic': topic,
          'context': contextInfo,
          'dimensions': dimensionsList,
          'currentAffairs': currentAffairsList,

          // 👇 useful for debugging
          'rawModelResponse': fullResponse,

          'timestamp': FieldValue.serverTimestamp(),
        });

        // 📊 Update total score correctly
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'totalScore': FieldValue.increment(score - previousScore),
        }, SetOptions(merge: true));
        print("✅ STEP 8: Firestore completed");
      } else {
        setState(() {
          feedback = "API Error";
          loading = false;
        });
      }
    } catch (e) {
      print("❌ ERROR OCCURRED: $e");

      setState(() {
        feedback = "Error occurred";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Essay")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: pickImages,
                child: Text("Upload Image"),
              ),
              SizedBox(height: 20),
              _images.isNotEmpty
                  ? SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _images[index],
                                    width: 120,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // 🔢 Page number
                                Positioned(
                                  top: 5,
                                  left: 5,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Page ${index + 1}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),

                                // 🔄 REORDER BUTTONS (ADD THIS)
                                Positioned(
                                  bottom: 5,
                                  left: 5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          onPressed: index > 0
                                              ? () {
                                                  setState(() {
                                                    final temp = _images[index];
                                                    _images[index] =
                                                        _images[index - 1];
                                                    _images[index - 1] = temp;
                                                  });
                                                }
                                              : null,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          onPressed: index < _images.length - 1
                                              ? () {
                                                  setState(() {
                                                    final temp = _images[index];
                                                    _images[index] =
                                                        _images[index + 1];
                                                    _images[index + 1] = temp;
                                                  });
                                                }
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                ///remove bar////////
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Text("No images selected"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_images.isEmpty || loading)
                    ? null
                    : () async {
                        await sendToGPT(_images);
                      },
                child: Text(loading ? "Evaluating..." : "Submit Essay"),
              ),

              // 👇👇👇 PASTE HERE (JUST AFTER BUTTON)
              SizedBox(height: 20),

              if (essayText.isNotEmpty) ...[
                Text(
                  "Your Essay",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    essayText,
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "Feedback",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    feedback,
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
