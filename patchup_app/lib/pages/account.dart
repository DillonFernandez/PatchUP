import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/appbar.dart';
import '../localization/app_localizations.dart';
import '../main.dart';
import 'aboutus_contactus.dart';
import 'login.dart';
import 'my_badges.dart';
import 'my_reports.dart';
import 'terms_conditions.dart';

// Account page widget for user profile and settings
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

// State class for account page logic and UI
class _AccountPageState extends State<AccountPage> {
  String userName = '';
  String userEmail = '';
  bool loading = true;
  String selectedLanguageCode = 'en';
  bool notificationsEnabled = true;
  int userPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchUserPoints();
    _loadSelectedLanguage();
  }

  // Fetch user info from backend or cache
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
    try {
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_name_$email', userName);
      await prefs.setString('cached_user_email_$email', userEmail);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString('cached_user_name_$email');
      final cachedEmail = prefs.getString('cached_user_email_$email');
      setState(() {
        userName = cachedName ?? '';
        userEmail = cachedEmail ?? email;
        loading = false;
      });
    }
  }

  // Fetch user points from backend or cache
  Future<void> _fetchUserPoints() async {
    final email = UserSession.email;
    if (email.isEmpty) {
      setState(() {
        userPoints = 0;
      });
      return;
    }
    final url = 'http://192.168.1.100/patchup_app/lib/api/get_points.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Email": email}),
      );
      final result = jsonDecode(response.body);
      setState(() {
        userPoints = result['points'] ?? 0;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_user_points_$email', userPoints);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedPoints = prefs.getInt('cached_user_points_$email');
      setState(() {
        userPoints = cachedPoints ?? 0;
      });
    }
  }

  // Logout user and clear session
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

  // Show logout confirmation dialog
  Future<void> _confirmLogout(BuildContext context) async {
    final appLoc = AppLocalizations.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              appLoc.translate('Logout'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: Text(
              appLoc.translate('Are you sure you want to logout?'),
              style: const TextStyle(color: Colors.white, fontSize: 16),
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
                child: Text(
                  appLoc.translate('Cancel'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
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
                child: Text(
                  appLoc.translate('Logout'),
                  style: const TextStyle(
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

  // Load selected language from preferences
  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_language');
    if (langCode != null && langCode.isNotEmpty) {
      setState(() {
        selectedLanguageCode = langCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF04274B),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
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
                // User profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 28,
                  ),
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFFE3E9F4),
                          child: Icon(
                            Icons.person,
                            size: 44,
                            color: Color(0xFF04274B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child:
                            loading
                                ? (userName.isNotEmpty || userEmail.isNotEmpty
                                    ? _buildProfileInfo()
                                    : const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ))
                                : _buildProfileInfo(),
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
                        top: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x2204274B),
                          blurRadius: 28,
                          offset: Offset(0, -10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 34,
                      ),
                      child: Column(
                        children: [
                          // My Reports card
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            margin: EdgeInsets.zero,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyReportsPage(),
                                    ),
                                  ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF04274B).withOpacity(0.08),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment,
                                      color: Color(0xFF04274B),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 18),
                                    Text(
                                      appLoc.translate('My Reports'),
                                      style: const TextStyle(
                                        color: Color(0xFF04274B),
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
                          ),
                          const SizedBox(height: 22),
                          // My Badges card
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            margin: EdgeInsets.zero,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyBadgesPage(),
                                    ),
                                  ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF04274B).withOpacity(0.08),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      color: Color(0xFF04274B),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 18),
                                    Text(
                                      appLoc.translate('My Badges'),
                                      style: const TextStyle(
                                        color: Color(0xFF04274B),
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
                          ),
                          const SizedBox(height: 22),
                          // Language selection card
                          _buildLanguageCard(),
                          const SizedBox(height: 22),
                          // Notifications toggle section
                          _buildNotificationsSection(appLoc),
                          const SizedBox(height: 22),
                          // About, Terms, and Logout section
                          _buildLogoutCard(context, appLoc),
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

  // Build user profile info section
  Widget _buildProfileInfo() {
    final appLoc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName.isNotEmpty ? userName : appLoc.translate('Name not found'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
            shadows: [
              Shadow(
                color: Color(0x33000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userEmail.isNotEmpty
              ? userEmail
              : appLoc.translate('Email not found'),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFB3C2D6),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 22),
              const SizedBox(width: 6),
              Text(
                '$userPoints ${appLoc.translate('Points')}',
                style: const TextStyle(
                  color: Color(0xFFFFA000),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build language selection card
  Widget _buildLanguageCard() {
    final appLoc = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.language, color: Color(0xFF04274B)),
                  const SizedBox(width: 10),
                  Text(
                    appLoc.translate('language'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF04274B),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(
                      langCode: 'en',
                      label: appLoc.translate('English'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildLanguageButton(
                      langCode: 'si',
                      label: appLoc.translate('Sinhala'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildLanguageButton(
                      langCode: 'ta',
                      label: appLoc.translate('Tamil'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build language selection button
  Widget _buildLanguageButton({
    required String langCode,
    required String label,
  }) {
    final isSelected = selectedLanguageCode == langCode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      child: TextButton(
        onPressed: () async {
          setState(() {
            selectedLanguageCode = langCode;
          });
          final inherited = InheritedLocale.of(context);
          inherited?.setLocale(Locale(langCode));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_language', langCode);
        },
        style: TextButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFFB3C2D6) : Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? const Color(0xFF04274B) : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF04274B) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  // Build notifications toggle section
  Widget _buildNotificationsSection(AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF04274B).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF04274B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  appLoc.translate('Enable Notifications'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF04274B),
                  ),
                ),
              ),
              Switch(
                value: notificationsEnabled,
                activeColor: const Color(0xFF04274B),
                onChanged: (val) {
                  setState(() {
                    notificationsEnabled = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build About, Terms, and Logout section
  Widget _buildLogoutCard(BuildContext context, AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Column(
            children: [
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
                  label: Text(
                    appLoc.translate('About & Contact Us'),
                    style: const TextStyle(
                      color: Color(0xFF04274B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F7FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsConditionsPage(),
                        ),
                      ),
                  icon: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF1E88E5),
                  ),
                  label: Text(
                    appLoc.translate('Terms and Conditions'),
                    style: const TextStyle(
                      color: Color(0xFF04274B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F7FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    appLoc.translate('Logout'),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF0F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
