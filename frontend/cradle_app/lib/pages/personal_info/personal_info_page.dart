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
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildPersonalDetailsCard(),
                        const SizedBox(height: 20),
                        _buildMedicalHistoryCard(),
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

  // ============================================================
  // UPDATED SECTION: Profile Header with Photo Change Option
  // ============================================================
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: primaryPink.withOpacity(0.15),
              backgroundImage: _pickedImage != null
                  ? (kIsWeb
                  ? NetworkImage(_pickedImage!.path)
                  : FileImage(File(_pickedImage!.path)) as ImageProvider)
                  : null,
              child: _pickedImage == null
                  ? const Icon(Icons.person, size: 48, color: primaryPink)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage, // Calls the gallery
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: primaryPink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Welcome back,', style: TextStyle(fontSize: 14, color: subText)),
        const SizedBox(height: 2),
        Text(
          _fullNameController.text.isNotEmpty ? _fullNameController.text : 'Mother',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
        ),
        const SizedBox(height: 4),
        Text(_userEmail, style: const TextStyle(fontSize: 13, color: subText)),
      ],
    );
  }

  // --- All other helper methods (_sectionCard, _buildTextField, etc.) remain exactly the same ---

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: primaryPink), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: darkText))]),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? hint, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: darkText),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryPink),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 1.5)),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      decoration: InputDecoration(labelText: 'Blood Group', prefixIcon: const Icon(Icons.bloodtype_outlined, color: primaryPink), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200))),
      items: _bloodGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
      onChanged: (value) => setState(() => _selectedBloodGroup = value),
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  Widget _buildPersonalDetailsCard() {
    return _sectionCard(
      title: 'Personal Details',
      icon: Icons.badge_outlined,
      children: [
        _buildTextField(controller: _fullNameController, label: 'Full Name', icon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
        const SizedBox(height: 16),
        _buildBloodGroupDropdown(),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildTextField(controller: _ageController, label: 'Age', icon: Icons.cake_outlined, keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _buildTextField(controller: _weightController, label: 'Weight (kg)', icon: Icons.monitor_weight_outlined, keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 16),
        _buildTextField(controller: _heightController, label: 'Height (cm)', icon: Icons.height, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(controller: _emergencyContactController, label: 'Emergency Contact', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildMedicalHistoryCard() {
    return _sectionCard(
      title: 'Medical History',
      icon: Icons.medical_information_outlined,
      children: [
        InkWell(
          onTap: _pickLmpDate,
          child: InputDecorator(
            decoration: InputDecoration(labelText: 'LMP Date', prefixIcon: const Icon(Icons.calendar_today, color: primaryPink), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(_lmpDate != null ? DateFormat('dd MMM yyyy').format(_lmpDate!) : 'Select Date'),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _readOnlyInfoBox(icon: Icons.pregnant_woman, label: 'Week', value: _pregnancyWeek != null ? 'Week $_pregnancyWeek' : '--')),
          const SizedBox(width: 12),
          Expanded(child: _readOnlyInfoBox(icon: Icons.event, label: 'Due Date', value: _estimatedDueDate != null ? DateFormat('dd MMM yyyy').format(_estimatedDueDate!) : '--')),
        ]),
        const SizedBox(height: 16),
        _buildTextField(controller: _allergiesController, label: 'Allergies', icon: Icons.warning_amber, maxLines: 2),
        const SizedBox(height: 16),
        _buildTextField(controller: _longTermDiseasesController, label: 'Diseases', icon: Icons.local_hospital, maxLines: 2),
      ],
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