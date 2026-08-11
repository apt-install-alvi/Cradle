import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../health_monitor/widgets/health_top_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/font_size_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  // ── Colour constants ──────────────────────────────────────────────
static const Color _accent = Color(0xFFAB0A65);
static const Color _brandSofter = Color(0xFFFCEEF5);
static const Color _brandSoft = Color(0xFFF6D9E9);
static const Color _ink = Color(0xFF3A2C33);
static const Color _muted = Color(0xFF8A7680);
static const Color _secondaryWhite = Colors.white;

static const List<BoxShadow> _cardShadow = [
  BoxShadow(
    color: Color(0x29C87896),
    blurRadius: 16,
    offset: Offset(0, 6),
  ),
];

TextStyle _sectionTitle() => GoogleFonts.gentiumBookPlus(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: _accent.withValues(alpha: 0.65),
    );

TextStyle _itemTitle() => const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: _ink,
    );

TextStyle _itemSubtitle() => const TextStyle(
      fontSize: 14,
      color: _muted,
    );

  // ── Toggle states ─────────────────────────────────────────────────
  bool _pushNotifications = true;
  bool _appointmentReminders = true;
  bool _healthAlerts = true;
  bool _locationAccess = true;
  bool _analyticsEnabled = true;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
Widget build(BuildContext context) {
  final languageProvider = context.watch<LanguageProvider>();
  final authProvider = context.watch<AuthProvider>();

  final bool isBangla = languageProvider.isBangla;
  final String userName =
      authProvider.userName.isEmpty ? 'User' : authProvider.userName;

  return GradientScaffold(
    bottomNavigationBar: const DashboardBottomNav(
      selectedIndex: -1,
    ),
    child: FadeTransition(
      opacity: _fadeIn,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 180),
        children: [
          const SizedBox(height: 12),

          // ── Header ─────────────────────────────────────────────
          HealthTopBar(
            title: isBangla ? 'সেটিংস' : 'Settings',
          ),

          const SizedBox(height: 12),

          // ── Profile ────────────────────────────────────────────
          _buildProfileCard(userName, isBangla),

          const SizedBox(height: 26),

          // ── Notifications ─────────────────────────────────────
          _buildSectionLabel(
            isBangla ? 'বিজ্ঞপ্তি' : 'NOTIFICATIONS',
          ),
          const SizedBox(height: 10),

          _buildToggleCard(
            icon: Icons.notifications_active_rounded,
            title: isBangla ? 'পুশ বিজ্ঞপ্তি' : 'Push Notifications',
            subtitle: isBangla
                ? 'অ্যাপ বিজ্ঞপ্তি গ্রহণ করুন'
                : 'Receive app notifications',
            value: _pushNotifications,
            onChanged: (v) {
              setState(() => _pushNotifications = v);
            },
          ),

          const SizedBox(height: 14),

          _buildToggleCard(
            icon: Icons.calendar_month_rounded,
            title: isBangla
                ? 'অ্যাপয়েন্টমেন্ট রিমাইন্ডার'
                : 'Appointment Reminders',
            subtitle: isBangla
                ? 'আসন্ন অ্যাপয়েন্টমেন্টের জন্য সতর্কতা'
                : 'Alerts for upcoming appointments',
            value: _appointmentReminders,
            onChanged: (v) {
              setState(() => _appointmentReminders = v);
            },
          ),

          const SizedBox(height: 14),

          _buildToggleCard(
            icon: Icons.health_and_safety_rounded,
            title: isBangla ? 'স্বাস্থ্য সতর্কতা' : 'Health Alerts',
            subtitle: isBangla
                ? 'গুরুত্বপূর্ণ স্বাস্থ্য বিজ্ঞপ্তি'
                : 'Important health notifications',
            value: _healthAlerts,
            onChanged: (v) {
              setState(() => _healthAlerts = v);
            },
          ),

          const SizedBox(height: 26),

          // ── Language ──────────────────────────────────────────
          _buildSectionLabel(
            isBangla ? 'ভাষা' : 'LANGUAGE',
          ),
          const SizedBox(height: 10),

          _buildLanguageCard(
            isBangla,
            languageProvider,
          ),

          const SizedBox(height: 26),

          // ── Appearance ────────────────────────────────────────
          _buildSectionLabel(
            isBangla ? 'চেহারা' : 'APPEARANCE',
          ),
          const SizedBox(height: 10),

          _buildNavigationCard(
            icon: Icons.text_fields_rounded,
            title: isBangla ? 'ফন্ট সাইজ' : 'Font Size',
            subtitle: isBangla
                ? 'টেক্সটের আকার পরিবর্তন করুন'
                : 'Adjust text size',
            onTap: () => _showFontSizeDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 26),

          // ── Privacy & Security ────────────────────────────────
          _buildSectionLabel(
            isBangla
                ? 'গোপনীয়তা ও নিরাপত্তা'
                : 'PRIVACY & SECURITY',
          ),
          const SizedBox(height: 10),

          _buildToggleCard(
            icon: Icons.location_on_rounded,
            title: isBangla ? 'লোকেশন অ্যাক্সেস' : 'Location Access',
            subtitle: isBangla
                ? 'অ্যাপকে আপনার অবস্থান ব্যবহার করতে দিন'
                : 'Allow app to use your location',
            value: _locationAccess,
            onChanged: (v) {
              setState(() => _locationAccess = v);
            },
          ),

          const SizedBox(height: 26),

          // ── Data & Storage ────────────────────────────────────
          _buildSectionLabel(
            isBangla ? 'ডেটা ও স্টোরেজ' : 'DATA & STORAGE',
          ),
          const SizedBox(height: 10),

          _buildToggleCard(
            icon: Icons.analytics_rounded,
            title: isBangla ? 'বিশ্লেষণ' : 'Analytics',
            subtitle: isBangla
                ? 'অ্যাপ উন্নয়নে সাহায্য করুন'
                : 'Help improve the app',
            value: _analyticsEnabled,
            onChanged: (v) {
              setState(() => _analyticsEnabled = v);
            },
          ),

          const SizedBox(height: 14),

          _buildNavigationCard(
            icon: Icons.cleaning_services_rounded,
            title: isBangla ? 'ক্যাশ পরিষ্কার' : 'Clear Cache',
            subtitle: isBangla
                ? 'অস্থায়ী ফাইল মুছুন'
                : 'Delete temporary files',
            onTap: () => _showClearCacheDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 14),

          _buildNavigationCard(
            icon: Icons.download_rounded,
            title: isBangla ? 'ডেটা এক্সপোর্ট' : 'Export Data',
            subtitle: isBangla
                ? 'আপনার স্বাস্থ্য ডেটা ডাউনলোড করুন'
                : 'Download your health data',
            onTap: () => _showComingSoon(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 26),

          // ── Help & Support ────────────────────────────────────
          _buildSectionLabel(
            isBangla ? 'সাহায্য ও সহায়তা' : 'HELP & SUPPORT',
          ),
          const SizedBox(height: 10),

          _buildNavigationCard(
            icon: Icons.help_outline_rounded,
            title: isBangla ? 'সচরাচর জিজ্ঞাসা' : 'FAQ',
            subtitle: isBangla
                ? 'সাধারণ প্রশ্নের উত্তর'
                : 'Answers to common questions',
            onTap: () => _showFAQDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 14),

          _buildNavigationCard(
            icon: Icons.support_agent_rounded,
            title: isBangla ? 'যোগাযোগ করুন' : 'Contact Us',
            subtitle: isBangla
                ? 'আমাদের সাপোর্ট টিমের সাথে কথা বলুন'
                : 'Reach out to our support team',
            onTap: () => _showContactUsDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 14),

          _buildNavigationCard(
            icon: Icons.bug_report_rounded,
            title: isBangla ? 'সমস্যা রিপোর্ট' : 'Report a Problem',
            subtitle: isBangla
                ? 'বাগ বা সমস্যা জানান'
                : 'Let us know about bugs or issues',
            onTap: () => _showComingSoon(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 26),

          // ── About ─────────────────────────────────────────────
          _buildSectionLabel(
            isBangla ? 'সম্পর্কে' : 'ABOUT',
          ),
          const SizedBox(height: 10),

          _buildNavigationCard(
            icon: Icons.info_outline_rounded,
            title: isBangla ? 'অ্যাপ সম্পর্কে' : 'About Cradle',
            subtitle: 'v1.0.0',
            onTap: () => _showAboutDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 14),

          _buildNavigationCard(
            icon: Icons.description_rounded,
            title: isBangla
                ? 'শর্তাবলী'
                : 'Terms & Conditions',
            subtitle: isBangla
                ? 'ব্যবহারের শর্তাবলী পড়ুন'
                : 'Read our terms of use',
            onTap: () => _showTermsDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 14),

          _buildNavigationCard(
            icon: Icons.privacy_tip_rounded,
            title: isBangla
                ? 'গোপনীয়তা নীতি'
                : 'Privacy Policy',
            subtitle: isBangla
                ? 'আমরা কীভাবে আপনার ডেটা ব্যবহার করি'
                : 'How we use your data',
            onTap: () => _showPrivacyPolicyDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 14),

          _buildNavigationCard(
            icon: Icons.star_rate_rounded,
            title: isBangla ? 'অ্যাপ রেট করুন' : 'Rate the App',
            subtitle: isBangla
                ? 'স্টোরে আমাদের রিভিউ দিন'
                : 'Leave us a review on the store',
            onTap: () => _showRatingDialog(
              context,
              isBangla,
            ),
          ),

          const SizedBox(height: 32),

          // ── Account actions ───────────────────────────────────
          _buildLogoutButton(isBangla),

          const SizedBox(height: 16),

          _buildDeleteAccountButton(isBangla),

          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

  // ════════════════════════════════════════════════════════════════════
  //  W I D G E T   B U I L D E R S
  // ════════════════════════════════════════════════════════════════════

  // ── Profile card ────────────────────────────────────────────────────
  Widget _buildProfileCard(String userName, bool isBangla) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.personalInfo);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _secondaryWhite.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.gentiumBookPlus(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _secondaryWhite,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.gentiumBookPlus(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _secondaryWhite,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isBangla
                        ? 'প্রোফাইল দেখুন ও সম্পাদনা করুন'
                        : 'View & edit profile',
                    style: GoogleFonts.gentiumBookPlus(
                      fontSize: 15,
                      color: _secondaryWhite.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _secondaryWhite.withValues(alpha: 0.7),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ───────────────────────────────────────────────────
Widget _buildSectionLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      label,
      style: _sectionTitle(),
    ),
  );
}

// ── Shared white card ──────────────────────────────────────────────
Widget _buildCard({
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: _cardShadow,
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

// ── Toggle card ────────────────────────────────────────────────────
Widget _buildToggleCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return _buildCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _SettingIcon(icon: icon),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _itemTitle(),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: _itemSubtitle(),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: value,
            activeTrackColor: _accent,
            activeThumbColor: Colors.pink.shade100,
            inactiveTrackColor: _accent.withValues(alpha: .3),
            inactiveThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    ),
  );
}

// ── Navigation card ────────────────────────────────────────────────
Widget _buildNavigationCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return _buildCard(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _SettingIcon(icon: icon),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _itemTitle(),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: _itemSubtitle(),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: _accent,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildLanguageCard(
  bool isBangla,
  LanguageProvider languageProvider,
) {
  return _buildCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const _SettingIcon(
            icon: Icons.language_rounded,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBangla ? 'ভাষা নির্বাচন' : 'App Language',
                  style: _itemTitle(),
                ),
                const SizedBox(height: 3),
                Text(
                  isBangla ? 'বর্তমান: বাংলা' : 'Current: English',
                  style: _itemSubtitle(),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: _brandSofter,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => languageProvider.setLanguage(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: !isBangla
                          ? _accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'EN',
                      style: GoogleFonts.gentiumBookPlus(
                        color: !isBangla
                            ? Colors.white
                            : _accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => languageProvider.setLanguage(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isBangla
                          ? _accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'বাং',
                      style: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ).copyWith(
                        color: isBangla
                            ? Colors.white
                            : _accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── Logout button ───────────────────────────────────────────────────
  Widget _buildLogoutButton(bool isBangla) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, isBangla),
        icon: const Icon(Icons.logout_rounded, size: 30),
        label: Text(
          isBangla ? 'লগ আউট' : 'Log Out',
          style: GoogleFonts.gentiumBookPlus(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: _secondaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
          shadowColor: _accent.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  // ── Delete account button ───────────────────────────────────────────
  Widget _buildDeleteAccountButton(bool isBangla) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteAccountDialog(context, isBangla),
        icon: Icon(Icons.delete_forever_rounded,
            size: 30, color: _accent.withValues(alpha: 0.7)),
        label: Text(
          isBangla ? 'অ্যাকাউন্ট মুছে ফেলুন' : 'Delete Account',
          style: GoogleFonts.gentiumBookPlus(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _accent.withValues(alpha: 0.7),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: _brandSofter,
          side: BorderSide(color: _accent.withValues(alpha: 0.25), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  D I A L O G S
  // ════════════════════════════════════════════════════════════════════

  void _showComingSoon(BuildContext ctx, bool isBangla) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          isBangla ? 'শীঘ্রই আসছে!' : 'Coming soon!',
          style: GoogleFonts.gentiumBookPlus(color: _secondaryWhite),
        ),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext ctx, bool isBangla) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isBangla ? 'ক্যাশ পরিষ্কার?' : 'Clear Cache?',
          style: GoogleFonts.gentiumBookPlus(
            fontWeight: FontWeight.bold,
            color: _accent,
          ),
        ),
        content: Text(
          isBangla
              ? 'এটি অস্থায়ী ডেটা মুছে ফেলবে। আপনার ব্যক্তিগত ডেটা প্রভাবিত হবে না।'
              : 'This will remove temporary data. Your personal data will not be affected.',
          style: GoogleFonts.gentiumBookPlus(color: _accent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isBangla ? 'বাতিল' : 'Cancel',
              style: GoogleFonts.gentiumBookPlus(color: _accent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showComingSoon(ctx, isBangla);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _secondaryWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isBangla ? 'পরিষ্কার করুন' : 'Clear',
              style: GoogleFonts.gentiumBookPlus(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext ctx, bool isBangla) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isBangla ? 'লগ আউট?' : 'Log Out?',
          style: GoogleFonts.gentiumBookPlus(
            fontWeight: FontWeight.bold,
            color: _accent,
          ),
        ),
        content: Text(
          isBangla
              ? 'আপনি কি নিশ্চিত আপনি লগ আউট করতে চান?'
              : 'Are you sure you want to log out?',
          style: GoogleFonts.gentiumBookPlus(color: _accent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isBangla ? 'বাতিল' : 'Cancel',
              style: GoogleFonts.gentiumBookPlus(color: _accent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _secondaryWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isBangla ? 'লগ আউট' : 'Log Out',
              style: GoogleFonts.gentiumBookPlus(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext ctx, bool isBangla) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: _accent, size: 26),
            const SizedBox(width: 8),
            Text(
              isBangla ? 'অ্যাকাউন্ট মুছুন?' : 'Delete Account?',
              style: GoogleFonts.gentiumBookPlus(
                fontWeight: FontWeight.bold,
                color: _accent,
              ),
            ),
          ],
        ),
        content: Text(
          isBangla
              ? 'এই ক্রিয়াটি অপরিবর্তনীয়। আপনার সমস্ত ডেটা স্থায়ীভাবে মুছে ফেলা হবে।'
              : 'This action is irreversible. All your data will be permanently deleted.',
          style: GoogleFonts.gentiumBookPlus(color: _accent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isBangla ? 'বাতিল' : 'Cancel',
              style: GoogleFonts.gentiumBookPlus(color: _accent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showComingSoon(ctx, isBangla);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _secondaryWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isBangla ? 'মুছে ফেলুন' : 'Delete',
              style: GoogleFonts.gentiumBookPlus(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isBangla) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_brandSoft, Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Cradle',
                        style: GoogleFonts.gentiumBookPlus(
                          fontWeight: FontWeight.bold,
                          color: _accent,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isBangla ? 'সংস্করণ: 1.0.0' : 'Version: 1.0.0',
                      style: GoogleFonts.gentiumBookPlus(
                        color: _accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isBangla
                          ? 'Cradle হলো একটি মাতৃস্বাস্থ্য সহায়ক অ্যাপ যা গর্ভবতী মায়েদের স্বাস্থ্য পর্যবেক্ষণ, ঝুঁকি মূল্যায়ন এবং শিক্ষামূলক সামগ্রী প্রদান করে।'
                          : 'Cradle is a maternal health companion app that provides health monitoring, risk assessment, and educational content for expecting mothers.',
                      style: GoogleFonts.gentiumBookPlus(
                        color: _accent.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isBangla ? '© ২০২৬ Cradle Team' : '© 2026 Cradle Team',
                      style: GoogleFonts.gentiumBookPlus(
                        color: _accent.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, bool isBangla) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, _) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_brandSoft, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1.5),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          isBangla ? 'ফন্ট সাইজ' : 'Font Size',
                          style: GoogleFonts.gentiumBookPlus(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isBangla ? 'টেক্সট আকার নমুনা' : 'Sample Text Size',
                          style: GoogleFonts.gentiumBookPlus(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBangla
                              ? 'এই স্লাইডারটি পরিবর্তন করে অ্যাপের লেখার আকার নিয়ন্ত্রণ করুন।'
                              : 'Change this slider to adjust the text size of the app.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.gentiumBookPlus(
                            fontSize: 13,
                            color: _accent.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _accent,
                            inactiveTrackColor: _accent.withValues(alpha: 0.15),
                            thumbColor: _accent,
                            overlayColor: _accent.withValues(alpha: 0.12),
                            valueIndicatorColor: _accent,
                            valueIndicatorTextStyle: GoogleFonts.gentiumBookPlus(color: _secondaryWhite),
                          ),
                          child: Slider(
                            value: fontSizeProvider.scaleFactor,
                            min: 0.8,
                            max: 1.6,
                            divisions: 8,
                            label: fontSizeProvider.scaleFactor.toStringAsFixed(1),
                            onChanged: (val) {
                              fontSizeProvider.setScaleFactor(val);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: _accent,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFAQDialog(BuildContext context, bool isBangla) {
    final List<Map<String, String>> faqList = isBangla
        ? [
            {
              'q': 'ক্র্যাডল কি?',
              'a': 'ক্র্যাডল হলো একটি মাতৃত্বকালীন স্বাস্থ্য সহায়ক অ্যাপ যা গর্ভবতী মায়েদের স্বাস্থ্য পর্যবেক্ষণ, ঝুঁকি মূল্যায়ন এবং শিক্ষামূলক সামগ্রী প্রদান করে।'
            },
            {
              'q': 'এআই ঝুঁকি মূল্যায়ন কীভাবে কাজ করে?',
              'a': 'এটি আপনার প্রদান করা লক্ষণ ও স্বাস্থ্য প্যারামিটার বিশ্লেষণ করে সম্ভাব্য ঝুঁকি সনাক্ত করে এবং চিকিৎসকের পরামর্শ নেওয়ার পরামর্শ দেয়।'
            },
            {
              'q': 'আমার স্বাস্থ্য ডেটা কি নিরাপদ?',
              'a': 'হ্যাঁ, আপনার ডেটা সম্পূর্ণ নিরাপদ এবং এটি শুধুমাত্র আপনার স্বাস্থ্য মূল্যায়নের জন্য ব্যবহৃত হয়।'
            },
            {
              'q': 'আমি কি আমার ডেটা এক্সপোর্ট করতে পারি?',
              'a': 'হ্যাঁ, আপনার চিকিৎসকের সাথে শেয়ার করার জন্য ডেটা ও স্টোরেজ সেটিং থেকে আপনার তথ্য ডাউনলোড করতে পারেন।'
            },
          ]
        : [
            {
              'q': 'What is Cradle?',
              'a': 'Cradle is a maternal health companion app designed to support expecting mothers by providing health monitoring, risk assessment, and educational content.'
            },
            {
              'q': 'How does the AI risk assessment work?',
              'a': 'It analyzes the maternal health parameters and symptoms you input to identify potential risk factors and suggests when to consult a healthcare provider.'
            },
            {
              'q': 'Is my health data secure?',
              'a': 'Yes, your health data is private, secure, and only used locally to calculate assessments and track your health metrics.'
            },
            {
              'q': 'Can I export my data?',
              'a': 'Yes, you can export your health history from the Data & Storage settings to share with your doctor.'
            },
          ];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_brandSoft, Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      isBangla ? 'সচরাচর জিজ্ঞাসা' : 'FAQ',
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: faqList.map((faq) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    faq['q']!,
                                    style: GoogleFonts.gentiumBookPlus(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _accent,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    faq['a']!,
                                    style: GoogleFonts.gentiumBookPlus(
                                      fontSize: 13.5,
                                      color: _accent.withValues(alpha: 0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactUsDialog(BuildContext context, bool isBangla) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_brandSoft, Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      isBangla ? 'যোগাযোগ করুন' : 'Contact Us',
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.email_rounded, color: _accent, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBangla ? 'ইমেইল' : 'Email',
                                style: GoogleFonts.gentiumBookPlus(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _accent.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'cradle.bd@gmail.com',
                                style: GoogleFonts.gentiumBookPlus(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_rounded, color: _accent, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBangla ? 'ফোন' : 'Phone',
                                style: GoogleFonts.gentiumBookPlus(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _accent.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+880 1234 567890',
                                style: GoogleFonts.gentiumBookPlus(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context, bool isBangla) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_brandSoft, Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      isBangla ? 'শর্তাবলী' : 'Terms & Conditions',
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          isBangla
                              ? '১. সম্মতি: ক্র্যাডল অ্যাপটি ব্যবহার করে আপনি আমাদের শর্তাবলীতে সম্মত হচ্ছেন।\n\n'
                                  '২. কোনো চিকিৎসা পরামর্শ নয়: এই অ্যাপের তথ্য শুধুমাত্র শিক্ষামূলক এবং সাধারণ সহায়তার জন্য। এটি পেশাদার ডাক্তারের পরামর্শ, রোগ নির্ণয় বা চিকিৎসার বিকল্প নয়।\n\n'
                                  '৩. দায়বদ্ধতা সীমাবদ্ধতা: অ্যাপের তথ্যের উপর ভিত্তি করে নেওয়া কোনো সিদ্ধান্তের জন্য ক্র্যাডল টিম দায়ী থাকবে না। যেকোনো জটিলতায় চিকিৎসকের পরামর্শ নিন।\n\n'
                                  '৪. শর্তাবলীর পরিবর্তন: আমরা যেকোনো সময় এই শর্তাবলী আপডেট করার অধিকার রাখি।'
                              : '1. Acceptance: By using the Cradle app, you agree to these Terms & Conditions.\n\n'
                                  '2. No Medical Advice: The content provided in this app is for educational and general support purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment.\n\n'
                                  '3. Limitation of Liability: Under no circumstances shall the Cradle team be liable for any decisions made based on the info provided inside the app. Always consult with a doctor for health concerns.\n\n'
                                  '4. Changes to Terms: We reserve the right to update these terms at any time.',
                          style: GoogleFonts.gentiumBookPlus(
                            fontSize: 14,
                            color: _accent.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isBangla) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_brandSoft, Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      isBangla ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          isBangla
                              ? '১. তথ্য সংগ্রহ: আমরা আপনার প্রোফাইলের নাম এবং প্রসূতি স্বাস্থ্য সংক্রান্ত ডাটা সংরক্ষণ করি।\n\n'
                                  '২. স্থানীয় প্রসেসিং: আপনার প্রদেয় সকল স্বাস্থ্য ডেটা আপনার ডিভাইসেই স্থানীয়ভাবে সংরক্ষণ ও বিশ্লেষণ করা হয় এবং বাইরের কোনো সার্ভারে অননুমোদিতভাবে শেয়ার করা হয় না।\n\n'
                                  '৩. নিরাপত্তা: আমরা আপনার ডেটার সর্বোচ্চ গোপনীয়তা রক্ষা করতে প্রতিশ্রুতিবদ্ধ।\n\n'
                                  '৪. আপনার নিয়ন্ত্রণ: আপনি যখনই চান সেটিং থেকে ক্যাশ পরিষ্কার অথবা অ্যাকাউন্ট মুছে ফেলে আপনার সকল ডেটা চিরতরে মুছে ফেলতে পারেন।'
                              : '1. Data Collection: We store your profile name and obstetric health parameters.\n\n'
                                  '2. Local Processing: All your health data is stored and analyzed locally on your device and is not shared with external servers without authorization.\n\n'
                                  '3. Security: We are committed to protecting the confidentiality of your personal information.\n\n'
                                  '4. Control: You can clear your cache or delete your account at any time through settings to permanently erase your data.',
                          style: GoogleFonts.gentiumBookPlus(
                            fontSize: 14,
                            color: _accent.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, bool isBangla) {
    int selectedStars = 5;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_brandSoft, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1.5),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          isBangla ? 'অ্যাপ রেট করুন' : 'Rate the App',
                          style: GoogleFonts.gentiumBookPlus(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          isBangla
                              ? 'ক্র্যাডল অ্যাপ সম্পর্কে আপনার মতামত আমাদের জানান!'
                              : 'How do you like Cradle? Give us your rating!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.gentiumBookPlus(
                            fontSize: 14.5,
                            color: _accent.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final currentStarValue = index + 1;
                            return IconButton(
                              icon: Icon(
                                currentStarValue <= selectedStars
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: currentStarValue <= selectedStars
                                    ? Colors.amber[700]
                                    : _accent.withValues(alpha: 0.35),
                                size: 38,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  selectedStars = currentStarValue;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isBangla ? 'মতামত দেওয়ার জন্য ধন্যবাদ!' : 'Thank you for your rating!',
                                    style: GoogleFonts.gentiumBookPlus(color: _secondaryWhite),
                                  ),
                                  backgroundColor: _accent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _secondaryWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              isBangla ? 'জমা দিন' : 'Submit',
                              style: GoogleFonts.gentiumBookPlus(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: _accent,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Settings icon ──────────────────────────────────────────────────
class _SettingIcon extends StatelessWidget {
  const _SettingIcon({
    required this.icon,
  });
  static const Color _accent = Color(0xFFAB0A65);
  static const Color _brandSofter = Color(0xFFFCEEF5);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _brandSofter,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: _accent,
        size: 30,
      ),
    );
  }
}