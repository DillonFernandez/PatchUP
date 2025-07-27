import 'package:flutter/material.dart';

import '../components/appbar.dart';

/// --- Leaderboard Page Widget ---
class LeaderBoardPage extends StatelessWidget {
  const LeaderBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Custom AppBar Section ---
      appBar: const UserAppBar(),
      // --- Page Background Color ---
      backgroundColor: Colors.white,
      // --- Main Body Section ---
      body: Center(
        child: Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Placeholder Text for Development ---
                Text(
                  'In Development',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
