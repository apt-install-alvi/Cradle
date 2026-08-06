import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../providers/language_provider.dart';
import '../../../core/utils/bangla_numerals.dart';

/// A month-view calendar card showing medication adherence per day.
///
/// [adherenceByDate] maps a date (normalized to midnight, i.e. no time
/// component) to an adherence percentage of 100, 75, 50, or 25. Days
/// with no entry (no data yet, or a future date) render as plain,
/// unfilled numbers.
class AdherenceCalendarCard extends StatefulWidget {
  final Map<DateTime, int> adherenceByDate;
  final DateTime initialMonth;

  const AdherenceCalendarCard({
    super.key,
    required this.adherenceByDate,
    required this.initialMonth,
  });

  @override
  State<AdherenceCalendarCard> createState() => _AdherenceCalendarCardState();
}

class _AdherenceCalendarCardState extends State<AdherenceCalendarCard> {
  late DateTime _visibleMonth;

  static const _monthNamesEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _monthNamesBn = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  int? _adherenceFor(int day) {
    final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
    return widget.adherenceByDate[date];
  }

  Color _bgFor(int? pct) {
    switch (pct) {
      case 100:
        return DashboardBottomNav.primaryPink;
      case 75:
        return DashboardBottomNav.primaryPink.withValues(alpha: .7);
      case 50:
        return DashboardBottomNav.primaryPink.withValues(alpha: .25);
      case 25:
        return DashboardBottomNav.primaryPink.withValues(alpha: .15);
      default:
        return Colors.transparent;
    }
  }

  Color _textFor(int? pct) {
    if (pct == 100 || pct == 75) return Colors.white;
    return DashboardBottomNav.primaryPink;
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final monthName =
        isBangla ? _monthNamesBn[_visibleMonth.month - 1] : _monthNamesEn[_visibleMonth.month - 1];
    final weekdayLabels = isBangla
        ? ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি']
        : ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // DateTime.weekday: Monday=1...Sunday=7. Convert so Sunday=0 for a
    // Sun-first grid, matching the weekday header order above.
    final firstWeekdayIndex =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.largeCard),
        boxShadow: appCardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalendarNavButton(
                icon: Icons.chevron_left,
                onTap: _goToPreviousMonth,
              ),
            Text(
              isBangla
                  ? '$monthName ${toBanglaDigits(_visibleMonth.year)}'
                  : '$monthName ${_visibleMonth.year}',
              style: AppText.sectionHeading.copyWith(fontSize: 16),
            ),
              _CalendarNavButton(
                icon: Icons.chevron_right,
                onTap: _goToNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: weekdayLabels
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(d, style: AppText.eyebrow.copyWith(fontSize: 10.5)),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
            ),
            itemCount: firstWeekdayIndex + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekdayIndex) return const SizedBox();
              final day = index - firstWeekdayIndex + 1;
              final pct = _adherenceFor(day);
              return Center(
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _bgFor(pct), shape: BoxShape.circle),
                child: Text(
                    isBangla ? toBanglaDigits(day) : '$day',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: pct == null ? AppColors.ink : _textFor(pct),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Text(
                isBangla ? '% ওষুধ গ্রহণ সম্পন্ন' : '% Medication Completed',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 12,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _LegendItem(
                    color: _bgFor(100),
                    label: isBangla ? '${toBanglaDigits(100)}%' : '100%',
                  ),
                  _LegendItem(
                    color: _bgFor(75),
                    label: isBangla ? '${toBanglaDigits(75)}%' : '75%',
                  ),
                  _LegendItem(
                    color: _bgFor(50),
                    label: isBangla ? '${toBanglaDigits(50)}%' : '50%',
                  ),
                  _LegendItem(
                    color: _bgFor(25),
                    label: isBangla ? '${toBanglaDigits(25)}%' : '25%',
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CalendarNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDEAF1),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 18, color: DashboardBottomNav.primaryPink),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color? color;
  final String label;
  const _LegendItem({this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color == Colors.transparent
                ? DashboardBottomNav.primaryPink.withValues(alpha: .15)
                : color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
