import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../components/appbar.dart';
import '../localization/app_localizations.dart';

// Report page widget for submitting pothole reports
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

// State class for report page logic and UI
class _ReportPageState extends State<ReportPage> {
  String? selectedDangerLevel;
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;
  late final Connectivity _connectivity;
  bool _isSyncing = false;
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      setState(() {
        _connectivityStatus = result;
      });
      if (_isOnline(result)) {
        _syncOfflineReports();
      }
    });
  }

  // Initialize connectivity and sync offline reports if online
  Future<void> _initConnectivity() async {
    final statuses = await _connectivity.checkConnectivity();
    final status =
        statuses.isNotEmpty ? statuses.first : ConnectivityResult.none;
    setState(() {
      _connectivityStatus = status;
    });
    if (_isOnline(status)) {
      _syncOfflineReports();
    }
  }

  // Check if device is online
  bool _isOnline(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  // Get list of synced report IDs from preferences
  Future<Set<String>> _getSyncedReportIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('synced_report_ids') ?? []).toSet();
  }

  // Add a report ID to the synced list
  Future<void> _addSyncedReportId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('synced_report_ids') ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList('synced_report_ids', ids);
    }
  }

  // Save a report locally for offline sync
  Future<void> _saveReportOffline(Map<String, dynamic> report) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reports = prefs.getStringList('offline_reports') ?? [];
    reports.add(jsonEncode(report));
    await prefs.setStringList('offline_reports', reports);
  }

  // Get offline reports, optionally excluding synced ones
  Future<List<Map<String, dynamic>>> _getOfflineReports({
    bool excludeSynced = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reports = prefs.getStringList('offline_reports') ?? [];
    final syncedIds = excludeSynced ? await _getSyncedReportIds() : <String>{};
    return reports
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .where((r) => !excludeSynced || !syncedIds.contains(r['id']))
        .toList();
  }

  // Remove synced reports from offline storage
  Future<void> _removeSyncedReportsFromOffline() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reports = prefs.getStringList('offline_reports') ?? [];
    final syncedIds = await _getSyncedReportIds();
    final unsyncedReports =
        reports
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .where((r) => !syncedIds.contains(r['id']))
            .map((r) => jsonEncode(r))
            .toList();
    await prefs.setStringList('offline_reports', unsyncedReports);
  }

  // Sync offline reports to backend when online
  Future<void> _syncOfflineReports() async {
    if (_isSyncing) return;
    _isSyncing = true;
    final reports = await _getOfflineReports();
    if (reports.isEmpty) {
      _isSyncing = false;
      return;
    }
    final syncedIds = await _getSyncedReportIds();
    for (final report in reports) {
      final reportId = report['id'] as String? ?? '';
      if (reportId.isEmpty || syncedIds.contains(reportId)) continue;
      final success = await _uploadLocationToDB(
        zip: report['ZipCode'],
        lat: report['Latitude'],
        lng: report['Longitude'],
        desc: report['Description'],
        severity: report['SeverityLevel'],
        imagePath: report['ImagePath'],
        userEmail: report['UserEmail'],
      );
      if (success) {
        await _addSyncedReportId(reportId);
      }
    }
    await _removeSyncedReportsFromOffline();
    _isSyncing = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offline reports synced successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Upload a single report to backend API
  Future<bool> _uploadLocationToDB({
    required String zip,
    required String lat,
    required String lng,
    required String desc,
    required String severity,
    required String imagePath,
    required String userEmail,
  }) async {
    final uri = Uri.parse(
      'http://192.168.1.100/patchup_app/lib/api/pothole_report.php',
    );
    var request = http.MultipartRequest('POST', uri);
    request.fields['ZipCode'] = zip;
    request.fields['Latitude'] = lat;
    request.fields['Longitude'] = lng;
    request.fields['Description'] = desc;
    request.fields['SeverityLevel'] = severity;
    request.fields['UserEmail'] = userEmail;
    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('Image', imagePath));
    }
    try {
      final response = await request.send();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _zipController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Refresh location using geolocator and update fields
  Future<void> _refreshLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _longitudeController.text = position.longitude.toString();
      _latitudeController.text = position.latitude.toString();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String zip = '';
      for (final placemark in placemarks) {
        if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
          zip = placemark.postalCode!;
          break;
        }
      }
      _zipController.text = zip;
      setState(() {});
    } catch (e) {
      _zipController.text = '';
    }
  }

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Show thank you dialog after successful submission
  Future<void> _showThankYouDialog(BuildContext context) async {
    final appLoc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              appLoc.translate("Thank You!"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: Text(
              appLoc.translate("Thank You Message"),
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
                onPressed: () {
                  Navigator.pop(context);
                  _zipController.clear();
                  _longitudeController.clear();
                  _latitudeController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _selectedImage = null;
                    selectedDangerLevel = null;
                  });
                },
                child: Text(
                  appLoc.translate("Close"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Show error dialog for incomplete fields or errors
  Future<void> _showErrorDialog(BuildContext context, String message) async {
    final appLoc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              appLoc.translate("Incomplete Fields"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: Text(
              message,
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  appLoc.translate("Close"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Show offline dialog when report is saved locally
  Future<void> _showOfflineDialog(BuildContext context) async {
    final appLoc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              appLoc.translate("Report Saved Offline"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: Text(
              appLoc.translate("Report Saved Offline Message"),
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
                onPressed: () {
                  Navigator.pop(context);
                  _zipController.clear();
                  _longitudeController.clear();
                  _latitudeController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _selectedImage = null;
                    selectedDangerLevel = null;
                  });
                },
                child: Text(
                  appLoc.translate("Close"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLoc.translate('Report a Pothole'),
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
          // Show offline icon if not online
          if (!_isOnline(_connectivityStatus))
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.cloud_off,
                color: Colors.redAccent,
                size: 28,
                semanticLabel: 'Offline',
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF04274B).withOpacity(0.09),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(14),
                    child: Icon(
                      Icons.report_problem,
                      color: Color(0xFF04274B),
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    appLoc.translate("Report a Pothole"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    appLoc.translate("Help us keep roads safe & smooth"),
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Image picker section
              Container(
                width: double.infinity,
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
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child:
                                  _selectedImage == null
                                      ? Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 64,
                                          color: Colors.grey[500],
                                        ),
                                      )
                                      : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          _selectedImage!,
                                          width: double.infinity,
                                          height: 160,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: _pickImageFromCamera,
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  appLoc.translate('Take Photo'),
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFF04274B),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: _pickImageFromGallery,
                                icon: Icon(
                                  Icons.upload_file,
                                  color: Colors.black87,
                                ),
                                label: Text(
                                  appLoc.translate('Upload'),
                                  style: TextStyle(color: Colors.black87),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Location input section
              Container(
                width: double.infinity,
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
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Color(0xFF04274B)),
                            const SizedBox(width: 8),
                            Text(
                              appLoc.translate('Location'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _refreshLocation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Text(
                                  appLoc.translate('Get Location'),
                                  style: TextStyle(
                                    color: Color(0xFF04274B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                          height: 1,
                        ),
                        const SizedBox(height: 18),
                        // Zip code input
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _zipController,
                                decoration: InputDecoration(
                                  hintText: appLoc.translate('Zip Code'),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          hasFocus
                                              ? const Color(0xFF04274B)
                                              : const Color(0xFFE4E9F2),
                                      width: hasFocus ? 2 : 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE4E9F2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF04274B),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F9FC),
                                ),
                                style: const TextStyle(fontSize: 16),
                                keyboardType: TextInputType.text,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Longitude input
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _longitudeController,
                                decoration: InputDecoration(
                                  hintText: appLoc.translate('Longitude'),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          hasFocus
                                              ? const Color(0xFF04274B)
                                              : const Color(0xFFE4E9F2),
                                      width: hasFocus ? 2 : 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE4E9F2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF04274B),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F9FC),
                                ),
                                style: const TextStyle(fontSize: 16),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Latitude input
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _latitudeController,
                                decoration: InputDecoration(
                                  hintText: appLoc.translate('Latitude'),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          hasFocus
                                              ? const Color(0xFF04274B)
                                              : const Color(0xFFE4E9F2),
                                      width: hasFocus ? 2 : 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE4E9F2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF04274B),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F9FC),
                                ),
                                style: const TextStyle(fontSize: 16),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Description input section
              Container(
                width: double.infinity,
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
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLoc.translate('Description'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                          height: 1,
                        ),
                        const SizedBox(height: 18),
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: appLoc.translate(
                                    'Description Hint',
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          hasFocus
                                              ? const Color(0xFF04274B)
                                              : const Color(0xFFE4E9F2),
                                      width: hasFocus ? 2 : 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE4E9F2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF04274B),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F9FC),
                                ),
                                style: const TextStyle(fontSize: 16),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Severity level selection section
              Container(
                width: double.infinity,
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
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLoc.translate('Severity Level'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                          height: 1,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _DangerLevelButton(
                                label: 'Small',
                                color: Colors.green,
                                selected: selectedDangerLevel == 'Small',
                                onTap: () {
                                  setState(() {
                                    selectedDangerLevel = 'Small';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DangerLevelButton(
                                label: 'Moderate',
                                color: Colors.amber,
                                selected: selectedDangerLevel == 'Moderate',
                                onTap: () {
                                  setState(() {
                                    selectedDangerLevel = 'Moderate';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DangerLevelButton(
                                label: 'Critical',
                                color: Colors.red,
                                selected: selectedDangerLevel == 'Critical',
                                onTap: () {
                                  setState(() {
                                    selectedDangerLevel = 'Critical';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Submit report button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final zip = _zipController.text.trim();
                    final lat = _latitudeController.text.trim();
                    final lng = _longitudeController.text.trim();
                    final desc = _descriptionController.text.trim();
                    final severity = selectedDangerLevel ?? '';
                    if (zip.isEmpty ||
                        lat.isEmpty ||
                        lng.isEmpty ||
                        desc.isEmpty ||
                        severity.isEmpty ||
                        _selectedImage == null) {
                      await _showErrorDialog(
                        context,
                        appLoc.translate("Incomplete Fields Message"),
                      );
                      return;
                    }
                    final userEmail = UserSession.email;
                    final imagePath = _selectedImage!.path;
                    final reportId = _uuid.v4();
                    final report = {
                      'id': reportId,
                      'ZipCode': zip,
                      'Latitude': lat,
                      'Longitude': lng,
                      'Description': desc,
                      'SeverityLevel': severity,
                      'ImagePath': imagePath,
                      'UserEmail': userEmail,
                    };
                    final syncedIds = await _getSyncedReportIds();
                    if (syncedIds.contains(reportId)) {
                      await _showErrorDialog(
                        context,
                        appLoc.translate(
                          "This report has already been submitted.",
                        ),
                      );
                      return;
                    }
                    if (_isOnline(_connectivityStatus)) {
                      final success = await _uploadLocationToDB(
                        zip: zip,
                        lat: lat,
                        lng: lng,
                        desc: desc,
                        severity: severity,
                        imagePath: imagePath,
                        userEmail: userEmail,
                      );
                      if (success) {
                        await _addSyncedReportId(reportId);
                        await _showThankYouDialog(context);
                      } else {
                        // Save offline if failed
                        await _saveReportOffline(report);
                        await _showOfflineDialog(context);
                      }
                    } else {
                      // Save report locally for later sync
                      await _saveReportOffline(report);
                      await _showOfflineDialog(context);
                    }
                  },
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text(
                    appLoc.translate('Submit Report'),
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF04274B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    shadowColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
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

// Widget for selecting severity/danger level
class _DangerLevelButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _DangerLevelButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 90,
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border:
              selected
                  ? Border.all(color: color, width: 3)
                  : Border.all(color: Colors.transparent, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          appLoc.translate(label),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
