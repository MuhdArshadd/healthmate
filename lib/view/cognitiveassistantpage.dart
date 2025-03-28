import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthmate/controller/cognitivegames_tracking_controller.dart';
import '../cognitivegames/ui/pages/startup_page.dart';
import 'custom_app_bar.dart';
import 'custom_nav_bar.dart';

import 'main_navigation_screen.dart';
import 'cognitivegamepage.dart';


import 'package:provider/provider.dart';
import '../AuthProvider/Auth_provider.dart';
import "../model/user_model.dart";

class CognitiveAssistantPage extends StatefulWidget {


  @override
  _CognitiveAssistantPageState createState() => _CognitiveAssistantPageState();
}

class _CognitiveAssistantPageState extends State<CognitiveAssistantPage> {

  final CognitivegamesTrackingController cognitivegamesTrackingController = CognitivegamesTrackingController();
  Future<Map<String, dynamic>>? streakData;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        setState(() {
          streakData = cognitivegamesTrackingController.getStreakData(user.userId);
        });
      } else {
        streakData = Future.value({
          'current_streak': 0,
          'longest_streak': 0,
          'last_played_date': null
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep Tracking Header
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Cognitive Assistant",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(
                    "assets/cognitive.png",
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD3E0E3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test your Memory',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Instruction:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'On the game board, there are always two identical images. Start the game by flipping a card. Then try to find another card that has the same image as the first. If you can\'t find a pair, the flipped cards will be flipped back with the face down. Try to remember these images, as it gets easier to find pairs the longer you play.',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Have fun and goodluck!!!',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            // Streak Data & Start Button
            FutureBuilder<Map<String, dynamic>>(
              future: streakData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("Error fetching streak data");
                }

                var data = snapshot.data!;
                int currentStreak = data['current_streak'];
                int longestStreak = data['longest_streak'];
                DateTime? lastPlayedDate = data['last_played_date'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak: Day $currentStreak',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Longest Streak: Day $longestStreak',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Last Played: ${lastPlayedDate != null ? lastPlayedDate.toString().split(' ')[0] : "Never"}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Update streak data before navigating to game page
                            await cognitivegamesTrackingController
                                .updateStreakData(user!.userId);
                            // Navigate to game page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StartUpPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD3E0E3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'START',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Keeps Home highlighted
        onTap: (index) {
          // Navigate back to MainNavigationScreen with the correct index
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
 builder: (context) => MainNavigationScreen(user: user!, selectedIndex: index),
            ),
          );
        },
      ),
    );
  }
}