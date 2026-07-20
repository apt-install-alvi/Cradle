import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // NEW
import 'dart:io'; // NEW (for File)
import 'package:flutter/foundation.dart' show kIsWeb; // NEW (for Web check)
import 'package:provider/provider.dart'; // NEW
import '../../providers/auth_provider.dart'; // NEW
import '../../providers/language_provider.dart'; // NEW
import '../../core/routes/app_routes.dart'; // NEW

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
// used only for date formatting (dd MMM yyyy)

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

  // static const String _testFullName = 'Ariful';
  static const String _testEmail = 'xyz@example.com';
  static const String _testEmergencyContact = '01xxxxxxxxx';

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isBangla = Provider.of<LanguageProvider>(context, listen: false).isBangla;
      _userEmail = _testEmail;
      _fullNameController.text = authProvider.userName.isNotEmpty
          ? authProvider.userName
          : (isBangla ? 'মা' : 'Mother');
      _emergencyContactController.text = _testEmergencyContact;
    } catch (e) {
      final isBangla = Provider.of<LanguageProvider>(context, listen: false).isBangla;
      _showSnackBar(
        isBangla ? 'প্রোফাইল লোড করতে ব্যর্থ হয়েছে: $e' : 'Failed to load profile: $e',
        isError: true,
      );
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
    final isBangla = Provider.of<LanguageProvider>(context, listen: false).isBangla;
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lmpDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: isBangla ? 'শেষ মাসিকের সময়কাল নির্বাচন করুন' : 'Select Last Menstrual Period Date',
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
    final isBangla = Provider.of<LanguageProvider>(context, listen: false).isBangla;
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        isBangla
            ? 'অনুগ্রহ করে সকল প্রয়োজনীয় ক্ষেত্র সঠিকভাবে পূরণ করুন ।'
            : 'Please fill all required fields correctly.',
        isError: true,
      );
      return;
    }
    if (_selectedBloodGroup == null) {
      _showSnackBar(
        isBangla ? 'অনুগ্রহ করে আপনার রক্তের গ্রুপ নির্বাচন করুন ।' : 'Please select your blood group.',
        isError: true,
      );
      return;
    }
    if (_lmpDate == null) {
      _showSnackBar(
        isBangla
            ? 'অনুগ্রহ করে আপনার শেষ মাসিকের সময় (LMP) নির্বাচন করুন । '
            : 'Please select your last menstrual period (LMP) date.',
        isError: true,
      );
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
      _showSnackBar(isBangla ? 'প্রোফাইল সফলভাবে সংরক্ষিত!' : 'Profile saved successfully!');
    } catch (e) {
      _showSnackBar(
        isBangla ? 'প্রোফাইল সেভ করতে ব্যর্থ হয়েছে: $e' : 'Failed to save profile: $e',
        isError: true,
      );
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
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    return Scaffold(
      backgroundColor: lightPink.withValues(alpha: 0.4),
      appBar: AppBar(
        title: Text(
          isBangla ? 'ব্যক্তিগত তথ্য' : 'Personal Info',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        // --- ADDED LOGOUT BUTTON HERE ---
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: isBangla ? 'লগ আউট' : 'Log Out',
            onPressed: () {
              // Clear session and return to login
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
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
                              _buildProfileHeader(isBangla),
                              const SizedBox(height: 24),
                              _buildPersonalDetailsCard(isBangla),
                              const SizedBox(height: 20),
                              _buildMedicalHistoryCard(isBangla),
                              const SizedBox(height: 28),
                              _buildActionButtons(isBangla),
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
  Widget _buildProfileHeader(bool isBangla) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: primaryPink.withValues(alpha: 0.15),
              backgroundImage: _pickedImage != null
                  ? (kIsWeb ? NetworkImage(_pickedImage!.path) : FileImage(File(_pickedImage!.path)) as ImageProvider)
                  : null,
              child: _pickedImage == null ? const Icon(Icons.person, size: 48, color: primaryPink) : null,
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
        Text(isBangla ? 'আবার স্বাগতম,' : 'Welcome back,', style: const TextStyle(fontSize: 14, color: subText)),
        const SizedBox(height: 2),
        Text(
          _fullNameController.text.isNotEmpty ? _fullNameController.text : (isBangla ? 'মা' : 'Mother'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
        ),
        const SizedBox(height: 4),
        Text(_userEmail, style: const TextStyle(fontSize: 13, color: subText)),
      ],
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: primaryPink),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: darkText))
            ]),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 1.5)),
      ),
    );
  }

  Widget _buildBloodGroupDropdown(bool isBangla) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBloodGroup,
      decoration: InputDecoration(
        labelText: isBangla ? 'রক্তের গ্রুপ' : 'Blood Group',
        prefixIcon: const Icon(Icons.bloodtype_outlined, color: primaryPink),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      items: _bloodGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
      onChanged: (value) => setState(() => _selectedBloodGroup = value),
      validator: (value) => value == null ? (isBangla ? 'প্রয়োজন' : 'Required') : null,
    );
  }

  Widget _buildPersonalDetailsCard(bool isBangla) {
    return _sectionCard(
      title: isBangla ? 'ব্যক্তিগত বিবরণ' : 'Personal Details',
      icon: Icons.badge_outlined,
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: isBangla ? 'পুরো নাম' : 'Full Name',
          icon: Icons.person_outline,
          validator: (v) => (v == null || v.isEmpty) ? (isBangla ? 'প্রয়োজন' : 'Required') : null,
        ),
        const SizedBox(height: 16),
        _buildBloodGroupDropdown(isBangla),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: _buildTextField(
              controller: _ageController,
              label: isBangla ? 'বয়স' : 'Age',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              controller: _weightController,
              label: isBangla ? 'ওজন (কেজি)' : 'Weight (kg)',
              icon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _heightController,
          label: isBangla ? 'উচ্চতা (সেমি)' : 'Height (cm)',
          icon: Icons.height,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyContactController,
          label: isBangla ? 'জরুরী যোগাযোগ' : 'Emergency Contact',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildMedicalHistoryCard(bool isBangla) {
    return _sectionCard(
      title: isBangla ? 'মেডিকেল ইতিহাস' : 'Medical History',
      icon: Icons.medical_information_outlined,
      children: [
        InkWell(
          onTap: _pickLmpDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: isBangla ? 'LMP তারিখ' : 'LMP Date',
              prefixIcon: const Icon(Icons.calendar_today, color: primaryPink),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _lmpDate != null
                  ? DateFormat('dd MMM yyyy').format(_lmpDate!)
                  : (isBangla ? 'নির্বাচিত তারিখ' : 'Select Date'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: _readOnlyInfoBox(
              icon: Icons.pregnant_woman,
              label: isBangla ? 'সপ্তাহ' : 'Week',
              value: _pregnancyWeek != null ? (isBangla ? 'সপ্তাহ $_pregnancyWeek' : 'Week $_pregnancyWeek') : '--',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _readOnlyInfoBox(
              icon: Icons.event,
              label: isBangla ? 'বাকি তারিখ' : 'Due Date',
              value: _estimatedDueDate != null ? DateFormat('dd MMM yyyy').format(_estimatedDueDate!) : '--',
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _allergiesController,
          label: isBangla ? 'এলার্জি' : 'Allergies',
          icon: Icons.warning_amber,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _longTermDiseasesController,
          label: isBangla ? 'রোগ' : 'Diseases',
          icon: Icons.local_hospital,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _readOnlyInfoBox({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: lightPink, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: primaryPink),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: subText))
        ]),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }

  Widget _buildActionButtons(bool isBangla) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: Text(isBangla ? 'বাতিল করুন' : 'Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSaving ? null : saveProfile,
            style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(isBangla ? 'সেভ করুন' : 'Save', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}