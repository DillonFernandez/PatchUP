import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

// About & Contact Us page widget
class AboutContactUsPage extends StatelessWidget {
  const AboutContactUsPage({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF04274B);
  static const Color accentColor = Color(0xFF1E88E5);
  static const Color bgColor = Color.fromARGB(255, 255, 255, 255);
  static const Color cardBorderColor = Color(0xFFE3E8F0);

  // Section title widget with icon
  Widget sectionTitle(String text, IconData icon, {double fontSize = 22}) =>
      Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: fontSize * 0.9),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: primaryColor,
              letterSpacing: 0.5,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      );

  // Divider between sections
  Widget sectionDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Divider(color: Colors.grey.shade300, thickness: 1.2, height: 1),
  );

  // Card style for section content
  Widget modernCard({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: cardBorderColor, width: 1.1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 18,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
      color: Colors.white,
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          appLoc.translate('About & Contact Us'),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and app title section
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.15),
                            primaryColor.withOpacity(0.10),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 54,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo/Logo 1.webp',
                            width: 90,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      appLoc.translate('Smart Pothole Reporting & Management'),
                      style: TextStyle(
                        fontSize: 18,
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              sectionDivider(),
              // Who We Are section
              modernCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(
                        appLoc.translate('Who We Are'),
                        Icons.info_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        appLoc.translate('Who We Are Description'),
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Vision and Mission section
              modernCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(
                        appLoc.translate('Our Vision'),
                        Icons.visibility_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Our Vision Description'),
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 18),
                      sectionTitle(
                        appLoc.translate('Our Mission'),
                        Icons.flag_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Our Mission Description'),
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Why PatchUp section
              modernCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(
                        appLoc.translate('Why PatchUp?'),
                        Icons.lightbulb_outline_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Why PatchUp Description'),
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Our Team section
              modernCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(
                        appLoc.translate('Our Team'),
                        Icons.group_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Our Team Description'),
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Contact Us section
              modernCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(
                        appLoc.translate('Contact Us'),
                        Icons.mail_outline_rounded,
                        fontSize: 22,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Contact Us Description'),
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Icon(Icons.email, color: accentColor, size: 22),
                          const SizedBox(width: 12),
                          SelectableText(
                            appLoc.translate('Email'),
                            style: TextStyle(
                              fontSize: 16.5,
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.phone, color: accentColor, size: 22),
                          const SizedBox(width: 12),
                          SelectableText(
                            appLoc.translate('Phone'),
                            style: TextStyle(
                              fontSize: 16.5,
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Copyright section
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    appLoc.translate('Copyright'),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
