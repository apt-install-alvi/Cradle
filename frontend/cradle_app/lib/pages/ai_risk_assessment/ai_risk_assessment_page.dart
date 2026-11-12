import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Shows the AI-generated pregnancy risk assessment based on
/// the user's reported symptoms.
class AiRiskAssessmentPage extends StatelessWidget {
  final DiagnosisResult result;

  const AiRiskAssessmentPage({super.key, required this.result});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.isEmpty) return;

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch phone dialer: $e');
    }
  }

  List<String> _extractEmergencyContacts(Map<String, dynamic>? profile) {
    if (profile == null) return [];
    final raw = profile['emergency_contact'] ?? profile['emergency_contacts'];
    final List<String> list = [];

    if (raw is List) {
      for (final item in raw) {
        final str = item.toString().trim();
        if (str.isNotEmpty) list.add(str);
      }
    } else if (raw != null && raw.toString().trim().isNotEmpty) {
      list.add(raw.toString().trim());
    }

    return list;
  }

  void _handleEmergencyContactsCall(BuildContext context, bool isBangla) {
    final auth = context.read<AuthProvider>();
    final contacts = _extractEmergencyContacts(auth.profile);

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBangla
                ? 'কোনো জরুরি যোগাযোগ নম্বর পাওয়া যায়নি। প্রোফাইলে নম্বর যোগ করুন।'
                : 'No emergency contacts found. Please add contact numbers in your Profile.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (contacts.length == 1) {
      _makePhoneCall(context, contacts.first);
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBangla ? 'জরুরি পরিচিতিতে কল করুন' : 'Call Emergency Contact',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.roseDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...contacts.map((phone) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFBF2F5),
                        child: Icon(Icons.phone, color: AppColors.roseDark),
                      ),
                      title: Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _makePhoneCall(context, phone);
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final risk = result.riskLevel;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(
        selectedIndex: 1,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFFAB0A65),
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBangla ? 'ঝুঁকি মূল্যায়ন' : 'Risk Assessment',
                    style: AppText.headerTitle.copyWith(fontSize: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RiskHero(result: result, isBangla: isBangla),
            const SizedBox(height: 16),
            _SymptomsSection(result: result, isBangla: isBangla),
            const SizedBox(height: 16),
            if (risk.recommendsDoctorVisit) ...[
              _WarningBanner(
                riskLevel: risk,
                message: result.localizedWarningMessage(isBangla),
              ),
              const SizedBox(height: 16),
            ],
            if (risk.isEmergency) ...[
              AppButton(
                label: isBangla ? 'জরুরি যোগাযোগের নম্বরে জানান' : 'Inform Emergency Contacts',
                icon: Icons.contact_phone_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: () {
                  _handleEmergencyContactsCall(context, isBangla);
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: isBangla ? 'অ্যাম্বুলেন্স কল করুন · 999' : 'Call Ambulance · 999',
                icon: Icons.local_hospital_outlined,
                variant: AppButtonVariant.danger,
                onPressed: () {
                  _makePhoneCall(context, '999');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RiskHero extends StatelessWidget {
  final DiagnosisResult result;
  final bool isBangla;

  const _RiskHero({required this.result, required this.isBangla});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.largeCard),
        boxShadow: appCardShadow,
      ),
      child: Column(
        children: [
          Text(
            result.riskLevel.displayLabel(isBangla),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,              // <-- Change this to any size you want
              fontWeight: FontWeight.w800,
              color: result.riskLevel.color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isBangla
                ? 'আপনার প্রদত্ত উপসর্গের ভিত্তিতে এই ঝুঁকির মাত্রা নির্ধারণ করা হয়েছে।'
                : 'Based on your reported symptoms, your pregnancy risk level is shown above.',
            textAlign: TextAlign.center,
            style: AppText.subtext.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SymptomsSection extends StatelessWidget {
  final DiagnosisResult result;
  final bool isBangla;

  const _SymptomsSection({required this.result, required this.isBangla});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: appCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBangla ? 'উপসর্গসমূহ' : 'REPORTED SYMPTOMS',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.roseDark,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.reportedSymptoms.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF2F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.displayLabel(isBangla),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A4A5F),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final RiskLevel riskLevel;
  final String message;
  const _WarningBanner({required this.riskLevel, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: riskLevel.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.high,
          width: 0.5
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: riskLevel.color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: riskLevel.color,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
