import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/appbar.dart';
import 'aboutus_contactus.dart';
import 'login.dart';
import 'my_badges.dart';
import 'my_reports.dart';

// --- Account Page Widget ---
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

// --- Account Page State ---
class _AccountPageState extends State<AccountPage> {
  String userName = '';
  String userEmail = '';
  bool loading = true;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // --- Fetch User Info from API ---
  Future<void> _fetchUserInfo() async {
    final email = UserSession.email;
    if (email.isEmpty) {
      setState(() {
        userName = '';
        userEmail = '';
        loading = false;
      });
      return;
    }
    final url = 'http://192.168.1.100/patchup_app/lib/api/get_user_info.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": email}),
    );
    final result = jsonDecode(response.body);
    setState(() {
      userName = result['name'] ?? '';
      userEmail = result['email'] ?? email;
      loading = false;
    });
  }

  // --- Logout Functionality ---
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    UserSession.email = '';
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // --- Logout Confirmation Dialog ---
  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: const Text(
              "Are you sure you want to logout?",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF0A4173),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
    if (shouldLogout == true) {
      await _logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04274B),
      body: SafeArea(
        child: Stack(
          children: [
            // --- Gradient Background ---
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF04274B), Color(0xFF0A4173)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Column(
              children: [
                // --- User Header Section ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0xFFE3E9F4),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF04274B),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child:
                            loading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName.isNotEmpty
                                          ? userName
                                          : 'Name not found',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userEmail.isNotEmpty
                                          ? userEmail
                                          : 'Email not found',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFFB3C2D6),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x2204274B),
                          blurRadius: 24,
                          offset: Offset(0, -8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          // --- My Reports Card ---
                          _buildCard(
                            icon: Icons.assignment,
                            label: 'My Reports',
                            color: const Color(0xFF5F6BFF),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyReportsPage(),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 18),
                          // --- My Badges Card ---
                          _buildCard(
                            icon: Icons.emoji_events,
                            label: 'My Badges',
                            color: const Color(0xFF5F6BFF),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyBadgesPage(),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 18),
                          // --- Language Selection Card ---
                          _buildLanguageCard(),
                          const SizedBox(height: 18),
                          // --- About & Contact Us and Logout Card ---
                          _buildLogoutCard(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Card Builder for Navigation Options ---
  Widget _buildCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.08), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 18),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF04274B),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFB3C2D6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Language Selection Card ---
  Widget _buildLanguageCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildLanguageButton('English')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLanguageButton('Sinhala', label: 'සිංහල'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLanguageButton('Tamil', label: 'தமிழ்'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Language Button Builder ---
  Widget _buildLanguageButton(String lang, {String? label}) {
    final isSelected = selectedLanguage == lang;
    return TextButton(
      onPressed: () {
        setState(() {
          selectedLanguage = lang;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFFE7EBFD) : const Color(0xFFF6F7FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? const Color(0xFF5F6BFF) : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      ),
      child: Text(
        label ?? lang,
        style: TextStyle(
          color: isSelected ? const Color(0xFF5F6BFF) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  // --- About & Contact Us and Logout Card ---
  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            children: [
              // --- About & Contact Us Button ---
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutContactUsPage(),
                        ),
                      ),
                  icon: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF5F6BFF),
                  ),
                  label: const Text(
                    'About & Contact Us',
                    style: TextStyle(
                      color: Color(0xFF04274B),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFF6F7FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // --- Logout Button ---
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFFFF0F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
