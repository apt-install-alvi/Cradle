import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/education.dart';
import '../../providers/education_provider.dart';

class ArticleDetailPage extends StatefulWidget {
  final Article article;
  final bool isBangla;

  const ArticleDetailPage({
    super.key,
    required this.article,
    required this.isBangla,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  double _scrollProgress = 0.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initTts();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final progress = _scrollController.offset / _scrollController.position.maxScrollExtent;
      setState(() {
        _scrollProgress = progress.clamp(0.0, 1.0);
      });
      // Update reading progress in provider
      if (_scrollProgress > context.read<EducationProvider>().getProgress(widget.article.id)) {
          context.read<EducationProvider>().updateProgress(widget.article.id, _scrollProgress);
      }
    }
  }

  Future<void> _initTts() async {
    // Attempt to set language
    String lang = widget.isBangla ? 'bn-BD' : 'en-US';
    bool isAvailable = await _flutterTts.isLanguageAvailable(lang);
    
    if (!isAvailable && widget.isBangla) {
      // Fallback for Bangla
      lang = 'bn-IN';
      isAvailable = await _flutterTts.isLanguageAvailable(lang);
    }

    if (isAvailable) {
      await _flutterTts.setLanguage(lang);
      await _flutterTts.setSpeechRate(0.5); // Slightly slower for better clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    }

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() => _isPlaying = false);
        _showErrorSnackBar(widget.isBangla ? "অডিও প্লে করতে সমস্যা হয়েছে" : "Error playing audio: $msg");
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _speak() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      String content = widget.article.getContent(widget.isBangla);
      if (content.isEmpty) return;
      
      if (mounted) setState(() => _isPlaying = true);
      var result = await _flutterTts.speak(content);
      if (result == 0 && mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  static const Color _accent = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: _accent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.stop_circle : Icons.volume_up, color: Colors.white),
                    onPressed: _speak,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      Share.share('${widget.article.getTitle(widget.isBangla)}\n\n${widget.article.getContent(widget.isBangla)}');
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    widget.article.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Meta
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.article.category,
                              style: const TextStyle(color: _accent, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.article.readingTimeMinutes} ${widget.isBangla ? "মিনিট পড়া" : "min read"}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.article.getTitle(widget.isBangla),
                        style: GoogleFonts.gentiumBookPlus(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.isBangla ? "সর্বশেষ আপডেট" : "Last updated"}: ${widget.article.lastUpdated}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const Divider(height: 40),

                      // Content
                      Text(
                        widget.article.getContent(widget.isBangla),
                        style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 32),

                      // Important Tips
                      if (widget.article.tips != null) ...[
                        _buildSectionHeader(widget.isBangla ? "গুরুত্বপূর্ণ টিপস" : "Important Tips", Icons.lightbulb_outline),
                        const SizedBox(height: 12),
                        ...widget.article.tips!.map((tip) => _buildBulletPoint(tip)),
                        const SizedBox(height: 32),
                      ],

                      // Warning Signs
                      if (widget.article.warningSigns != null) ...[
                        _buildWarningCard(),
                        const SizedBox(height: 32),
                      ],

                      // When to Contact Doctor
                      if (widget.article.contactDoctor != null) ...[
                        _buildSectionHeader(widget.isBangla ? "কখন ডাক্তারের সাথে যোগাযোগ করবেন" : "When to Contact a Doctor", Icons.local_hospital_outlined),
                        const SizedBox(height: 12),
                        Text(
                          widget.article.contactDoctor!,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Medical Disclaimer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.isBangla 
                            ? "এই অ্যাপ্লিকেশনটি শুধুমাত্র শিক্ষামূলক তথ্য প্রদান করে এবং পেশাদার চিকিৎসা পরামর্শের বিকল্প নয়। রোগ নির্ণয় এবং চিকিৎসার জন্য সর্বদা একজন যোগ্য স্বাস্থ্যসেবা প্রদানকারীর সাথে পরামর্শ করুন।"
                            : "This application provides educational information only and does not replace professional medical advice. Always consult a qualified healthcare provider for diagnosis and treatment.",
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Reading Progress Bar at the top (under AppBar)
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _scrollProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(_accent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.gentiumBookPlus(fontSize: 20, fontWeight: FontWeight.bold, color: _accent),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 20, color: _accent)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                widget.isBangla ? "সতর্ক সংকেত" : "Warning Signs",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.article.warningSigns!.map((sign) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(sign, style: const TextStyle(color: Colors.red))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
