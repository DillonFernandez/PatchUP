import 'package:flutter/material.dart';

import '../pages/account.dart';
import '../pages/home.dart';
import '../pages/leaderboard.dart';
import '../pages/reports.dart';

// --- Bottom Navigation Bar Widget ---
class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

// --- State Class for Navigation Logic and UI ---
class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // --- Navigation Bar Color Definitions ---
    const Color selectedColor = Color(0xFF04274B);
    const Color unselectedColor = Colors.grey;

    // --- List of Pages for Navigation Destinations ---
    final List<Widget> pages = [
      const HomePage(),
      const ReportsPage(),
      const LeaderBoardPage(),
      const AccountPage(),
    ];

    // --- Scaffold Containing Navigation Bar and Current Page ---
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentPageIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            // --- Style for Navigation Bar Labels ---
            labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
              Set<MaterialState> states,
            ) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(color: selectedColor);
              }
              return const TextStyle(color: unselectedColor);
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: selectedColor.withOpacity(0.1),
            // --- Handle Navigation Destination Selection ---
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            // --- Define Navigation Destinations ---
            destinations: <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home, color: selectedColor),
                icon: Icon(Icons.home_outlined, color: unselectedColor),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.insert_drive_file,
                  color: selectedColor,
                ),
                icon: Icon(
                  Icons.insert_drive_file_outlined,
                  color: unselectedColor,
                ),
                label: 'Reports',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.leaderboard, color: selectedColor),
                icon: Icon(Icons.leaderboard_outlined, color: unselectedColor),
                label: 'Leaderboard',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person, color: selectedColor),
                icon: Icon(Icons.person_outline, color: unselectedColor),
                label: 'Profile',
              ),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
