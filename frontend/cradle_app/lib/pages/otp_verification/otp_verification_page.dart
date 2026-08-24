import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/language_toggle.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  bool _isVerifying = false;

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isVerifying = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        final code = _otpController.text.trim();
        debugPrint('[OTP] Attempting verification for code: $code');

        await authProvider.verifyOtp(code);
        
        if (mounted) {
          debugPrint('[OTP] Verification successful. Profile completed: ${authProvider.isProfileCompleted}');
          if (authProvider.isProfileCompleted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.personalInfo,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          debugPrint('[OTP] Verification failed: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isBangla = Provider.of<LanguageProvider>(context, listen: false).isBangla;
    try {
      await authProvider.resendOtp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBangla ? 'ওটিপি পুনরায় পাঠানো হয়েছে' : 'OTP has been resent',
            ),
            backgroundColor: const Color(0xFFAB0A65),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF7F2F6);
    const Color secondaryColor = Color(0xFFAB0A65);
    const Color textColor = Color(0xFF4A3E48);

    final authProvider = context.watch<AuthProvider>();
    final phoneNumber = authProvider.phone ?? '';

    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    final String subtitle = isBangla ? 'একজন মায়ের সুরক্ষিত যত্ন' : "A Mother's Secure Care";
    final String otpHeader = isBangla ? 'ওটিপি যাচাইকরণ' : 'OTP Verification';
    final String otpSub = isBangla
        ? 'আপনার $phoneNumber নম্বরে পাঠানো কোডটি লিখুন'
        : 'Enter the code sent to your number $phoneNumber';
    final String otpLabel = isBangla ? 'ওটিপি কোড' : 'OTP Code';
    final String otpHint = isBangla ? '০০০০০০' : '000000';
    final String submitBtn = isBangla ? 'সম্পন্ন করুন' : 'Verify & Proceed';
    final String resendBtn = isBangla ? 'আবার কোড পাঠান' : 'Resend Code';

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
                  _buildLogo(secondaryColor, subtitle, textColor, isBangla),
                  const SizedBox(height: 50),
                  
                  // Header
                  _buildHeader(otpHeader, isBangla, textColor, otpSub),
                  const SizedBox(height: 32),

                  // OTP Input Field
                  _buildOtpField(textColor, isBangla, otpLabel, secondaryColor, otpHint),
                  
                  const SizedBox(height: 40),

                  // Done Button
                  _buildSubmitButton(authProvider, _verifyOtp, secondaryColor, isBangla, submitBtn),
                  const SizedBox(height: 24),
                  
                  // Resend Code Button
                  _buildResendButton(authProvider, _resendOtp, secondaryColor, isBangla, resendBtn),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(Color secondaryColor, bool isBangla, Color textColor) {
    return LanguageToggle(
      activeColor: secondaryColor,
      textColor: textColor,
    );
  }

  Widget _buildLogo(Color secondaryColor, String subtitle, Color textColor, bool isBangla) {
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
          style: isBangla
              ? TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w500)
              : GoogleFonts.gentiumBookPlus(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHeader(String otpHeader, bool isBangla, Color textColor, String otpSub) {
    return Center(
      child: Column(
        children: [
          Text(
            otpHeader,
            textAlign: TextAlign.center,
            style: isBangla
                ? TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)
                : GoogleFonts.gentiumBookPlus(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            otpSub,
            textAlign: TextAlign.center,
            style: isBangla
                ? TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7))
                : GoogleFonts.gentiumBookPlus(fontSize: 13, color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(Color textColor, bool isBangla, String otpLabel, Color secondaryColor, String otpHint) {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: isBangla
          ? TextStyle(color: textColor, fontSize: 22, letterSpacing: 8.0, fontWeight: FontWeight.bold)
          : GoogleFonts.gentiumBookPlus(color: textColor, fontSize: 22, letterSpacing: 8.0, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        counterText: '',
        labelText: otpLabel,
        labelStyle: isBangla
            ? TextStyle(color: secondaryColor, fontSize: 14, letterSpacing: 0.0)
            : GoogleFonts.gentiumBookPlus(color: secondaryColor, fontSize: 14, letterSpacing: 0.0, fontWeight: FontWeight.bold),
        hintText: otpHint,
        hintStyle: isBangla
            ? TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 20, letterSpacing: 8.0)
            : GoogleFonts.gentiumBookPlus(color: textColor.withValues(alpha: 0.3), fontSize: 20, letterSpacing: 8.0, fontWeight: FontWeight.bold),
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
        if (value == null || value.trim().isEmpty) return isBangla ? 'ওটিপি কোড দিন' : 'Enter OTP code';
        if (value.trim().length != 6) return isBangla ? '৬ ডিজিট হতে হবে' : 'Must be 6 digits';
        return null;
      },
      onChanged: (value) {
        if (value.trim().length == 6 && !_isVerifying) {
          _verifyOtp();
        }
      },
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider, Future<void> Function() verifyOtp, Color secondaryColor, bool isBangla, String submitBtn) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : verifyOtp,
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

  Widget _buildResendButton(AuthProvider authProvider, Future<void> Function() resendOtp, Color secondaryColor, bool isBangla, String resendBtn) {
    return TextButton(
      onPressed: authProvider.isLoading ? null : resendOtp,
      child: Text(
        resendBtn,
        style: isBangla
            ? TextStyle(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.bold)
            : GoogleFonts.gentiumBookPlus(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
