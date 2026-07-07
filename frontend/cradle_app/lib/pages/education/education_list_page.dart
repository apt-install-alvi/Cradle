import 'package:flutter/material.dart';

class EducationListPage extends StatelessWidget {
  const EducationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = [
      {
        "title": "Essential Nutrition During Pregnancy",
        "subtitle":
            "Learn which nutrients are most important for a healthy pregnancy."
      },
      {
        "title": "Vaccination Schedule for Your Baby",
        "subtitle":
            "Keep track of important vaccines from birth to early childhood."
      },
      {
        "title": "Recognizing Pregnancy Warning Signs",
        "subtitle":
            "Know when to seek medical care for your safety and your baby's."
      },
    ];

    final faqs = [
      {
        "question": "How often should I visit a doctor during pregnancy?",
        "answer":
            "Regular antenatal checkups are recommended throughout pregnancy. Follow your healthcare provider's schedule."
      },
      {
        "question": "What foods should I avoid during pregnancy?",
        "answer":
            "Avoid raw meat, unpasteurized dairy products, excessive caffeine, and alcohol."
      },
      {
        "question": "When should breastfeeding begin?",
        "answer":
            "Breastfeeding should ideally begin within one hour after birth."
      },
      {
        "question": "How can I recognize dehydration in my child?",
        "answer":
            "Watch for dry lips, fewer wet diapers, excessive sleepiness, and lack of tears while crying."
      },
      {
        "question": "How can I reduce the risk of infections during pregnancy?",
        "answer":
            "Maintain good hygiene, eat properly cooked food, stay vaccinated, and attend regular checkups."
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFCAE1),
              Color(0xFFFFE8F2),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "Education",
                style: TextStyle(
                  fontFamily: "Gentium Book Plus",
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Color(0xFFAB0A65),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Learn about maternal and child health through trusted articles and FAQs.",
                style: TextStyle(
                  fontFamily: "Gentium Book Plus",
                  color: Color(0xFFAB0A65),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),

              /// Latest Articles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Latest Articles",
                    style: TextStyle(
                      fontFamily: "Gentium Book Plus",
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFFAB0A65),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Show More",
                      style: TextStyle(
                        fontFamily: "Gentium Book Plus",
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAB0A65),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ...articles.map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.52),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(18),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFAB0A65).withOpacity(.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.article_outlined,
                          color: Color(0xFFAB0A65),
                        ),
                      ),
                      title: Text(
                        article["title"]!,
                        style: const TextStyle(
                          fontFamily: "Gentium Book Plus",
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAB0A65),
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          article["subtitle"]!,
                          style: const TextStyle(
                            fontFamily: "Gentium Book Plus",
                            color: Color(0xFFAB0A65),
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFAB0A65),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "FAQs",
                style: TextStyle(
                  fontFamily: "Gentium Book Plus",
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFFAB0A65),
                ),
              ),

              const SizedBox(height: 15),

              ...faqs.map(
                (faq) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.52),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        collapsedIconColor: const Color(0xFFAB0A65),
                        iconColor: const Color(0xFFAB0A65),
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          20,
                        ),
                        title: Text(
                          faq["question"]!,
                          style: const TextStyle(
                            fontFamily: "Gentium Book Plus",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFAB0A65),
                            fontSize: 17,
                          ),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              faq["answer"]!,
                              style: const TextStyle(
                                fontFamily: "Gentium Book Plus",
                                color: Color(0xFFAB0A65),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}