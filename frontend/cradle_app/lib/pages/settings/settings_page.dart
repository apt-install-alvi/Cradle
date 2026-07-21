import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  // ── Colour constants ──────────────────────────────────────────────
  static const Color _topGradient = Color(0xFFFFCAE1);
  static const Color _bottomGradient = Color(0xFFFFE8F2);
  static const Color _accent = Color(0xFFAB0A65);
  static const Color _primaryWhite52 = Color(0x85FFFFFF); // #FFF 52 %
  static const Color _secondaryWhite = Color(0xFFFFFFFF);

  // ── Toggle states ─────────────────────────────────────────────────
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _appointmentReminders = true;
  bool _healthAlerts = true;
  bool _darkMode = false;
  bool _biometricLock = false;
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

  // ── Helpers ───────────────────────────────────────────────────────
  TextStyle _sectionTitle() => GoogleFonts.gentiumBookPlus(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: _accent.withValues(alpha: 0.65),
      );

  TextStyle _itemTitle() => GoogleFonts.gentiumBookPlus(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _accent,
      );

  TextStyle _itemSubtitle() => GoogleFonts.gentiumBookPlus(
        fontSize: 12.5,
        color: _accent.withValues(alpha: 0.55),
      );

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final bool isBangla = languageProvider.isBangla;
    final String userName =
        authProvider.userName.isEmpty ? 'User' : authProvider.userName;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_topGradient, _bottomGradient],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                // ── App bar ──────────────────────────────────────
                _buildAppBar(isBangla),

                // ── Content ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Profile card ─────────────────────────
                        _buildProfileCard(userName, isBangla),
                        const SizedBox(height: 26),

                        // ── Notifications ────────────────────────
                        _buildSectionLabel(
                            isBangla ? 'বিজ্ঞপ্তি' : 'NOTIFICATIONS'),
                        const SizedBox(height: 10),
                        _buildSettingsCard([
                          _toggleTile(
                            icon: Icons.notifications_active_rounded,
                            title: isBangla
                                ? 'পুশ বিজ্ঞপ্তি'
                                : 'Push Notifications',
                            subtitle: isBangla
                                ? 'অ্যাপ বিজ্ঞপ্তি গ্রহণ করুন'
                                : 'Receive app notifications',
                            value: _pushNotifications,
                            onChanged: (v) =>
                                setState(() => _pushNotifications = v),
                          ),
                          _divider(),
                          _toggleTile(
                            icon: Icons.email_rounded,
                            title: isBangla
                                ? 'ইমেইল বিজ্ঞপ্তি'
                                : 'Email Notifications',
                            subtitle: isBangla
                                ? 'ইমেইল আপডেট পান'
                                : 'Get updates via email',
                            value: _emailNotifications,
                            onChanged: (v) =>
                                setState(() => _emailNotifications = v),
                          ),
                          _divider(),
                          _toggleTile(
                            icon: Icons.calendar_month_rounded,
                            title: isBangla
                                ? 'অ্যাপয়েন্টমেন্ট রিমাইন্ডার'
                                : 'Appointment Reminders',
                            subtitle: isBangla
                                ? 'আসন্ন অ্যাপয়েন্টমেন্টের জন্য সতর্কতা'
                                : 'Alerts for upcoming appointments',
                            value: _appointmentReminders,
                            onChanged: (v) =>
                                setState(() => _appointmentReminders = v),
                          ),
                          _divider(),
                          _toggleTile(
                            icon: Icons.health_and_safety_rounded,
                            title:
                                isBangla ? 'স্বাস্থ্য সতর্কতা' : 'Health Alerts',
                            subtitle: isBangla
                                ? 'গুরুত্বপূর্ণ স্বাস্থ্য বিজ্ঞপ্তি'
                                : 'Important health notifications',
                            value: _healthAlerts,
                            onChanged: (v) =>
                                setState(() => _healthAlerts = v),
                          ),
                        ]),
                        const SizedBox(height: 26),

                        // ── Language ─────────────────────────────
                        _buildSectionLabel(isBangla ? 'ভাষা' : 'LANGUAGE'),
                        const SizedBox(height: 10),
                        _buildSettingsCard([
                          _buildLanguageSelector(isBangla, languageProvider),
                        ]),
                        const SizedBox(height: 26),

                        // ── Appearance ───────────────────────────
                        _buildSectionLabel(
                            isBangla ? 'চেহারা' : 'APPEARANCE'),
                        const SizedBox(height: 10),
                        _buildSettingsCard([
                          _toggleTile(
                            icon: Icons.dark_mode_rounded,
                            title: isBangla ? 'ডার্ক মোড' : 'Dark Mode',
                            subtitle: isBangla
                                ? 'গাঢ় থিম সক্রিয় করুন'
                                : 'Enable dark theme',
                            value: _darkMode,
                            onChanged: (v) => setState(() => _darkMode = v),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.text_fields_rounded,
                            title:
                                isBangla ? 'ফন্ট সাইজ' : 'Font Size',
                            subtitle:
                                isBangla ? 'টেক্সটের আকার পরিবর্তন করুন' : 'Adjust text size',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                        ]),
                        const SizedBox(height: 26),

                        // ── Privacy & Security ───────────────────
                        _buildSectionLabel(
                            isBangla ? 'গোপনীয়তা ও নিরাপত্তা' : 'PRIVACY & SECURITY'),
                        const SizedBox(height: 10),
                        _buildSettingsCard([
                          _toggleTile(
                            icon: Icons.fingerprint_rounded,
                            title: isBangla ? 'বায়োমেট্রিক লক' : 'Biometric Lock',
                            subtitle: isBangla
                                ? 'ফিঙ্গারপ্রিন্ট / ফেস আইডি ব্যবহার করুন'
                                : 'Use fingerprint / Face ID',
                            value: _biometricLock,
                            onChanged: (v) =>
                                setState(() => _biometricLock = v),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.lock_rounded,
                            title: isBangla ? 'পাসওয়ার্ড পরিবর্তন' : 'Change Password',
                            subtitle: isBangla
                                ? 'আপনার পাসওয়ার্ড আপডেট করুন'
                                : 'Update your password',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                          _divider(),
                          _toggleTile(
                            icon: Icons.location_on_rounded,
                            title: isBangla ? 'লোকেশন অ্যাক্সেস' : 'Location Access',
                            subtitle: isBangla
                                ? 'অ্যাপকে আপনার অবস্থান ব্যবহার করতে দিন'
                                : 'Allow app to use your location',
                            value: _locationAccess,
                            onChanged: (v) =>
                                setState(() => _locationAccess = v),
                          ),
                        ]),
                        const SizedBox(height: 26),

                        // ── Data & Storage ───────────────────────
                        _buildSectionLabel(
                            isBangla ? 'ডেটা ও স্টোরেজ' : 'DATA & STORAGE'),
                        const SizedBox(height: 10),
                        _buildSettingsCard([
                          _toggleTile(
                            icon: Icons.analytics_rounded,
                            title: isBangla ? 'বিশ্লেষণ' : 'Analytics',
                            subtitle: isBangla
                                ? 'অ্যাপ উন্নয়নে সাহায্য করুন'
                                : 'Help improve the app',
                            value: _analyticsEnabled,
                            onChanged: (v) =>
                                setState(() => _analyticsEnabled = v),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.cleaning_services_rounded,
                            title: isBangla ? 'ক্যাশ পরিষ্কার' : 'Clear Cache',
                            subtitle: isBangla
                                ? 'অস্থায়ী ফাইল মুছুন'
                                : 'Delete temporary files',
                            onTap: () => _showClearCacheDialog(context, isBangla),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.download_rounded,
                            title: isBangla ? 'ডেটা এক্সপোর্ট' : 'Export Data',
                            subtitle: isBangla
                                ? 'আপনার স্বাস্থ্য ডেটা ডাউনলোড করুন'
                                : 'Download your health data',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                        ]),
                        const SizedBox(height: 26),

                        // ── Help & Support ───────────────────────
                        _buildSectionLabel(
                            isBangla ? 'সাহায্য ও সহায়তা' : 'HELP & SUPPORT'),
                        const SizedBox(height: 10),
                        _buildSettingsCard([
                          _navTile(
                            icon: Icons.help_outline_rounded,
                            title: isBangla ? 'সচরাচর জিজ্ঞাসা' : 'FAQ',
                            subtitle: isBangla
                                ? 'সাধারণ প্রশ্নের উত্তর'
                                : 'Answers to common questions',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.support_agent_rounded,
                            title: isBangla ? 'যোগাযোগ করুন' : 'Contact Us',
                            subtitle: isBangla
                                ? 'আমাদের সাপোর্ট টিমের সাথে কথা বলুন'
                                : 'Reach out to our support team',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.bug_report_rounded,
                            title: isBangla ? 'সমস্যা রিপোর্ট' : 'Report a Problem',
                            subtitle: isBangla
                                ? 'বাগ বা সমস্যা জানান'
                                : 'Let us know about bugs or issues',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                        ]),
                        const SizedBox(height: 26),

                        // ── About ────────────────────────────────
                        _buildSectionLabel(isBangla ? 'সম্পর্কে' : 'ABOUT'),
                        const SizedBox(height: 10),
                        _buildSettingsCard([
                          _navTile(
                            icon: Icons.info_outline_rounded,
                            title: isBangla ? 'অ্যাপ সম্পর্কে' : 'About Cradle',
                            subtitle: 'v1.0.0',
                            onTap: () => _showAboutDialog(context, isBangla),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.description_rounded,
                            title: isBangla
                                ? 'শর্তাবলী'
                                : 'Terms & Conditions',
                            subtitle: isBangla
                                ? 'ব্যবহারের শর্তাবলী পড়ুন'
                                : 'Read our terms of use',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.privacy_tip_rounded,
                            title: isBangla
                                ? 'গোপনীয়তা নীতি'
                                : 'Privacy Policy',
                            subtitle: isBangla
                                ? 'আমরা কীভাবে আপনার ডেটা ব্যবহার করি'
                                : 'How we use your data',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                          _divider(),
                          _navTile(
                            icon: Icons.star_rate_rounded,
                            title: isBangla ? 'অ্যাপ রেট করুন' : 'Rate the App',
                            subtitle: isBangla
                                ? 'স্টোরে আমাদের রিভিউ দিন'
                                : 'Leave us a review on the store',
                            onTap: () => _showComingSoon(context, isBangla),
                          ),
                        ]),
                        const SizedBox(height: 32),

                        // ── Logout button ────────────────────────
                        _buildLogoutButton(isBangla),

                        const SizedBox(height: 16),

                        // ── Delete account ───────────────────────
                        _buildDeleteAccountButton(isBangla),

                        const SizedBox(height: 24),
                      ],
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

  // ════════════════════════════════════════════════════════════════════
  //  W I D G E T   B U I L D E R S
  // ════════════════════════════════════════════════════════════════════

  // ── App bar ─────────────────────────────────────────────────────────
  Widget _buildAppBar(bool isBangla) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryWhite52,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _accent,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            isBangla ? 'সেটিংস' : 'Settings',
            style: GoogleFonts.gentiumBookPlus(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _accent,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

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
              offset: const Offset(0, 8),
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
                      fontSize: 13,
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
      child: Text(label, style: _sectionTitle()),
    );
  }

  // ── Settings card container ─────────────────────────────────────────
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryWhite52,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accent.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ── Toggle tile ─────────────────────────────────────────────────────
  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _accent, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _itemTitle()),
                const SizedBox(height: 2),
                Text(subtitle, style: _itemSubtitle()),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _accent,
            activeTrackColor: _accent.withValues(alpha: 0.3),
            inactiveThumbColor: _accent.withValues(alpha: 0.35),
            inactiveTrackColor: _accent.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  // ── Navigation tile (arrow >) ───────────────────────────────────────
  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _accent, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _itemTitle()),
                    const SizedBox(height: 2),
                    Text(subtitle, style: _itemSubtitle()),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _accent.withValues(alpha: 0.35),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Divider ─────────────────────────────────────────────────────────
  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: _accent.withValues(alpha: 0.08),
      ),
    );
  }

  // ── Language selector ───────────────────────────────────────────────
  Widget _buildLanguageSelector(
      bool isBangla, LanguageProvider languageProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.language_rounded, color: _accent, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBangla ? 'ভাষা নির্বাচন' : 'App Language',
                  style: _itemTitle(),
                ),
                const SizedBox(height: 2),
                Text(
                  isBangla
                      ? 'বর্তমান: বাংলা'
                      : 'Current: English',
                  style: _itemSubtitle(),
                ),
              ],
            ),
          ),
          // Language toggle
          Container(
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: !isBangla ? _accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'EN',
                      style: GoogleFonts.gentiumBookPlus(
                        color: !isBangla ? _secondaryWhite : _accent,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isBangla ? _accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'বাং',
                      style: TextStyle(
                        color: isBangla ? _secondaryWhite : _accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout button ───────────────────────────────────────────────────
  Widget _buildLogoutButton(bool isBangla) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, isBangla),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          isBangla ? 'লগ আউট' : 'Log Out',
          style: GoogleFonts.gentiumBookPlus(
            fontSize: 16,
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
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteAccountDialog(context, isBangla),
        icon: Icon(Icons.delete_forever_rounded,
            size: 20, color: _accent.withValues(alpha: 0.7)),
        label: Text(
          isBangla ? 'অ্যাকাউন্ট মুছে ফেলুন' : 'Delete Account',
          style: GoogleFonts.gentiumBookPlus(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _accent.withValues(alpha: 0.7),
          ),
        ),
        style: OutlinedButton.styleFrom(
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
        backgroundColor: _bottomGradient,
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
        backgroundColor: _bottomGradient,
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
        backgroundColor: _bottomGradient,
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

  void _showAboutDialog(BuildContext ctx, bool isBangla) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _bottomGradient,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cradle',
          style: GoogleFonts.gentiumBookPlus(
            fontWeight: FontWeight.bold,
            color: _accent,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBangla
                  ? 'সংস্করণ: 1.0.0'
                  : 'Version: 1.0.0',
              style: GoogleFonts.gentiumBookPlus(
                color: _accent,
                fontSize: 14,
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
            const SizedBox(height: 16),
            Text(
              isBangla
                  ? '© ২০২৬ Cradle Team'
                  : '© 2026 Cradle Team',
              style: GoogleFonts.gentiumBookPlus(
                color: _accent.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _secondaryWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isBangla ? 'ঠিক আছে' : 'OK',
              style: GoogleFonts.gentiumBookPlus(),
            ),
          ),
        ],
      ),
    );
  }
}
