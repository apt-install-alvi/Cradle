import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.register(
          _phoneController.text.trim(),
          _nameController.text.trim(),
        );
        
        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.otp,
            arguments: {
              'phoneNumber': _phoneController.text.trim(),
            },
          );
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
    final String authHeader = isBangla ? 'প্রবেশ করুন / নিবন্ধন করুন' : 'Login / Register';
    final String authSub = isBangla ? 'এগিয়ে যেতে আপনার তথ্য প্রদান করুন' : 'Provide your details to proceed';
    final String nameLabel = isBangla ? 'নাম' : 'Name';
    final String nameHint = isBangla ? 'আপনার সম্পূর্ণ নাম লিখুন' : 'Enter your full name';
    final String phoneLabel = isBangla ? 'মোবাইল নম্বর' : 'Mobile Number';
    final String phoneHint = isBangla ? '১১ ডিজিটের মোবাইল নম্বর' : '11-digit mobile number';
    final String submitBtn = isBangla ? 'এগিয়ে যান' : 'Proceed';

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
                    child: _buildLanguageToggle(secondaryColor, isBangla, textColor),
                  ),
                  const SizedBox(height: 25),
                  // Logo
                  _buildLogo(secondaryColor, subtitle, textColor),
                  const SizedBox(height: 50),
                  
                  // Header
                  _buildHeader(authHeader, isBangla, textColor, authSub),
                  const SizedBox(height: 32),

                  // Name Field
                  _buildNameField(textColor, isBangla, nameLabel, secondaryColor, nameHint),
                  const SizedBox(height: 20),

                  // Phone Field
                  _buildPhoneField(textColor, isBangla, phoneLabel, secondaryColor, phoneHint),
                  const SizedBox(height: 40),

                  // Submit Button
                  _buildSubmitButton(authProvider, _submitForm, secondaryColor, isBangla, submitBtn),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(Color secondaryColor, bool isBangla, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: secondaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.read<LanguageProvider>().setLanguage(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !isBangla ? secondaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'English',
                style: GoogleFonts.gentiumBookPlus(
                  color: !isBangla ? Colors.white : textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<LanguageProvider>().setLanguage(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isBangla ? secondaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'বাংলা',
                style: TextStyle(
                  color: isBangla ? Colors.white : textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildHeader(String authHeader, bool isBangla, Color textColor, String authSub) {
    return Center(
      child: Column(
        children: [
          Text(
            authHeader,
            textAlign: TextAlign.center,
            style: isBangla
                ? TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)
                : GoogleFonts.gentiumBookPlus(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            authSub,
            textAlign: TextAlign.center,
            style: isBangla
                ? TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7))
                : GoogleFonts.gentiumBookPlus(fontSize: 13, color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(Color textColor, bool isBangla, String nameLabel, Color secondaryColor, String nameHint) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      style: isBangla
          ? TextStyle(color: textColor, fontSize: 16)
          : GoogleFonts.gentiumBookPlus(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: nameLabel,
        labelStyle: isBangla
            ? TextStyle(color: secondaryColor, fontSize: 14)
            : GoogleFonts.gentiumBookPlus(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        hintText: nameHint,
        hintStyle: isBangla
            ? TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 14)
            : GoogleFonts.gentiumBookPlus(color: textColor.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.bold),
        prefixIcon: Icon(Icons.person_outline, color: secondaryColor),
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) return isBangla ? 'আপনার নাম লিখুন' : 'Please enter your name';
        return null;
      },
    );
  }

  Widget _buildPhoneField(Color textColor, bool isBangla, String phoneLabel, Color secondaryColor, String phoneHint) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: isBangla
          ? TextStyle(color: textColor, fontSize: 16)
          : GoogleFonts.gentiumBookPlus(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: phoneLabel,
        labelStyle: isBangla
            ? TextStyle(color: secondaryColor, fontSize: 14)
            : GoogleFonts.gentiumBookPlus(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.bold),
        hintText: phoneHint,
        hintStyle: isBangla
            ? TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 14)
            : GoogleFonts.gentiumBookPlus(color: textColor.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.bold),
        prefixIcon: Icon(Icons.phone_outlined, color: secondaryColor),
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) return isBangla ? 'মোবাইল নম্বর লিখুন' : 'Please enter phone number';
        final phoneRegExp = RegExp(r'^(?:\+88|88)?(01[3-9]\d{8})$');
        if (!phoneRegExp.hasMatch(value.trim())) return isBangla ? 'সঠিক নম্বর দিন' : 'Enter valid phone number';
        return null;
      },
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
}
