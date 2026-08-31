import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

/// Shows the AI-generated pregnancy risk assessment based on
/// the user's reported symptoms and physiological parameters.
class AiRiskAssessmentPage extends StatelessWidget {
  final DiagnosisResult result;

  const AiRiskAssessmentPage({super.key, required this.result});

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
                  // TODO: wire up to the user's saved emergency contacts.
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: isBangla ? 'অ্যাম্বুলেন্স কল করুন · 999' : 'Call Ambulance · 999',
                icon: Icons.local_hospital_outlined,
                variant: AppButtonVariant.danger,
                onPressed: () {
                  // TODO: launch the dialer with the local emergency number.
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
        // Primary colour - FFFFFF 52% opacity
        color: Colors.white.withOpacity(0.52),
        borderRadius: BorderRadius.circular(AppRadii.largeCard),
        border: Border.all(color: const Color(0xFFAB0A65).withOpacity(0.15), width: 1.5),
        boxShadow: appCardShadow,
      ),
      child: Column(
        children: [
          Text(
            result.riskLevel.displayLabel(isBangla),
            textAlign: TextAlign.center,
            style: GoogleFonts.gentiumBookPlus(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: result.riskLevel.color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isBangla
                ? 'আপনার প্রদত্ত স্বাস্থ্যের প্যারামিটার ও উপসর্গের ভিত্তিতে এই ঝুঁকির মাত্রা নির্ধারণ করা হয়েছে।'
                : 'Based on your reported health parameters and symptoms, your pregnancy risk level is shown above.',
            textAlign: TextAlign.center,
            style: AppText.subtext.copyWith(fontSize: 14, color: const Color(0xFFAB0A65)),
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
        // Primary colour - FFFFFF 52% opacity
        color: Colors.white.withOpacity(0.52),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: const Color(0xFFAB0A65).withOpacity(0.15), width: 1.5),
        boxShadow: appCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBangla ? 'মূল্যায়িত উপসর্গ ও বিবরণ' : 'EVALUATED SYMPTOMS & DETAILS',
            style: GoogleFonts.gentiumBookPlus(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: const Color(0xFFAB0A65),
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
                  color: const Color(0xFFAB0A65).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFAB0A65).withOpacity(0.2), width: 1),
                ),
                child: Text(
                  entry.displayLabel(isBangla),
                  style: GoogleFonts.gentiumBookPlus(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFAB0A65),
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
          color: riskLevel.color,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: riskLevel.color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.gentiumBookPlus(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: riskLevel.color,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
