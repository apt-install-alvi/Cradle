import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../utils/health_format_utils.dart';

const _brand = DashboardBottomNav.primaryPink;
const _brandSofter = Color(0xFFFCEEF5);
const _brandSoft = Color(0xFFF6D9E9);
const _muted = Color(0xFF8A7680);
const _ink = Color(0xFF3A2C33);

const List<String> _dayLettersEn = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const List<String> _dayLettersBn = ['র', 'সো', 'ম', 'বু', 'বৃ', 'শু', 'শ'];

/// Frequency stepper + reminder time slots + repeat-day chips.
/// Used both inline (main screen, pre-tracking config) and on the
/// Edit Preferences screen.
class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({
    super.key,
    required this.freq,
    required this.times,
    required this.days,
    required this.isBangla,
    required this.onFreqChange,
    required this.onTimeChange,
    required this.onDayToggle,
    this.showReminderNote = false,
  });

  final int freq;
  final List<String> times;
  final List<bool> days;
  final bool isBangla;
  final ValueChanged<int> onFreqChange; // delta
  final void Function(int index, String hhmm) onTimeChange;
  final ValueChanged<int> onDayToggle; // index
  final bool showReminderNote;

  @override
  Widget build(BuildContext context) {
    final dayLetters = isBangla ? _dayLettersBn : _dayLettersEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(isBangla ? 'দিনে কতবার' : 'Times per day'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _brandSofter,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _stepperBtn('−', () => onFreqChange(-1)),
                  SizedBox(
                    width: 26,
                    child: Text(
                      localizedNumber(freq, isBangla),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gentiumBookPlus(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _ink,
                      ),
                    ),
                  ),
                  _stepperBtn('+', () => onFreqChange(1)),
                ],
              ),
            ),
            SizedBox(
              width: 130,
              child: Text(
                isBangla
                    ? 'প্রতিটি রিডিংয়ের জন্য একটি রিমাইন্ডার যোগ করুন'
                    : 'Add a reminder for each reading',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, color: _muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _label(isBangla ? 'রিমাইন্ডারের সময়' : 'Reminder times'),
        Column(
          children: List.generate(times.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: parseHHmm(times[i]),
                  );
                  if (picked != null) {
                    onTimeChange(i, timeOfDayToHHmm(picked));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _brandSofter,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: _brand,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          localizedNumber(i + 1, isBangla),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        fmtTime12h(times[i], isBangla: isBangla),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        _label(isBangla ? 'পুনরাবৃত্তি হবে' : 'Repeat on'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final selected = days[i];
            return GestureDetector(
              onTap: () => onDayToggle(i),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _brand : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? _brand : _brandSoft,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  dayLetters[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _brand,
                  ),
                ),
              ),
            );
          }),
        ),
        if (showReminderNote) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _brandSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔔', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBangla
                        ? 'আপনার নির্বাচিত দিনগুলোতে প্রতিটি রিমাইন্ডার সময়ে আমরা আপনাকে একটি বিজ্ঞপ্তি পাঠাব।'
                        : "We'll send you a notification at each reminder time on the days you've selected.",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF7A0F4F),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: _brand,
          ),
        ),
      );

  Widget _stepperBtn(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: _brand, shape: BoxShape.circle),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
