import 'package:flutter/material.dart';
import '../../pages/splash/splash_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/otp_verification/otp_verification_page.dart';
import '../../pages/personal_info/personal_info_page.dart';
import '../../pages/dashboard/dashboard_page.dart';
import '../../pages/symptom_input/symptom_input_page.dart';
import '../../pages/ai_risk_assessment/ai_risk_assessment_page.dart';
import '../../pages/health_history/health_history_page.dart';
import '../../pages/appointments/appointments_page.dart';
import '../../pages/emergency/emergency_alerts_page.dart';
import '../../pages/education/education_list_page.dart';
import '../../pages/notifications/notifications_page.dart';
import '../../pages/settings/settings_page.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.otp:
        return MaterialPageRoute(builder: (_) => const OtpVerificationPage());
      case AppRoutes.personalInfo:
        return MaterialPageRoute(builder: (_) => const PersonalInfoPage());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case AppRoutes.symptomInput:
        return MaterialPageRoute(builder: (_) => const SymptomInputPage());
      case AppRoutes.riskAssessment:
        return MaterialPageRoute(builder: (_) => const AiRiskAssessmentPage());
      case AppRoutes.healthHistory:
        return MaterialPageRoute(builder: (_) => const HealthHistoryPage());
      case AppRoutes.appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsPage());
      case AppRoutes.emergency:
        return MaterialPageRoute(builder: (_) => const EmergencyAlertsPage());
      case AppRoutes.education:
        return MaterialPageRoute(builder: (_) => const EducationListPage());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route Error')),
          ),
        );
    }
  }
}
