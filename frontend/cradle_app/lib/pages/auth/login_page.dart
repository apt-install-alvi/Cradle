import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Navigate to OTP verification page using named route with arguments
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: {
          'phoneNumber': _phoneController.text.trim(),
          'name': _nameController.text.trim(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF7F2F6);
    const Color secondaryColor = Color(0xFFAB0A65);
    const Color textColor = Color(0xFF4A3E48);

    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    final String subtitle = isBangla ? 'একজন মায়ের সুরক্ষিত যত্ন' : "A Mother's Secure Care";
    final String registerHeader = isBangla ? 'নিবন্ধন করুন' : 'Register';
    final String registerSub = isBangla ? 'এগিয়ে যেতে আপনার তথ্য প্রদান করুন' : 'Provide your details to proceed';
    final String nameLabel = isBangla ? 'নাম' : 'Name';
    final String nameHint = isBangla ? 'আপনার সম্পূর্ণ নাম লিখুন' : 'Enter your full name';
    final String nameError = isBangla ? 'দয়া করে আপনার নাম লিখুন' : 'Please enter your name';
    final String phoneLabel = isBangla ? 'মোবাইল নম্বর' : 'Mobile Number';
    final String phoneHint = isBangla ? '১১ ডিজিটের মোবাইল নম্বর' : '11-digit mobile number';
    final String phoneError = isBangla ? 'দয়া করে আপনার মোবাইল নম্বর লিখুন' : 'Please enter your mobile number';
    final String phoneInvalidError = isBangla ? 'দয়া করে একটি সঠিক মোবাইল নম্বর লিখুন' : 'Please enter a valid mobile number';
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
                  // Language Toggle Switch at top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
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
                                style: TextStyle(
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
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Logo from Splash Screen
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: secondaryColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      child: SvgPicture.asset(
                        'assets/images/Logo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // "Cradle" Name
                  Text(
                    'Cradle',
                    style: GoogleFonts.geo(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: secondaryColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Registration Header (Center Aligned)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          registerHeader,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          registerSub,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: nameLabel,
                      labelStyle: const TextStyle(color: secondaryColor, fontSize: 14),
                      hintText: nameHint,
                      hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 14),
                      prefixIcon: const Icon(Icons.person_outline, color: secondaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: secondaryColor.withValues(alpha: 0.2), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: secondaryColor, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return nameError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: phoneLabel,
                      labelStyle: const TextStyle(color: secondaryColor, fontSize: 14),
                      hintText: phoneHint,
                      hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 14),
                      prefixIcon: const Icon(Icons.phone_outlined, color: secondaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: secondaryColor.withValues(alpha: 0.2), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: secondaryColor, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return phoneError;
                      }
                      final phoneRegExp = RegExp(r'^(?:\+88|88)?(01[3-9]\d{8})$');
                      if (!phoneRegExp.hasMatch(value.trim())) {
                        return phoneInvalidError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        submitBtn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
