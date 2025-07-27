import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- User Session Class for Storing Current User's Email ---
class UserSession {
  static String email = '';
}

// --- AppBar Widget with User Points Display ---
class UserAppBar extends StatefulWidget implements PreferredSizeWidget {
  const UserAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(54);

  @override
  State<UserAppBar> createState() => _UserAppBarState();
}

// --- State Class for UserAppBar: Handles Points Fetching and UI ---
class _UserAppBarState extends State<UserAppBar> {
  int points = 0;
  bool loading = true;

  // --- Initialize State and Fetch User Points ---
  @override
  void initState() {
    super.initState();
    fetchPoints();
  }

  // --- Fetch Points from Backend API Using User's Email ---
  Future<void> fetchPoints() async {
    final email = UserSession.email;
    if (email.isEmpty) {
      setState(() {
        loading = false;
      });
      return;
    }
    final url = 'http://192.168.1.100/patchup_app/lib/api/get_points.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": email}),
    );
    final result = jsonDecode(response.body);
    setState(() {
      points = result['points'] ?? 0;
      loading = false;
    });
  }

  // --- Build the AppBar UI with Logo and Points Display ---
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // --- App Logo ---
            Image.asset(
              'assets/images/logo/Logo 1.webp',
              width: 105,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(child: Container()),
            // --- Points Indicator ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 22),
                  const SizedBox(width: 6),
                  loading
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                        ),
                      )
                      : Text(
                        '$points',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
