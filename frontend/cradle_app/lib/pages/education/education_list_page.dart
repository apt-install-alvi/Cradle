import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class EducationListPage extends StatefulWidget {
  const EducationListPage({Key? key}) : super(key: key);

  @override
  State<EducationListPage> createState() => _EducationListPageState();
}

class _EducationListPageState extends State<EducationListPage> {
  bool _isLoading = true;
  List<dynamic> _articles = [];
  int? _selectedTrimester;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiService.getArticles(trimester: _selectedTrimester);
      setState(() {
        _articles = res['success'] == true ? res['data'] : [];
      });
    } catch (_) {}

    setState(() {
      _isLoading = false;
    });
  }

  void _showArticleDetails(dynamic article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final title = article['title'] ?? '';
        final content = article['content'] ?? '';
        final category = article['category'] ?? '';
        final readTime = article['readingTimeMinutes'] ?? 5;

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$readTime min read',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Divider(height: 32),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Library'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Trimester Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter by Trimester:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8.0,
                    children: [1, 2, 3].map((tri) {
                      final isSelected = _selectedTrimester == tri;
                      return ChoiceChip(
                        label: Text('T$tri'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTrimester = selected ? tri : null;
                          });
                          _loadArticles();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            // Articles List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _articles.isEmpty
                      ? const Center(child: Text('No articles found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: _articles.length,
                          itemBuilder: (context, index) {
                            final art = _articles[index];
                            final title = art['title'] ?? '';
                            final category = art['category'] ?? '';
                            final readTime = art['readingTimeMinutes'] ?? 5;
                            final summary = art['content']?.substring(0, 80) + '...';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor),
                                onTap: () => _showArticleDetails(art),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


