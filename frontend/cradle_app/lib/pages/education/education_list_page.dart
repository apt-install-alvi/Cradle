import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';


class EducationListPage extends StatelessWidget {
  const EducationListPage({super.key});

  // ── Colour constants (Theme matching) ──────────────────────────────
  static const Color _topGradient = Color(0xFFFFCAE1);
  static const Color _bottomGradient = Color(0xFFFFE8F2);
  static const Color _accent = Color(0xFFAB0A65);
  static const Color _primaryWhite52 = Color(0x85FFFFFF); // #FFF 52%

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const DashboardBottomNav(selectedIndex: 2),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_topGradient, _bottomGradient],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── App Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
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
                              border: Border.all(color: _accent.withValues(alpha: 0.08)),
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
                        isBangla ? "শিক্ষামূলক গাইড" : "Education Guides",
                        style: GoogleFonts.gentiumBookPlus(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Tab Bar ──────────────────────────────────────────
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: _accent,
                  unselectedLabelColor: _accent.withValues(alpha: 0.55),
                  indicatorColor: _accent,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.gentiumBookPlus(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: isBangla ? "মায়ের স্বাস্থ্য" : "Mother’s Health"),
                    Tab(text: isBangla ? "শিশুর স্বাস্থ্য" : "Baby’s Health"),
                    Tab(text: isBangla ? "সচেতনতা ও গাইডেন্স" : "Awareness & Guidance"),
                    Tab(text: isBangla ? "প্রতিরোধ ও নিরাপত্তা" : "Prevention & Safety"),
                  ],
                ),

                // ── Tab Views ────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    children: [
                      ArticleFeed(category: "maternal", isBangla: isBangla),
                      ArticleFeed(category: "baby", isBangla: isBangla),
                      ArticleFeed(category: "awareness", isBangla: isBangla),
                      ArticleFeed(category: "prevention", isBangla: isBangla),
                    ],
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

//--------------------------------------------------
// ARTICLE FEED WIDGET
//--------------------------------------------------
class ArticleFeed extends StatelessWidget {
  final String category;
  final bool isBangla;

  const ArticleFeed({
    super.key,
    required this.category,
    required this.isBangla,
  });

  // ── Theme Colours ──────────────────────────────────────────────────
  static const Color _accent = Color(0xFFAB0A65);
  static const Color _primaryWhite52 = Color(0x85FFFFFF);
  static const Color _secondaryWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    // Localized sample articles list
    final List<Map<String, dynamic>> articles = _getArticles();

