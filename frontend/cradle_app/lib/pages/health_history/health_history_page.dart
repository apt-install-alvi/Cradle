import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import './widgets/history_card.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

class HealthHistoryPage extends StatefulWidget {
  const HealthHistoryPage({super.key});

  @override
  State<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends State<HealthHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await ApiService.get('/predictions/history', token: token);
      final List<dynamic> data = response['data'] ?? [];
      
      setState(() {
        _historyItems = data.map((item) => Map<String, dynamic>.from(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching diagnosis history: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) return _historyItems;
    final q = _query.toLowerCase();
    return _historyItems.where((item) {
      final risk = (item['risk_level'] ?? '').toString().toLowerCase();
      final symptoms = (item['symptoms'] as List<dynamic>? ?? [])
          .map((s) => (s['type'] ?? '').toString().toLowerCase())
          .join(' ');
      return risk.contains(q) || symptoms.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(
        selectedIndex: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFAB0A65),
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'ডায়াগনোসিস ইতিহাস' : 'Diagnosis History',
                  style: AppText.headerTitle.copyWith(fontSize: 24),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFAB0A65)),
                onPressed: _fetchHistory,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            isBangla: isBangla,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFAB0A65)))
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          isBangla
                              ? 'আপনার ডায়াগনোসিস ইতিহাস পাওয়া যায়নি।'
                              : 'No diagnosis history found.',
                          style: AppText.subtext,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 180),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return HistoryCard(
                            item: item,
                            onTap: () {
                              // Optional: view detailed assessment if desired
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isBangla;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.isBangla,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: appCardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: AppColors.ink),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          hintText: isBangla ? 'ইতিহাস খুঁজুন (ঝুঁকি বা উপসর্গ)' : 'Search history (risk or symptom)',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.muted),
          prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
        ),
      ),
    );
  }
}
