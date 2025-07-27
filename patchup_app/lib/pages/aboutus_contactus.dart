import 'package:flutter/material.dart';

class AboutContactUsPage extends StatelessWidget {
  const AboutContactUsPage({Key? key}) : super(key: key);

  // --- Color Constants ---
  static const Color primaryColor = Color(0xFF04274B);
  static const Color accentColor = Color(0xFF04274B);
  static const Color bgColor = Color.fromARGB(255, 255, 255, 255);

  // --- Fade-in Animation Widget ---
  Widget fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      builder:
          (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          ),
      child: child,
    );
  }

  // --- Section Title Widget ---
  Widget sectionTitle(String text, {double fontSize = 22}) => Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: primaryColor,
      letterSpacing: 0.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('About & Contact Us'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- App Logo & Header Section ---
              fadeIn(
                child: Container(
                  child: Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo/Logo 1.webp',
                          width: 150,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Smart Pothole Reporting & Management',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              // --- Who We Are Card Section ---
              Container(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle('Who We Are'),
                        const SizedBox(height: 10),
                        Text(
                          'PatchUp is an innovative smart pothole reporting and management platform designed to improve road safety and infrastructure maintenance in Sri Lanka. Our mission is to empower citizens to report potholes easily and transparently, while enabling local authorities to act faster and more effectively.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --- Vision & Mission Card Section ---
              Container(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle('Our Vision', fontSize: 20),
                        const SizedBox(height: 8),
                        Text(
                          'To create safer, better-maintained roads for everyone by bridging the communication gap between the public and local authorities.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        sectionTitle('Our Mission', fontSize: 20),
                        const SizedBox(height: 8),
                        Text(
                          '• Enable real-time pothole reporting through a simple mobile and web platform.\n'
                          '• Provide transparency and accountability in road repairs.\n'
                          '• Foster community involvement by allowing users to validate reports and track progress.\n'
                          '• Help authorities prioritize repairs using accurate data and analytics.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --- Why PatchUp Card Section ---
              Container(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle('Why PatchUp?', fontSize: 20),
                        const SizedBox(height: 8),
                        Text(
                          '• Real-time Reporting: Capture pothole images, GPS location, and descriptions instantly.\n'
                          '• Community Validation: Users can upvote and confirm existing reports to ensure critical issues are addressed quickly.\n'
                          '• Authority Integration: Reports are routed directly to the correct municipal council through dashboards.\n'
                          '• Multilingual Support: Available in Sinhala, Tamil, and English for maximum accessibility.\n'
                          '• Offline Reporting: Users can submit reports even without internet connectivity.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --- Our Team Card Section ---
              Container(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle('Our Team', fontSize: 20),
                        const SizedBox(height: 8),
                        Text(
                          'PatchUp was developed by a passionate group of students at Level 5 (COMP50022: Commercial Computing, SEENG2421):\n\n'
                          '• Dillon Fernandez (CB012663)\n'
                          '• Hiranya Nirmal (CB012776)\n'
                          '• Sanura Devjan (CB012596)\n'
                          '• Akshith Rithushan (CB013331)\n\n'
                          'Together, we are committed to making roads safer and empowering communities.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --- Contact Us Card Section ---
              Container(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle('Contact Us', fontSize: 22),
                        const SizedBox(height: 6),
                        Text(
                          'We’d love to hear from you! Whether you have questions, feedback, or partnership opportunities, feel free to reach out.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Icon(Icons.email, color: accentColor),
                            const SizedBox(width: 10),
                            Text(
                              'patchup@gmail.com',
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.phone, color: accentColor),
                            const SizedBox(width: 10),
                            Text(
                              '0770860998',
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // --- Footer Section ---
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '© 2024 PatchUp. All rights reserved.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
