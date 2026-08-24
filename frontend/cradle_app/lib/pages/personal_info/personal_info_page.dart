import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/bottom_nav.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  static const Color _accent = Color(0xFFAB0A65);
  static const Color _secondaryWhite = Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _longTermDiseasesController = TextEditingController();

  XFile? _pickedImage;
  String? _base64Image;
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, // Resize for performance
      maxHeight: 512,
      imageQuality: 70,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.fetchProfile();
      final data = authProvider.profile;

      _fullNameController.text = data['full_name'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _weightController.text = data['weight']?.toString() ?? '';
      _heightController.text = data['height']?.toString() ?? '';
      _emergencyContactController.text = data['emergency_contact'] ?? '';
      _allergiesController.text = data['allergies'] ?? '';
      _longTermDiseasesController.text = data['long_term_diseases'] ?? '';
      _selectedBloodGroup = data['blood_group'];
      _base64Image = data['profile_image'];

      if (data['conception_date'] != null) {
        _lmpDate = DateTime.parse(data['conception_date']);
        calculatePregnancy();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
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
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: _accent,
              onPrimary: _secondaryWhite,
              surface: _secondaryWhite,
              onSurface: Color(0xFF3A2C33),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: _secondaryWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final Map<String, dynamic> profileData = {
        'full_name': _fullNameController.text.trim(),
        'blood_group': _selectedBloodGroup,
        'age': int.tryParse(_ageController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()),
        'height': double.tryParse(_heightController.text.trim()),
        'emergency_contact': _emergencyContactController.text.trim(),
        'conception_date': _lmpDate?.toIso8601String(),
        'expected_due_date': _estimatedDueDate?.toIso8601String(),
        'pregnancy_week': _pregnancyWeek,
        'allergies': _allergiesController.text.trim(),
        'long_term_diseases': _longTermDiseasesController.text.trim(),
        'profile_image': _base64Image,
      };

      await authProvider.updateProfile(profileData);
      if (mounted) {
        _showSnackBar(isBangla ? 'প্রোফাইল সফলভাবে সংরক্ষিত!' : 'Profile saved successfully!');
        // Navigate to dashboard after saving
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar(isBangla ? 'ব্যর্থ হয়েছে: $e' : 'Failed to save: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.gentiumBookPlus(color: _secondaryWhite)),
        backgroundColor: isError ? Colors.red.shade700 : _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    return Scaffold(
      bottomNavigationBar: const DashboardBottomNav(selectedIndex: -1),
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth > 700 ? 650 : constraints.maxWidth;
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 180),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTopBar(isBangla),
                                const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildTopBar(bool isBangla) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back, color: _accent, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBangla ? 'ব্যক্তিগত তথ্য' : 'Personal Info',
              style: AppText.headerTitle.copyWith(fontSize: 24),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.logout, color: _accent, size: 24),
            tooltip: isBangla ? 'লগ আউট' : 'Log Out',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isBangla) {
    ImageProvider? imageProvider;
    if (_base64Image != null) {
      imageProvider = MemoryImage(base64Decode(_base64Image!));
    }

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: _accent.withValues(alpha: 0.15),
              backgroundImage: imageProvider,
              child: imageProvider == null ? const Icon(Icons.person, size: 48, color: _accent) : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: _secondaryWhite, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          isBangla ? 'আবার স্বাগতম,' : 'Welcome back,',
          style: GoogleFonts.gentiumBookPlus(
            fontSize: 18,
            color: _accent.withValues(alpha: 0.65),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _fullNameController.text.isNotEmpty ? _fullNameController.text : (isBangla ? 'মা' : 'Mother'),
          style: GoogleFonts.gentiumBookPlus(fontSize: 24, fontWeight: FontWeight.bold, color: _accent),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: _accent),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.gentiumBookPlus(fontSize: 20, fontWeight: FontWeight.bold, color: _accent))
            ]),
            Divider(height: 24, thickness: 0.6, color: _accent.withValues(alpha: 0.08)),
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
      style: GoogleFonts.gentiumBookPlus(color: _accent, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.gentiumBookPlus(color: _accent.withValues(alpha: 0.7)),
        hintText: hint,
        hintStyle: GoogleFonts.gentiumBookPlus(color: _accent.withValues(alpha: 0.4)),
        prefixIcon: Icon(icon, color: _accent),
        filled: true,
        fillColor: _secondaryWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accent.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorStyle: GoogleFonts.gentiumBookPlus(color: Colors.red.shade800),
      ),
    );
  }

  Widget _buildBloodGroupDropdown(bool isBangla) {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      style: GoogleFonts.gentiumBookPlus(color: _accent, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: isBangla ? 'রক্তের গ্রুপ' : 'Blood Group',
        labelStyle: GoogleFonts.gentiumBookPlus(color: _accent.withValues(alpha: 0.7)),
        prefixIcon: const Icon(Icons.bloodtype_outlined, color: _accent),
        filled: true,
        fillColor: _secondaryWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accent.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      ),
      dropdownColor: _secondaryWhite,
      items: _bloodGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
      onChanged: (value) => setState(() => _selectedBloodGroup = value),
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
              filled: true,
              fillColor: _secondaryWhite,
              labelText: isBangla ? 'LMP তারিখ' : 'LMP Date',
              labelStyle: GoogleFonts.gentiumBookPlus(color: _accent, fontWeight: FontWeight.bold),
              prefixIcon: const Icon(Icons.calendar_today, color: _accent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _accent.withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _accent.withValues(alpha: 0.15)),
              ),
            ),
            child: Text(
              _lmpDate != null ? DateFormat('dd MMM yyyy').format(_lmpDate!) : (isBangla ? 'নির্বাচিত তারিখ' : 'Select Date'),
              style: GoogleFonts.gentiumBookPlus(color: _accent, fontWeight: FontWeight.bold),
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
        _buildTextField(controller: _allergiesController, label: isBangla ? 'এলার্জি' : 'Allergies', icon: Icons.warning_amber, maxLines: 2),
        const SizedBox(height: 16),
        _buildTextField(controller: _longTermDiseasesController, label: isBangla ? 'রোগ' : 'Diseases', icon: Icons.local_hospital, maxLines: 2),
      ],
    );
  }

  Widget _readOnlyInfoBox({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _secondaryWhite, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: _accent),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.gentiumBookPlus(fontSize: 16, color: _accent.withValues(alpha: 0.65), fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.gentiumBookPlus(fontWeight: FontWeight.bold, fontSize: 14, color: _accent)),
      ]),
    );
  }

  Widget _buildActionButtons(bool isBangla) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _accent.withValues(alpha: 0.25), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: Text(isBangla ? 'বাতিল করুন' : 'Cancel', style: GoogleFonts.gentiumBookPlus(color: _accent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSaving ? null : saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _secondaryWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 4,
              shadowColor: _accent.withValues(alpha: 0.35),
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: _secondaryWhite, strokeWidth: 2))
                : Text(isBangla ? 'সেভ করুন' : 'Save', style: GoogleFonts.gentiumBookPlus(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
