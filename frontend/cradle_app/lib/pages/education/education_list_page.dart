import 'package:cradle_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../providers/education_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/routes/app_routes.dart';

import 'widgets/article_card.dart';
import 'article_detail_page.dart';

class EducationListPage extends StatefulWidget {
  const EducationListPage({super.key});

  @override
  State<EducationListPage> createState() => _EducationListPageState();
}

class _EducationListPageState extends State<EducationListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _showBackToTop = false;

  static const Color _accent = Color(0xFFAB0A65);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _showBackToTop = _scrollController.offset > 400;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _searchController.text =
          context.read<EducationProvider>().searchQuery;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final eduProvider = context.watch<EducationProvider>();

    final bool isBangla = languageProvider.isBangla;

    final List<String> categories = [
      'All',
      'Trimester',
      'Nutrition',
      'Exercise',
      'Baby',
      'Maternal',
      'Mental Health',
      'Emergency',
      'Medication',
      'Checkups',
    ];

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(selectedIndex: 1),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),

              // ============================================================
              // HEADER
              // ============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        isBangla
                            ? "শিক্ষামূলক গাইড"
                            : "Education Guides",
                        style: AppText.headerTitle.copyWith(
                          fontSize: 24,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // FAQ pill/button
                    _buildFaqButton(context),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
              // SEARCH BAR
              // ============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    eduProvider.setSearchQuery(val);

                    // Rebuild so the clear button appears/disappears.
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: isBangla
                        ? "আর্টিকেল বা সাধারণ জিজ্ঞাসা খুঁজুন..."
                        : "Search articles or FAQs...",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: _accent,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: _accent,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              eduProvider.setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
              // CATEGORY CHIPS
              // ============================================================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected =
                        eduProvider.selectedCategory == cat;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          _getCategoryName(cat, isBangla),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : _accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        onSelected: (val) {
                          eduProvider.setCategory(cat);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: _accent,
                        disabledColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        side: BorderSide.none,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                        elevation: 0,
                        pressElevation: 0,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
              // CONTENT
              // ============================================================
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    200,
                  ),
                  children: [
                    // ========================================================
                    // SAVED ARTICLES
                    // ========================================================
                    if (eduProvider.bookmarkedArticles.isNotEmpty &&
                        eduProvider.selectedCategory == 'All') ...[
                      _buildSectionHeader(
                        isBangla
                            ? "⭐ সংরক্ষিত আর্টিকেল"
                            : "⭐ Saved Articles",
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              eduProvider.bookmarkedArticles.length,
                          itemBuilder: (context, index) {
                            final article =
                                eduProvider.bookmarkedArticles[index];

                            return Container(
                              width: 300,
                              margin: const EdgeInsets.only(right: 16),
                              child: ArticleCard(
                                article: article,
                                isBangla: isBangla,
                                isBookmarked: true,
                                progress:
                                    eduProvider.getProgress(article.id),
                                onBookmarkToggle: () {
                                  eduProvider.toggleBookmark(article.id);
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ArticleDetailPage(
                                        article: article,
                                        isBangla: isBangla,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // ========================================================
                    // PREGNANCY EDUCATION
                    // ========================================================
                    _buildSectionHeader(
                      isBangla
                          ? "📚 গর্ভাবস্থা শিক্ষা"
                          : "📚 Pregnancy Education",
                    ),

                    const SizedBox(height: 12),

                    if (eduProvider.filteredArticles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            isBangla
                                ? "কোন আর্টিকেল পাওয়া যায়নি"
                                : "No articles found",
                          ),
                        ),
                      )
                    else
                      ...eduProvider.filteredArticles.map(
                        (article) => ArticleCard(
                          article: article,
                          isBangla: isBangla,
                          isBookmarked:
                              eduProvider.isBookmarked(article.id),
                          progress:
                              eduProvider.getProgress(article.id),
                          onBookmarkToggle: () {
                            eduProvider.toggleBookmark(article.id);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailPage(
                                  article: article,
                                  isBangla: isBangla,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ========================================================
                    // DISCLAIMER
                    // ========================================================
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

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),

          // ================================================================
          // BACK TO TOP
          // ================================================================
          if (_showBackToTop)
            Positioned(
              right: 16,
              bottom: 140,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: _accent,
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // FAQ BUTTON
  // =========================================================================
  Widget _buildFaqButton(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.faq,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/faq.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 3),

              const Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SECTION HEADER
  // =========================================================================
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.gentiumBookPlus(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _accent,
      ),
    );
  }

  // =========================================================================
  // CATEGORY NAME
  // =========================================================================
  String _getCategoryName(String cat, bool isBangla) {
    if (!isBangla) return cat;

    switch (cat) {
      case 'All':
        return 'সব';
      case 'Trimester':
        return 'ত্রৈমাসিক';
      case 'Nutrition':
        return 'পুষ্টি';
      case 'Exercise':
        return 'ব্যায়াম';
      case 'Baby':
        return 'শিশু';
      case 'Maternal':
        return 'মা';
      case 'Mental Health':
        return 'মানসিক স্বাস্থ্য';
      case 'Emergency':
        return 'জরুরি';
      case 'Medication':
        return 'ওষুধ';
      case 'Checkups':
        return 'চেকআপ';
      default:
        return cat;
    }
  }
}