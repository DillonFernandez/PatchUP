import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../components/appbar.dart';

// --- Report Page Widget ---
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

// --- Report Page State ---
class _ReportPageState extends State<ReportPage> {
  String? selectedDangerLevel;

  // --- Controllers and State Variables ---
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // --- Dispose Controllers ---
  @override
  void dispose() {
    _zipController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Upload Location Data and Image to Backend ---
  Future<void> _uploadLocationToDB() async {
    final zip = _zipController.text.trim();
    final lat = _latitudeController.text.trim();
    final lng = _longitudeController.text.trim();
    final desc = _descriptionController.text.trim();
    final severity = selectedDangerLevel ?? '';

    if (zip.isEmpty || lat.isEmpty || lng.isEmpty) return;

    final uri = Uri.parse(
      'http://192.168.1.100/patchup_app/lib/api/pothole_report.php',
    );
    var request = http.MultipartRequest('POST', uri);

    request.fields['ZipCode'] = zip;
    request.fields['Latitude'] = lat;
    request.fields['Longitude'] = lng;
    request.fields['Description'] = desc;
    request.fields['SeverityLevel'] = severity;
    request.fields['UserEmail'] = UserSession.email; // <-- Pass user email

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('Image', _selectedImage!.path),
      );
    }

    await request.send();
  }

  // --- Refresh Location and Auto-fill Fields ---
  Future<void> _refreshLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _longitudeController.text = position.longitude.toString();
      _latitudeController.text = position.latitude.toString();

      // Improved zip code retrieval
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
      // Handle error (optional)
      _zipController.text = '';
    }
  }

  // --- Pick Image from Camera ---
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- Pick Image from Gallery ---
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- Show Thank You Dialog and Clear Form ---
  Future<void> _showThankYouDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              "Thank You!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: const Text(
              "Thank you for caring for our roads and community. Your report helps make a difference!",
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
                onPressed: () {
                  Navigator.pop(context);
                  // Clear all fields after dialog is closed
                  _zipController.clear();
                  _longitudeController.clear();
                  _latitudeController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _selectedImage = null;
                    selectedDangerLevel = null; // Clear severity
                    // Add more fields to clear if needed
                  });
                },
                child: const Text(
                  "Close",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  // --- Show Error Dialog ---
  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              "Incomplete Fields",
              style: TextStyle(
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
                child: const Text(
                  "Close",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar Section ---
      appBar: AppBar(
        title: const Text('Report a Pothole'),
        backgroundColor: const Color(0xFF04274B),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Section ---
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
                    "Report a Pothole",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Help us keep roads safe & smooth",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // --- Photo Picker Card Section ---
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
                        // --- Image Preview and Picker Buttons ---
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
                                  'Take Photo',
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
                                  'Upload',
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
              // --- Location Card Section ---
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
                              'Location',
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
                                  'Get Location',
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
                        // --- Zip Code Field ---
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _zipController,
                                decoration: InputDecoration(
                                  hintText: 'Zip Code',
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
                        // --- Longitude Field ---
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _longitudeController,
                                decoration: InputDecoration(
                                  hintText: 'Longitude',
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
                        // --- Latitude Field ---
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _latitudeController,
                                decoration: InputDecoration(
                                  hintText: 'Latitude',
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
              // --- Description Card Section ---
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
                          'Description',
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
                        // --- Description Field ---
                        Focus(
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'E.g., Large pothole, risk to vehicles, near crosswalk...',
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
              // --- Severity Level Card Section ---
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
                          'Severity Level',
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
              // --- Submit Button Section ---
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // --- Validation: Check All Fields ---
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
                        "Please fill in all fields and attach a photo before submitting your report.",
                      );
                      return;
                    }
                    await _uploadLocationToDB();
                    await _showThankYouDialog(context);
                  },
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text(
                    'Submit Report',
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

// --- Danger Level Button Widget ---
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
          label,
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