    if (articles.isEmpty) {
      return Center(
        child: Text(
          isBangla ? "কোন আর্টিকেল পাওয়া যায়নি" : "No articles found",
          style: GoogleFonts.gentiumBookPlus(
            color: _accent.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: _primaryWhite52,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _accent.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Image (Added)
                if (article["images"] != null && (article["images"] as List).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16), // Fixed line
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        article["images"][0],
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.broken_image_rounded, color: _accent, size: 40),
                          );
                        },
                      ),
                    ),
                  ),

                // Source label
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article["source"]!,
                        style: GoogleFonts.gentiumBookPlus(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article["date"]!,
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 12,
                        color: _accent.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  article["title"]!,
                  style: GoogleFonts.gentiumBookPlus(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _accent,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Summary
                Text(
                  article["summary"]!,
                  style: GoogleFonts.gentiumBookPlus(
                    fontSize: 14,
                    color: _accent.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Action Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _showArticleDetails(context, article);
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 16, color: _accent),
                    label: Text(
                      isBangla ? "আরও পড়ুন" : "Read More",
                      style: GoogleFonts.gentiumBookPlus(
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      backgroundColor: _accent.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  void _showComingSoon(BuildContext ctx) {
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

  void _showArticleDetails(BuildContext context, Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar and Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.cancel_rounded, color: _accent, size: 28),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article["images"] != null)
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: (article["images"] as List).length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                article["images"][index],
                                width: 320,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 320,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: _accent.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.broken_image_rounded,
                                      color: _accent,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      article["title"]!,
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          article["source"]!,
                          style: GoogleFonts.gentiumBookPlus(
                            fontWeight: FontWeight.bold,
                            color: _accent.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "• ${article["date"]!}",
                          style: GoogleFonts.gentiumBookPlus(
                            color: _accent.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    Text(
                      article["details"] ?? article["summary"]!,
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getArticles() {
    if (category == "maternal") {
      return [
        {
          "title": isBangla ? "গর্ভাবস্থায় স্বাস্থ্যকর পুষ্টি" : "Healthy Nutrition During Pregnancy",
          "summary": isBangla
              ? "গর্ভাবস্থায় নিরাপদ থাকার জন্য কোন খাবারগুলো খাবেন এবং বর্জন করবেন তা বিস্তারিতভাবে জানুন।"
              : "Learn what foods to eat and avoid for a safe and healthy pregnancy journey.",
          "source": isBangla ? "ডাব্লিউএইচও (WHO)" : "WHO",
          "date": isBangla ? "জুলাই ২০২৬" : "July 2026",
          "url": "https://www.who.int/maternal-health",
          "images": ["assets/images/pf2.jpg"],
          "details": isBangla
              ? "গর্ভাবস্থায় স্বাস্থ্যকর খাবার খাওয়া আপনার শিশুর বৃদ্ধি এবং বিকাশে সহায়তা করার জন্য অত্যন্ত গুরুত্বপূর্ণ। আপনাকে বিভিন্ন ধরণের পুষ্টিকর খাবার খেতে হবে, যেমন ফলমূল, শাকসবজি, প্রোটিন সমৃদ্ধ খাবার (যেমন মাছ, মাংস, ডিম, মটরশুঁটি) এবং দুগ্ধজাত পণ্য। প্রচুর পরিমাণে পানি পান করুন এবং চিনিযুক্ত পানীয় বা অতিরিক্ত ক্যাফেইন বর্জন করুন। সুস্থ থাকতে নিয়মিত সুষম খাবার গ্রহণ করুন।"
              : "Eating healthy food during pregnancy is crucial to help your baby grow and develop. You should eat a variety of nutritious foods, including fruits, vegetables, protein-rich foods (such as fish, meat, eggs, beans), and dairy products. Drink plenty of water and avoid sugary drinks or excessive caffeine. Maintaining a balanced diet is key to a healthy pregnancy."
        },
        {
          "title": isBangla ? "গর্ভাবস্থায় ব্যায়াম এবং হাঁটাচলা" : "Prenatal Exercise & Physical Activities",
          "summary": isBangla
              ? "একজন গর্ভবতী মায়ের জন্য প্রতিদিন কতটুকু শারীরিক কসরত প্রয়োজন এবং তার সঠিক নিয়মগুলো।"
              : "Best practices and guidelines for light exercises to stay active during pregnancy safely.",
          "source": isBangla ? " ইউনিসেফ" : "UNICEF",
          "date": isBangla ? "জুন ২০২৬" : "June 2026",
          "images": ["assets/images/pf3.jpg"],
          "url": "https://www.unicef.org"
        }
      ];
    } else if (category == "baby") {
      return [
        {
          "title": isBangla ? "নবজাতকের জন্ডিস সচেতনতা" : "Baby Jaundice Awareness",
          "summary": isBangla
              ? "নবজাতকের জন্ডিসের সাধারণ লক্ষণগুলো বুঝুন এবং কখন চিকিৎসকের পরামর্শ নেবেন তা জানুন।"
              : "Understand common symptoms of infant jaundice and when you should seek professional medical care.",
          "source": isBangla ? "ইউনিসেফ" : "UNICEF",
          "date": isBangla ? "জুলাই ২০২৬" : "July 2026",
          "images": ["assets/images/pf2.jpg"],
          "url": "https://www.unicef.org/baby-health"
        },
        {
          "title": isBangla ? "প্রথম ৬ মাস স্তন্যপান করানোর নিয়ম" : "Guidelines for Breastfeeding First 6 Months",
          "summary": isBangla
              ? "শিশুর প্রথম ৬ মাস শুধুমাত্র মায়ের দুধ খাওয়ানোর গুরুত্ব এবং শিশুর বিকাশে এর অপরিসীম অবদান।"
              : "The absolute importance of exclusive breastfeeding during the first six months of your baby's life.",
          "source": isBangla ? "ডাব্লিউএইচও" : "WHO",
          "date": isBangla ? "মে ২০২৬" : "May 2026",
          "images": ["assets/images/pf2.jpg"],
          "url": "https://www.who.int"
        }
      ];
    } else if (category == "awareness") {
      return [
        {
          "title": isBangla ? "গর্ভাবস্থায় মানসিক স্বাস্থ্য ও যত্ন" : "Mental Health & Care During Pregnancy",
          "summary": isBangla
              ? "মায়ের মানসিক অবসাদ দূর করতে পরিবারের ভূমিকা এবং কিছু কার্যকরী টিপস।"
              : "Tips on managing stress and preserving mental well-being for expecting mothers.",
          "source": isBangla ? "আইসিডিডিআর,বি" : "icddr,b",
          "date": isBangla ? "জুলাই ২০২৬" : "July 2026",
          "images": ["assets/images/pf2.jpg"],
          "url": "https://www.icddrb.org"
        }
      ];
    } else if (category == "prevention") {
      return [
        {
          "title": isBangla ? "ঝুঁকিপূর্ণ লক্ষণ ও জটিলতা প্রতিরোধ" : "Preventing High-Risk Pregnancy Symptoms",
          "summary": isBangla
              ? "গর্ভাবস্থায় কোন কোন লক্ষণ দেখা দিলে অবিলম্বে হাসপাতালের শরণাপন্ন হতে হবে তার তালিকা।"
              : "Be aware of early warning signals and how to react promptly to avoid pregnancy complications.",
          "source": isBangla ? "ডাব্লিউএইচও" : "WHO",
          "date": isBangla ? "জুন ২০২৬" : "June 2026",
          "images": ["assets/images/pf2.jpg"],
          "url": "https://www.who.int"
        }
      ];
    }
    return [];
  }
}
