import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EducationListPage extends StatelessWidget {
  const EducationListPage({super.key});

  static const Color primaryPink = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Education Guides",
            style: GoogleFonts.gentiumBookPlus(
              fontWeight: FontWeight.bold,
              color: primaryPink,
            ),
          ),
          bottom: TabBar(
            labelColor: primaryPink,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryPink,
            labelStyle: GoogleFonts.gentiumBookPlus(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: "Mother’s Health"),
              Tab(text: "Baby’s Health"),
              Tab(text: "Awareness & Guidance"),
              Tab(text: "Prevention & Safety"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ArticleFeed(category: "maternal"),
            ArticleFeed(category: "baby"),
            ArticleFeed(category: "awareness"),
            ArticleFeed(category: "prevention"),
          ],
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
  const ArticleFeed({super.key, required this.category});

  static const Color primaryPink = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    // Sample articles (replace with API/RSS data)
    final articles = [
      {
        "title": "Healthy Nutrition During Pregnancy",
        "summary": "Learn what foods to eat and avoid for a safe pregnancy.",
        "source": "WHO",
        "date": "July 2026",
        "url": "https://www.who.int/maternal-health"
      },
      {
        "title": "Baby Jaundice Awareness",
        "summary": "Understand symptoms and when to seek medical help.",
        "source": "UNICEF",
        "date": "July 2026",
        "url": "https://www.unicef.org/baby-health"
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article["title"]!,
                  style: GoogleFonts.gentiumBookPlus(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryPink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article["summary"]!,
                  style: GoogleFonts.gentiumBookPlus(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${article["source"]} • ${article["date"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: open article in WebView or browser
                    },
                    child: const Text("Read More"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
