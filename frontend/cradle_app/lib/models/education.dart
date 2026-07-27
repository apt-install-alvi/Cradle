class Article {
  final String id;
  final Map<String, String> title; // Localized: {'en': '...', 'bn': '...'}
  final Map<String, String> description;
  final Map<String, String> content;
  final String category;
  final String imageUrl;
  final int readingTimeMinutes;
  final String lastUpdated;
  final List<String>? tips;
  final List<String>? warningSigns;
  final String? contactDoctor;
  final List<String>? references;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.readingTimeMinutes,
    required this.lastUpdated,
    this.tips,
    this.warningSigns,
    this.contactDoctor,
    this.references,
  });

  String getTitle(bool isBangla) => title[isBangla ? 'bn' : 'en'] ?? '';
  String getDescription(bool isBangla) => description[isBangla ? 'bn' : 'en'] ?? '';
  String getContent(bool isBangla) => content[isBangla ? 'bn' : 'en'] ?? '';
}

class FAQ {
  final Map<String, String> question;
  final Map<String, String> answer;
  final String category;

  FAQ({
    required this.question,
    required this.answer,
    required this.category,
  });

  String getQuestion(bool isBangla) => question[isBangla ? 'bn' : 'en'] ?? '';
  String getAnswer(bool isBangla) => answer[isBangla ? 'bn' : 'en'] ?? '';
}
