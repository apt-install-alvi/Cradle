import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import '../../providers/health_tracking_provider.dart';
import './models/vital_definition.dart';
import './models/vital_log.dart';
import './utils/health_format_utils.dart';
import './widgets/health_top_bar.dart';
import './widgets/confirm_modal.dart';

const _brand = DashboardBottomNav.primaryPink;
const _brandSofter = Color(0xFFFCEEF5);
const _ink = Color(0xFF3A2C33);
const _muted = Color(0xFF8A7680);

enum LogEntryMode { initial, edit }

class LogEntryPage extends StatefulWidget {
  const LogEntryPage({
    super.key,
    required this.vitalKey,
    required this.mode,
    this.logId,
  });

  final String vitalKey;
  final LogEntryMode mode;
  final String? logId;

  @override
  State<LogEntryPage> createState() => _LogEntryPageState();
}

class _LogEntryPageState extends State<LogEntryPage> {
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _context;
  bool _initialized = false;

  VitalLog? get _existing {
    if (widget.mode != LogEntryMode.edit || widget.logId == null) return null;
    final provider = context.read<HealthTrackingProvider>();
    final logs = provider.state(widget.vitalKey).logs;
    try {
      return logs.firstWhere((l) => l.id == widget.logId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _valueCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final def = kVitalDefinitions[widget.vitalKey]!;
    final isBangla = context.watch<LanguageProvider>().isBangla;

    if (!_initialized) {
      final existing = _existing;
      if (existing != null) {
        if (def.type == VitalType.bp) {
          _systolicCtrl.text = existing.systolic?.toString() ?? '';
          _diastolicCtrl.text = existing.diastolic?.toString() ?? '';
        } else {
          _valueCtrl.text = existing.value?.toString() ?? '';
        }
        _noteCtrl.text = existing.note;
        _context = existing.context;
      }
      _initialized = true;
    }

    final title = widget.mode == LogEntryMode.initial
        ? (isBangla ? '${def.nameBn} লগ করুন' : 'Log ${def.nameEn}')
        : (isBangla ? '${def.nameBn} রিডিং সম্পাদনা করুন' : 'Edit ${def.nameEn} reading');
    final subtitle = widget.mode == LogEntryMode.initial
        ? (isBangla ? 'আসুন আপনার প্রথম রিডিং রেকর্ড করি' : "Let's capture your first reading")
        : (isBangla ? 'এই রিডিংটি আপডেট করুন' : 'Update this reading');

    return GradientScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          HealthTopBar(title: title, subtitle: subtitle),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x29C87896), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: _brandSofter,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    def.iconAsset,
                    width: 26,
                    height: 26,
                    color: _brand,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (_, __, ___) => const Icon(Icons.favorite, color: _brand),
                  ),
                ),
                const SizedBox(height: 16),
                if (def.type == VitalType.bp) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          label: isBangla ? 'সিস্টোলিক' : 'Systolic',
                          controller: _systolicCtrl,
                          hint: '120',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NumberField(
                          label: isBangla ? 'ডায়াস্টোলিক' : 'Diastolic',
                          controller: _diastolicCtrl,
                          hint: '80',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('mmHg', style: TextStyle(fontSize: 11.5, color: _muted)),
                ] else ...[
                  _NumberField(
                    label: def.name(isBangla),
                    controller: _valueCtrl,
                    hint: 'e.g. ${(((def.min ?? 0) + (def.max ?? 0)) / 2).round()}',
                    suffix: def.unit,
                    allowDecimal: def.decimals > 0,
                  ),
                  if (def.hasContext) ...[
                    const SizedBox(height: 16),
                    Text(
                      (isBangla ? 'প্রসঙ্গ' : 'Context').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _brand,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kGlucoseContexts.map((c) {
                        final selected = _context == c;
                        return GestureDetector(
                          onTap: () => setState(() => _context = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? _brand : _brandSofter,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              localizedGlucoseContext(c, isBangla),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : _brand,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Text(
                  (isBangla ? 'নোট (ঐচ্ছিক)' : 'Note (optional)').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: _brand,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13.5, color: _ink),
                  decoration: InputDecoration(
                    hintText: isBangla ? "আপনি যা যোগ করতে চান…" : "Anything you'd like to add…",
                    hintStyle: const TextStyle(fontSize: 13.5, color: _muted),
                    filled: true,
                    fillColor: _brandSofter,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _save(context, def, isBangla),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                widget.mode == LogEntryMode.initial
                    ? (isBangla ? 'রিডিং সংরক্ষণ করুন' : 'Save reading')
                    : (isBangla ? 'রিডিং আপডেট করুন' : 'Update reading'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context, VitalDefinition def, bool isBangla) {
    final provider = context.read<HealthTrackingProvider>();
    final note = _noteCtrl.text;

    if (def.type == VitalType.bp) {
      final sys = int.tryParse(_systolicCtrl.text);
      final dia = int.tryParse(_diastolicCtrl.text);
      if (sys == null || dia == null) {
        showHealthToast(
          context,
          isBangla ? 'সিস্টোলিক এবং ডায়াস্টোলিক উভয়ই লিখুন' : 'Enter both systolic and diastolic',
        );
        return;
      }
      if (widget.mode == LogEntryMode.initial) {
        provider.addInitialLog(
          widget.vitalKey,
          VitalLog(id: _tempId(), date: DateTime.now(), systolic: sys, diastolic: dia, note: note),
        );
        showHealthToast(context, isBangla ? '${def.nameBn} রিডিং সংরক্ষিত হয়েছে' : '${def.nameEn} reading saved');
        Navigator.of(context).pop();
      } else {
        provider.updateLog(
          widget.vitalKey,
          widget.logId!,
          _existing!.copyWith(systolic: sys, diastolic: dia, note: note),
        );
        showHealthToast(context, isBangla ? 'রিডিং আপডেট হয়েছে' : 'Reading updated');
        Navigator.of(context).pop();
      }
    } else {
      final val = double.tryParse(_valueCtrl.text);
      if (val == null) {
        showHealthToast(context, isBangla ? 'চালিয়ে যেতে একটি মান লিখুন' : 'Enter a value to continue');
        return;
      }
      if (widget.mode == LogEntryMode.initial) {
        provider.addInitialLog(
          widget.vitalKey,
          VitalLog(
            id: _tempId(),
            date: DateTime.now(),
            value: val,
            context: def.hasContext ? _context : null,
            note: note,
          ),
        );
        showHealthToast(context, isBangla ? '${def.nameBn} রিডিং সংরক্ষিত হয়েছে' : '${def.nameEn} reading saved');
        Navigator.of(context).pop();
      } else {
        provider.updateLog(
          widget.vitalKey,
          widget.logId!,
          _existing!.copyWith(value: val, context: def.hasContext ? _context : null, note: note),
        );
        showHealthToast(context, isBangla ? 'রিডিং আপডেট হয়েছে' : 'Reading updated');
        Navigator.of(context).pop();
      }
    }
  }

  String _tempId() => 'log_${DateTime.now().microsecondsSinceEpoch}';
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    this.hint,
    this.suffix,
    this.allowDecimal = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? suffix;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: _brand,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
                style: GoogleFonts.gentiumBookPlus(fontSize: 20, fontWeight: FontWeight.w700, color: _ink),
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: _brandSofter,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 10),
              Text(suffix!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _muted)),
            ],
          ],
        ),
      ],
    );
  }
}
