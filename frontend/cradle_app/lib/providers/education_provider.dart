import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/education.dart';
import '../repositories/education_repository.dart';

class EducationProvider with ChangeNotifier {
  List<Article> _articles = [];
  List<FAQ> _faqs = [];
  
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Set<String> _bookmarkedArticleIds = {};
  Map<String, double> _readingProgress = {}; // articleId -> progress (0.0 to 1.0)
  int? _expandedFaqIndex;

  EducationProvider() {
    _loadData();
    _loadPreferences();
  }

  // Getters
  List<Article> get filteredArticles {
    return _articles.where((article) {
      // If searching, we ignore the category chip to provide global search results
      final matchesCategory = _searchQuery.isNotEmpty || _selectedCategory == 'All' || article.category == _selectedCategory;
      
      if (_searchQuery.isEmpty) return matchesCategory;

      final query = _searchQuery.toLowerCase();
      
      // Prefix matching on Title, Category, Description, and Content
      bool matchesTitle = article.title.values.any((t) {
        final cleanText = t.toLowerCase().trim();
        final words = cleanText.split(' ');
        return words.any((word) => word.startsWith(query)) || cleanText.contains(query);
      });
      
      // Check category in both English and Bangla
      final bnCat = _getCategoryNameBN(article.category);
      bool matchesCat = article.category.toLowerCase().startsWith(query) || 
                        bnCat.startsWith(query);

      bool matchesDesc = article.description.values.any((d) => d.toLowerCase().contains(query));
      bool matchesContent = article.content.values.any((c) => c.toLowerCase().contains(query));

      return matchesCategory && (matchesTitle || matchesCat || matchesDesc || matchesContent);
    }).toList();
  }

  List<FAQ> get filteredFAQs {
    if (_searchQuery.isEmpty) return _faqs;
    final query = _searchQuery.toLowerCase().trim();
    
    return _faqs.where((faq) {
      bool matchesQuestion = faq.question.values.any((q) {
        final cleanText = q.toLowerCase().trim();
        final words = cleanText.split(' ');
        return words.any((word) => word.startsWith(query)) || cleanText.contains(query);
      });
      
      bool matchesAnswer = faq.answer.values.any((a) => a.toLowerCase().contains(query));
      
      // Check FAQ category in both English and its likely Bangla equivalent
      final bnCat = _getCategoryNameBN(faq.category);
      bool matchesCat = faq.category.toLowerCase().startsWith(query) || 
                        bnCat.startsWith(query);

      return matchesQuestion || matchesAnswer || matchesCat;
    }).toList();
  }

  String _getCategoryNameBN(String cat) {
    switch (cat) {
      case 'All': return 'সব';
      case 'Trimester': return 'ত্রৈমাসিক';
      case 'Nutrition': return 'পুষ্টি';
      case 'Exercise': return 'ব্যায়াম';
      case 'Baby': return 'শিশু';
      case 'Maternal': return 'মা';
      case 'Mental Health': return 'মানসিক স্বাস্থ্য';
      case 'Emergency': return 'জরুরি';
      case 'Medication': return 'ওষুধ';
      case 'Checkups': return 'চেকআপ';
      default: return cat;
    }
  }

  List<Article> get bookmarkedArticles {
    return _articles.where((a) => _bookmarkedArticleIds.contains(a.id)).toList();
  }

  String get selectedCategory => _selectedCategory;
  int? get expandedFaqIndex => _expandedFaqIndex;
  
  bool isBookmarked(String id) => _bookmarkedArticleIds.contains(id);
  double getProgress(String id) => _readingProgress[id] ?? 0.0;

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFaq(int index) {
    if (_expandedFaqIndex == index) {
      _expandedFaqIndex = null;
    } else {
      _expandedFaqIndex = index;
    }
    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    if (_bookmarkedArticleIds.contains(id)) {
      _bookmarkedArticleIds.remove(id);
    } else {
      _bookmarkedArticleIds.add(id);
    }
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateProgress(String id, double progress) async {
    _readingProgress[id] = progress;
    notifyListeners();
    await _savePreferences();
  }

  // Data Loading
  void _loadData() {
    _articles = EducationRepository.getArticles();
    _faqs = EducationRepository.getFAQs();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkedArticleIds = (prefs.getStringList('bookmarks') ?? []).toSet();
    
    final progressList = prefs.getStringList('reading_progress') ?? [];
    for (var entry in progressList) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        _readingProgress[parts[0]] = double.tryParse(parts[1]) ?? 0.0;
      }
    }
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', _bookmarkedArticleIds.toList());
    
    final progressList = _readingProgress.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('reading_progress', progressList);
  }
}
