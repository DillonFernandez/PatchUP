import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/appbar.dart';
import 'report.dart';

// --- Fetch Recent Reports from API ---
Future<List<Map<String, dynamic>>> fetchReports() async {
  final response = await http.get(
    Uri.parse(
      'http://192.168.1.100/patchup_app/lib/api/display_reports_home.php',
    ),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}

// --- Home Page Widget ---
class HomePage extends StatelessWidget {
  final void Function()? goToReportTab;

  const HomePage({super.key, this.goToReportTab});

  // --- Fetch Home Page Statistics from API ---
  Future<Map<String, dynamic>> fetchHomeStats() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.100/patchup_app/lib/api/home_stats.php'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const UserAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Welcome Card Section ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Color(0xFFe3edf7), Color(0xFFf8fafc)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.08),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Color(0xFFE0E3E8), width: 1.1),
                ),
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.transparent),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF04274B), Color(0xFF3b82f6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome to PatchUp!",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  color: Color(0xFF04274B),
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Your city, your reports. Stay updated and help improve your community.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey[700],
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              // --- Statistics Cards Section ---
              FutureBuilder<Map<String, dynamic>>(
                future: fetchHomeStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // --- Loading State for Stats Cards ---
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        3,
                        (i) => Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.withOpacity(0.07),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Color(0xFFE0E3E8),
                                width: 1.2,
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: Colors.transparent,
                                  width: 0,
                                ),
                              ),
                              margin: EdgeInsets.zero,
                              child: SizedBox(
                                height: 90,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF04274B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // --- Error State for Stats Cards ---
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        'Failed to load stats',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  } else {
                    // --- Loaded Stats Cards ---
                    final stats = snapshot.data!;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people,
                            label: "Users",
                            value: stats['total_users'].toString(),
                            color: Colors.blue[700]!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.bar_chart,
                            label: "Avg/Day",
                            value: stats['avg_reports_per_day'].toString(),
                            color: Colors.orange[700]!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            label: "Resolved",
                            value: stats['potholes_resolved'].toString(),
                            color: Colors.green[700]!,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 35),
              // --- Divider with Recent Reports Icon ---
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1.3,
                      endIndent: 10,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF04274B).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_edu_rounded,
                          color: Color(0xFF04274B),
                          size: 22,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Recent Reports',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF04274B),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1.3,
                      indent: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // --- Recent Reports List Section ---
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // --- Loading State for Reports List ---
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF04274B),
                        ),
                      ),
                    );
                  }
                  final reports = snapshot.data ?? [];
                  if (reports.isEmpty) {
                    // --- No Reports Found State ---
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No recent reports found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }
                  // --- List of Recent Reports ---
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _ReportCard(report: report);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // --- Floating Action Button for New Report ---
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF04274B).withOpacity(0.18),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportPage()),
            );
          },
          backgroundColor: const Color(0xFF04274B),
          child: const Icon(Icons.add, color: Colors.white, size: 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// --- Statistics Card Widget ---
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.09),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Color(0xFFE0E3E8), width: 1.1),
      ),
      margin: EdgeInsets.zero,
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.transparent),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Icon Section ---
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.18), color.withOpacity(0.09)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.transparent,
                  child: Icon(icon, color: color, size: 28),
                ),
              ),
              const SizedBox(height: 12),
              // --- Value Section ---
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
              // --- Label Section ---
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.blueGrey[700],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Report Card Widget for Recent Reports ---
class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        splashColor: Colors.blue[50],
        highlightColor: Colors.blue[50]?.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xFFF7F8FA),
            border: Border.all(color: Color(0xFFE0E3E8), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.07),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.transparent),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Top Row: Severity and Status ---
                  Row(
                    children: [
                      if (report['SeverityLevel'] != null)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 6,
                            ),
                            margin: EdgeInsets.only(
                              right: report['Status'] != null ? 8 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange[700],
                                  size: 17,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${report['SeverityLevel']}',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (report['Status'] != null)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 17,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${report['Status']}',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // --- Main Content Row: Image and Details ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Image Section ---
                      report['ImageURL'] != null &&
                              report['ImageURL'].toString().isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'http://192.168.1.100${report['ImageURL']}',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.image_not_supported,
                                    size: 38,
                                    color: Colors.blueGrey[200],
                                  ),
                            ),
                          )
                          : Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.warning,
                                color: Colors.redAccent,
                                size: 38,
                              ),
                            ),
                          ),
                      const SizedBox(width: 22),
                      // --- Details Section ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Location Row ---
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xFF04274B),
                                  size: 19,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${report['Latitude']}, ${report['Longitude']}',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey[900],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // --- ZipCode Row ---
                            if (report['ZipCode'] != null &&
                                report['ZipCode'].toString().isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_post_office,
                                    size: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    report['ZipCode'],
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey[900],
                                    ),
                                  ),
                                ],
                              ),
                            // --- Timestamp Row ---
                            if (report['Timestamp'] != null &&
                                report['Timestamp'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.blueGrey[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      report['Timestamp'],
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blueGrey[900],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // --- User Row ---
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${report['UserName'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // --- Description Section ---
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      report['Description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: Colors.blueGrey[900],
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
