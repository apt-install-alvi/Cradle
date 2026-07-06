import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // NEW
import 'dart:io'; // NEW (for File)
import 'package:flutter/foundation.dart' show kIsWeb; // NEW (for Web check)

// ----------------------------------------------------------------
// TEST MODE: Firebase is not wired up yet.
// When you're ready to connect Firebase, uncomment the two imports
// below and add these packages to pubspec.yaml:
//   cloud_firestore: ^<latest>
//   firebase_auth:   ^<latest>
//   intl:            ^<latest>
// ----------------------------------------------------------------
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // used only for date formatting (dd MMM yyyy)

/// ============================================================
/// PersonalInfoPage
/// ------------------------------------------------------------
/// Allows a logged-in user to create/update her maternal health
/// profile. Data is stored in Firestore under:
///   users/{uid}
/// ============================================================

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  static const Color primaryPink = Color(0xFFE96487);
  static const Color lightPink = Color(0xFFFDECF1);
  static const Color darkText = Color(0xFF33293A);
  static const Color subText = Color(0xFF8A7E8D);

  static const String _testFullName = 'Ariful';
  static const String _testEmail = 'ariful@example.com';
  static const String _testEmergencyContact = '019369365656';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _longTermDiseasesController = TextEditingController();

  // --- NEW PHOTO VARIABLES ---
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  String? _selectedBloodGroup;
  DateTime? _lmpDate;
  DateTime? _estimatedDueDate;
  int? _pregnancyWeek;

  String _userEmail = '';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _emergencyContactController.dispose();
    _allergiesController.dispose();
    _longTermDiseasesController.dispose();
    super.dispose();
  }

  // --- NEW PHOTO PICKING METHOD ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> loadProfile() async {
    setState(() => _isLoading = true);
    try {
      _userEmail = _testEmail;
      _fullNameController.text = _testFullName;
      _emergencyContactController.text = _testEmergencyContact;
    } catch (e) {
      _showSnackBar('Failed to load profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void calculatePregnancy() {
    if (_lmpDate == null) return;
    final DateTime today = DateTime.now();
    final DateTime edd = _lmpDate!.add(const Duration(days: 280));
    final int daysSinceLmp = today.difference(_lmpDate!).inDays;
    setState(() {
      _estimatedDueDate = edd;
      _pregnancyWeek = daysSinceLmp > 0 ? (daysSinceLmp / 7).floor() : 0;
    });
  }

  Future<void> _pickLmpDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lmpDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'Select Last Menstrual Period',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: primaryPink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _lmpDate = picked);
      calculatePregnancy();
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all required fields correctly.', isError: true);
      return;
    }
    if (_selectedBloodGroup == null) {
      _showSnackBar('Please select your blood group.', isError: true);
      return;
    }
    if (_lmpDate == null) {
      _showSnackBar('Please select your Last Menstrual Period (LMP).', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> profileData = {
        'fullName': _fullNameController.text.trim(),
        'email': _userEmail,
        'bloodGroup': _selectedBloodGroup,
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
        'height': double.tryParse(_heightController.text.trim()) ?? 0.0,
        'emergencyContact': _emergencyContactController.text.trim(),
        'lmp': _lmpDate?.toIso8601String(),
        'estimatedDueDate': _estimatedDueDate?.toIso8601String(),
        'pregnancyWeek': _pregnancyWeek ?? 0,
        'allergies': _allergiesController.text.trim(),
        'longTermDiseases': _longTermDiseasesController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
        'imagePath': _pickedImage?.path, // Log the image path
      };

      await Future.delayed(const Duration(milliseconds: 600));
      debugPrint('TEST MODE — profile data saved: $profileData');
      _showSnackBar('Profile saved successfully! (test mode)');
    } catch (e) {
      _showSnackBar('Failed to save profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink.withOpacity(0.4),
      appBar: AppBar(
        title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryPink))
          : SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth > 700 ? 650 : constraints.maxWidth;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // _buildProfileHeader(),
                        // const SizedBox(height: 24),
                        // _buildPersonalDetailsCard(),
                        // const SizedBox(height: 20),
                        // _buildMedicalHistoryCard(),
                        const SizedBox(height: 28),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _readOnlyInfoBox({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: lightPink, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 14, color: primaryPink), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10, color: subText))]),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: ElevatedButton(onPressed: saveProfile, style: ElevatedButton.styleFrom(backgroundColor: primaryPink), child: const Text('Save Information', style: TextStyle(color: Colors.white)))),
      ],
    );
  }
}