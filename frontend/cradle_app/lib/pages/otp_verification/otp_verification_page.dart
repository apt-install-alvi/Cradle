import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phone;

  const OtpVerificationPage({Key? key, required this.phone}) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final code = _codeController.text.trim();

    final success = await auth.verifyOtp(code);
    if (success) {
      if (mounted) {
        if (auth.isProfileCompleted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.personalInfo, (route) => false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid or expired OTP code.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify Your Phone',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit verification code to\n${widget.phone}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  '(For local testing, enter: 123456)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: _codeController,
                  labelText: 'Verification Code',
                  hintText: 'e.g. 123456',
                  prefixIcon: Icons.security_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().length != 6) {
                      return 'Enter the 6-digit verification code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: 'Verify & Continue',
                      isLoading: auth.isLoading,
                      onPressed: _verify,
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Simulates OTP resend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP verification code resent.')),
                    );
                  },
                  child: Text(
                    'Resend Code',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


