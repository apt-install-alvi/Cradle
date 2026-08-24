import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/language_toggle.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.register(
          _phoneController.text.trim(),
          _nameController.text.trim(),
          int.parse(_ageController.text.trim()),
        );

        if (mounted) {
          // Navigate to OTP page
          Navigator.pushNamed(context, AppRoutes.otp);
        }
      } catch (e) {
        if (mounted) {
          _showError(e.toString());
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF7F2F6);
    const Color secondaryColor = Color(0xFFAB0A65);
    const Color textColor = Color(0xFF4A3E48);

    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final bool isBangla = languageProvider.isBangla;

    final String subtitle = isBangla ? 'একজন মায়ের সুরক্ষিত যত্ন' : "A Mother's Secure Care";
    final String registerHeader = isBangla ? 'নিবন্ধন করুন' : 'Sign Up';
    final String registerSub = isBangla ? 'নিবন্ধন করতে আপনার তথ্য প্রদান করুন' : 'Provide your details to register';
    final String nameLabel = isBangla ? 'নাম' : 'Name';
    final String nameHint = isBangla ? 'আপনার সম্পূর্ণ নাম লিখুন' : 'Enter your full name';
    final String ageLabel = isBangla ? 'বয়স' : 'Age';
    final String ageHint = isBangla ? 'আপনার বয়স লিখুন' : 'Enter your age';
    final String phoneLabel = isBangla ? 'মোবাইল নম্বর' : 'Mobile Number';
    final String phoneHint = isBangla ? '১১ ডিজিটের মোবাইল নম্বর' : '11-digit mobile number';
    final String submitBtn = isBangla ? 'নিবন্ধন করুন' : 'Sign Up';

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Language Toggle Switch
                  Align(
                    alignment: Alignment.topRight,
                    child: LanguageToggle(
                      activeColor: secondaryColor,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Logo
                  _buildLogo(secondaryColor, subtitle, textColor),
                  const SizedBox(height: 50),

                  // Header
                  _buildHeader(registerHeader, isBangla, textColor, registerSub),
                  const SizedBox(height: 32),

                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: nameLabel,
                    hint: nameHint,
                    icon: Icons.person_outline,
                    secondaryColor: secondaryColor,
                    textColor: textColor,
                    isBangla: isBangla,
                    validator: (value) => (value == null || value.trim().isEmpty) ? (isBangla ? 'আপনার নাম লিখুন' : 'Please enter your name') : null,
                  ),
                  const SizedBox(height: 20),

                  // Age Field
                  _buildTextField(
                    controller: _ageController,
                    label: ageLabel,
                    hint: ageHint,
                    icon: Icons.cake_outlined,
                    secondaryColor: secondaryColor,
                    textColor: textColor,
                    isBangla: isBangla,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return isBangla ? 'আপনার বয়স লিখুন' : 'Please enter your age';
                      if (int.tryParse(value.trim()) == null) return isBangla ? 'সঠিক সংখ্যা দিন' : 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  _buildTextField(
                    controller: _phoneController,
                    label: phoneLabel,
                    hint: phoneHint,
                    icon: Icons.phone_outlined,
                    secondaryColor: secondaryColor,
                    textColor: textColor,
                    isBangla: isBangla,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return isBangla ? 'মোবাইল নম্বর লিখুন' : 'Please enter phone number';
                      final phoneRegExp = RegExp(r'^(?:\+88|88)?(01[3-9]\d{8})$');
                      if (!phoneRegExp.hasMatch(value.trim())) return isBangla ? 'সঠিক নম্বর দিন' : 'Enter valid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  _buildSubmitButton(authProvider, _submitForm, secondaryColor, isBangla, submitBtn),
                  const SizedBox(height: 24),

                  // Footer toggle
                  _buildFooterToggle(isBangla, secondaryColor),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Color secondaryColor, String subtitle, Color textColor) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          child: SvgPicture.asset(
            'assets/images/Logo.svg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cradle',
          style: GoogleFonts.geom(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: secondaryColor,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.geom(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, bool isBangla, Color textColor, String sub) {
    return Center(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: isBangla
                ? TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)
                : GoogleFonts.gentiumBookPlus(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: isBangla
                ? TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7))
                : GoogleFonts.gentiumBookPlus(fontSize: 13, color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color secondaryColor,
    required Color textColor,
    required bool isBangla,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: isBangla
          ? TextStyle(color: textColor, fontSize: 16)
          : GoogleFonts.gentiumBookPlus(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: isBangla
            ? TextStyle(color: secondaryColor, fontSize: 14)
            : GoogleFonts.gentiumBookPlus(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        hintText: hint,
        hintStyle: isBangla
            ? TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 14)
            : GoogleFonts.gentiumBookPlus(color: textColor.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: secondaryColor),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondaryColor.withValues(alpha: 0.2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondaryColor, width: 2.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: validator,
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider, Future<void> Function() submitForm, Color secondaryColor, bool isBangla, String submitBtn) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: authProvider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                submitBtn,
                style: isBangla
                    ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    : GoogleFonts.gentiumBookPlus(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildFooterToggle(bool isBangla, Color secondaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isBangla ? 'আগের অ্যাকাউন্ট? ' : "Already have an account? ",
          style: GoogleFonts.gentiumBookPlus(color: const Color(0xFF4A3E48)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            isBangla ? 'লগইন করুন' : 'Login here',
            style: GoogleFonts.gentiumBookPlus(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
