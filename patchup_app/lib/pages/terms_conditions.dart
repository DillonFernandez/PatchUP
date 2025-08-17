import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

// Terms and Conditions page widget
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

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
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 0.5,
                fontFamily: 'Montserrat',
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
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
          appLoc.translate('Terms and Conditions Title'),
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
              // Header section with icon and title
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: accentColor,
                      size: 60,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      appLoc.translate('Terms and Conditions Title'),
                      style: TextStyle(
                        fontSize: 22,
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appLoc.translate('Terms and Conditions Last Updated'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              sectionDivider(),
              // Welcome section
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
                        appLoc.translate('Terms and Conditions Welcome Title'),
                        Icons.info_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        appLoc.translate(
                          'Terms and Conditions Welcome Description',
                        ),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 1
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
                        appLoc.translate('Terms and Conditions 1 Title'),
                        Icons.public_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 1 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 2
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
                        appLoc.translate('Terms and Conditions 2 Title'),
                        Icons.person_outline_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 2 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 3
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
                        appLoc.translate('Terms and Conditions 3 Title'),
                        Icons.location_on_outlined,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 3 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 4
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
                        appLoc.translate('Terms and Conditions 4 Title'),
                        Icons.camera_alt_outlined,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 4 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 5
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
                        appLoc.translate('Terms and Conditions 5 Title'),
                        Icons.lock_outline_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 5 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 6
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
                        appLoc.translate('Terms and Conditions 6 Title'),
                        Icons.money_off_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 6 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 7
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
                        appLoc.translate('Terms and Conditions 7 Title'),
                        Icons.map_outlined,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 7 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 8
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
                        appLoc.translate('Terms and Conditions 8 Title'),
                        Icons.warning_amber_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 8 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
              sectionDivider(),
              // Section 9
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
                        appLoc.translate('Terms and Conditions 9 Title'),
                        Icons.update_rounded,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appLoc.translate('Terms and Conditions 9 Description'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          color: Colors.black87,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
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
