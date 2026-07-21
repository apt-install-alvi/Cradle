import 'package:flutter/material.dart';
import '../models/diagnosis_result.dart';

/// Color-coded pill showing the assessed risk level
/// (green = low, yellowish-orange = medium, red = high).
class RiskPill extends StatelessWidget {
  final RiskLevel riskLevel;

  const RiskPill({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: riskLevel.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: riskLevel.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            riskLevel.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: riskLevel.color,
            ),
          ),
        ],
      ),
    );
  }
}
