import 'package:flutter/material.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/risk_pill.dart';
import '../../core/widgets/bottom_nav.dart';
/// Shows the AI-recommended diagnosis, the symptoms it was based on, and
/// a risk-appropriate call to action — escalating to emergency actions
/// for high-risk results.
///
/// Order on screen: 1) recommended diagnosis, 2) reported symptoms,
/// 3) the risk warning banner (medium/high only), 4) emergency actions
/// (high risk only).
class AiRiskAssessmentPage extends StatelessWidget {
  final DiagnosisResult result;

  const AiRiskAssessmentPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final risk = result.riskLevel;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(
      selectedIndex: 1,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFAB0A65),
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 12),
            // const SizedBox(height: 4),
            _DiagnosisHero(result: result),
            const SizedBox(height: 16),
            _SymptomsSection(result: result),
            const SizedBox(height: 16),
            if (risk.recommendsDoctorVisit) ...[
              _WarningBanner(riskLevel: risk, message: result.warningMessage),
              const SizedBox(height: 16),
            ],
            if (risk.isEmergency) ...[
              AppButton(
                label: 'Inform Emergency Contacts',
                icon: Icons.contact_phone_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: () {
                  // TODO: wire up to the user's saved emergency contacts.
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Call Ambulance · 999',
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

class _DiagnosisHero extends StatelessWidget {
  final DiagnosisResult result;
  const _DiagnosisHero({required this.result});

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
          const Text('RECOMMENDED DIAGNOSIS', style: AppText.eyebrow),
          const SizedBox(height: 8),
          Text(
            result.diagnosisName,
            textAlign: TextAlign.center,
            style: AppText.diagnosisTitle,
          ),
          const SizedBox(height: 12),
          RiskPill(riskLevel: result.riskLevel),
        ],
      ),
    );
  }
}

class _SymptomsSection extends StatelessWidget {
  final DiagnosisResult result;
  const _SymptomsSection({required this.result});

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
          const Text(
            'REPORTED SYMPTOMS',
            style: TextStyle(
              fontSize: 13,
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
                  entry.displayLabel,
                  style: const TextStyle(
                    fontSize: 12,
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: riskLevel.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
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
