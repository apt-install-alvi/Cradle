import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/routes/app_routes.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final enteredOtp = _otpController.text.trim();
      // Dummy verification (OTP: 123456)
      if (enteredOtp == '123456') {
        // Extract arguments
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
        final name = args?['name'] ?? 'Mother';

        // Save name to AuthProvider
        Provider.of<AuthProvider>(context, listen: false).setUserName(name);

        // Correct OTP - Navigate to Dashboard
        Navigator.pushNamed(
          context,
          AppRoutes.dashboard,
        );
      } else {
        final isBangla = Provider.of<LanguageProvider>(context, listen: false).isBangla;
        setState(() {
          _errorMessage = isBangla
              ? 'ভুল ওটিপি কোড! অনুগ্রহ করে ১২৩৪৫৬ ব্যবহার করুন।'
              : 'Invalid OTP code! Please use 123456.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF7F2F6);
    const Color secondaryColor = Color(0xFFAB0A65);
    const Color textColor = Color(0xFF4A3E48);

    // Extract arguments from route settings
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final phoneNumber = args?['phoneNumber'] ?? '';

    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    final String subtitle = isBangla ? 'একজন মায়ের সুরক্ষিত যত্ন' : "A Mother's Secure Care";
    final String otpHeader = isBangla ? 'ওটিপি যাচাইকরণ' : 'OTP Verification';
    final String otpSub = isBangla
        ? 'আপনার $phoneNumber নম্বরে পাঠানো কোডটি লিখুন'
        : 'Enter the code sent to your number $phoneNumber';
    final String otpLabel = isBangla ? 'ওটিপি কোড' : 'OTP Code';
    final String otpHint = isBangla ? '১২৩৪৫৬' : '123456';
    final String otpError = isBangla ? 'দয়া করে ওটিপি কোডটি লিখুন' : 'Please enter the OTP code';
    final String otpLengthError = isBangla ? 'ওটিপি কোডটি ৬ ডিজিটের হতে হবে' : 'OTP code must be 6 digits';
    final String submitBtn = isBangla ? 'সম্পন্ন করুন' : 'Verify & Proceed';
    final String resendBtn = isBangla ? 'আবার কোড পাঠান' : 'Resend Code';
    final String resendMessage = isBangla
        ? 'ওটিপি পুনরায় পাঠানো হয়েছে (১২৩৪৫৬)'
        : 'OTP has been resent (123456)';

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
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Logo at the same position
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
                    style: isBangla
                        ? GoogleFonts.geo(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: secondaryColor,
                            letterSpacing: 2.0,
                          )
                        : GoogleFonts.gentiumBookPlus(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                            letterSpacing: 2.0,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: isBangla
                        ? const TextStyle(
                            fontSize: 14,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          )
                        : GoogleFonts.gentiumBookPlus(
                            fontSize: 14,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                  const SizedBox(height: 50),
                  
                  // OTP Verification Header (Center Aligned)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          otpHeader,
                          textAlign: TextAlign.center,
                          style: isBangla
                              ? const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                )
                              : GoogleFonts.gentiumBookPlus(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          otpSub,
                          textAlign: TextAlign.center,
                          style: isBangla
                              ? TextStyle(
                                  fontSize: 13,
                                  color: textColor.withValues(alpha: 0.7),
                                )
                              : GoogleFonts.gentiumBookPlus(
                                  fontSize: 13,
                                  color: textColor.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Field
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: isBangla
                        ? const TextStyle(
                            color: textColor,
                            fontSize: 22,
                            letterSpacing: 8.0,
                            fontWeight: FontWeight.bold,
                          )
                        : GoogleFonts.gentiumBookPlus(
                            color: textColor,
                            fontSize: 22,
                            letterSpacing: 8.0,
                            fontWeight: FontWeight.bold,
                          ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: otpLabel,
                      labelStyle: isBangla
                          ? const TextStyle(
                              color: secondaryColor,
                              fontSize: 14,
                              letterSpacing: 0.0,
                            )
                          : GoogleFonts.gentiumBookPlus(
                              color: secondaryColor,
                              fontSize: 14,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      hintText: otpHint,
                      hintStyle: isBangla
                          ? TextStyle(
                              color: textColor.withValues(alpha: 0.3),
                              fontSize: 20,
                              letterSpacing: 8.0,
                            )
                          : GoogleFonts.gentiumBookPlus(
                              color: textColor.withValues(alpha: 0.3),
                              fontSize: 20,
                              letterSpacing: 8.0,
                              fontWeight: FontWeight.bold,
                            ),
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
                        return otpError;
                      }
                      if (value.trim().length != 6) {
                        return otpLengthError;
                      }
                      return null;
                    },
                  ),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: isBangla
                          ? const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            )
                          : GoogleFonts.gentiumBookPlus(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _verifyOtp,
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
                        style: isBangla
                            ? const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )
                            : GoogleFonts.gentiumBookPlus(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Resend Code Button
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            resendMessage,
                            style: isBangla
                                ? const TextStyle(fontSize: 14)
                                : GoogleFonts.gentiumBookPlus(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: secondaryColor,
                        ),
                      );
                    },
                    child: Text(
                      resendBtn,
                      style: isBangla
                          ? const TextStyle(
                              color: secondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )
                          : GoogleFonts.gentiumBookPlus(
                              color: secondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
