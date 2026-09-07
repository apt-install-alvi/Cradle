import 'package:cradle_app/core/theme/app_theme.dart';
import 'package:cradle_app/core/widgets/bottom_nav.dart';
import 'package:cradle_app/core/widgets/gradient_scaffold.dart';
import 'package:cradle_app/providers/education_provider.dart';
import 'package:cradle_app/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/faq_accordion.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const Color _accent = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final eduProvider = context.watch<EducationProvider>();

    final bool isBangla = languageProvider.isBangla;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(
        selectedIndex: 1,
      ),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ================================================================
          // HEADER
          // ================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: _accent,
                  ),
                ),

                Expanded(
                  child: Text(
                    isBangla
                        ? 'সাধারণ জিজ্ঞাসা'
                        : 'Frequently Asked Questions',
                    style: AppText.headerTitle.copyWith(
                      fontSize: 23,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================================================================
          // FAQ LIST
          // ================================================================
          Expanded(
            child: eduProvider.filteredFAQs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        isBangla
                            ? "কোন প্রশ্ন পাওয়া যায়নি"
                            : "No questions found",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      120,
                    ),
                    children: [
                      Text(
                        isBangla
                            ? 'গর্ভাবস্থা সম্পর্কে সাধারণ প্রশ্নের উত্তর'
                            : 'Answers to common pregnancy questions',
                        style: GoogleFonts.gentiumBookPlus(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _accent,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...eduProvider.filteredFAQs
                          .asMap()
                          .entries
                          .map(
                            (entry) => FAQAccordion(
                              faq: entry.value,
                              isBangla: isBangla,
                              isExpanded:
                                  eduProvider.expandedFaqIndex ==
                                      entry.key,
                              onToggle: () {
                                eduProvider.toggleFaq(entry.key);
                              },
                            ),
                          ),

                      const SizedBox(height: 20),

                      Text(
                        isBangla
                            ? "এই অ্যাপ্লিকেশনটি শুধুমাত্র শিক্ষামূলক তথ্য প্রদান করে এবং পেশাদার চিকিৎসা পরামর্শের বিকল্প নয়।"
                            : "This application provides educational information only and does not replace professional medical advice.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}