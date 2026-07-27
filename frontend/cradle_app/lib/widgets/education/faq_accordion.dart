import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/education.dart';

class FAQAccordion extends StatelessWidget {
  final FAQ faq;
  final bool isBangla;
  final bool isExpanded;
  final VoidCallback onToggle;

  const FAQAccordion({
    super.key,
    required this.faq,
    required this.isBangla,
    required this.isExpanded,
    required this.onToggle,
  });

  static const Color _accent = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          key: GlobalKey(), // Forces state update on index change
          onExpansionChanged: (_) => onToggle(),
          title: Text(
            faq.getQuestion(isBangla),
            style: GoogleFonts.gentiumBookPlus(
              fontWeight: FontWeight.bold,
              color: _accent,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: _accent,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.getAnswer(isBangla),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
