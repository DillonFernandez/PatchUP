import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/appbar.dart' show UserSession;
import '../localization/app_localizations.dart';

// Notifications page widget for displaying and managing notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

// State class for notifications logic and UI
class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _loading = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  // Load user email and fetch notifications
  Future<void> _loadUserAndFetch() async {
    String? email = UserSession.email;
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('user_email');
    setState(() {
      _userEmail = email;
    });
    if (email != null) {
      await _fetchNotifications(email);
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  // Fetch notifications from backend API
  Future<void> _fetchNotifications(String email) async {
    setState(() {
      _loading = true;
    });
    final url =
        'http://192.168.1.100/patchup_app/lib/api/get_notifications.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": email}),
    );
    final result = jsonDecode(response.body);
    setState(() {
      _notifications = result["success"] ? result["notifications"] : [];
      _loading = false;
    });
  }

  // Mark all notifications as read (update locally)
  Future<void> _markAllAsRead() async {
    if (_userEmail == null) return;
    final url =
        'http://192.168.1.100/patchup_app/lib/api/mark_notifications_read.php';
    await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": _userEmail}),
    );
    // Update all unread notifications to read locally
    setState(() {
      for (var n in _notifications) {
        n['IsRead'] = 1;
      }
    });
  }

  // Mark a single notification as read (update locally)
  Future<void> _markAsRead(int notificationID) async {
    if (_userEmail == null) return;
    final url =
        'http://192.168.1.100/patchup_app/lib/api/mark_notifications_read.php';
    await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": _userEmail, "NotificationID": notificationID}),
    );
    // Update the notification's IsRead status locally
    setState(() {
      final notif = _notifications.firstWhere(
        (n) => n['NotificationID'] == notificationID,
        orElse: () => null,
      );
      if (notif != null) {
        notif['IsRead'] = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLoc.translate('Notifications AppBar Title'),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF04274B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => n['IsRead'] == 0))
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              tooltip: appLoc.translate('Mark all as read'),
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF04274B)),
              )
              : _notifications.isEmpty
              ? Center(
                child: Text(
                  'No Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                itemCount: _notifications.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 20),
                itemBuilder: (context, idx) {
                  final n = _notifications[idx];
                  final isRead = n['IsRead'] == 1;
                  // Notification card UI with read/unread styling
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {},
                      child: Opacity(
                        opacity: isRead ? 0.5 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blueGrey[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 18,
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.notifications_active,
                                  color:
                                      isRead
                                          ? Colors.grey
                                          : const Color(0xFF04274B),
                                ),
                                title: Text(
                                  n['Title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isRead ? Colors.grey : Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['Body'] ?? '',
                                      style: TextStyle(
                                        color:
                                            isRead
                                                ? Colors.grey[600]
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['CreatedAt'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            isRead
                                                ? Colors.grey[500]
                                                : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing:
                                    isRead
                                        ? null
                                        : IconButton(
                                          icon: const Icon(
                                            Icons.mark_email_read,
                                            color: Color(0xFF04274B),
                                          ),
                                          tooltip: appLoc.translate(
                                            'Mark as read',
                                          ),
                                          onPressed:
                                              () => _markAsRead(
                                                n['NotificationID'],
                                              ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
