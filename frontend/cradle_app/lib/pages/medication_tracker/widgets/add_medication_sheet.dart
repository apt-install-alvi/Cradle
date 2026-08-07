import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../models/medication.dart';
import '../../../providers/language_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One selectable option in the medicine-type icon picker. All options
/// currently point at the shared placeholder PNG; swap [assetPath] per
/// option once real per-type icon assets are added to the project.
class _MedIconOption {
  final String id;
  final String labelEn;
  final String labelBn;
  final String assetPath;

  const _MedIconOption({
    required this.id,
    required this.labelEn,
    required this.labelBn,
    this.assetPath = 'assets/icons/placeholder.png',
  });
}

const List<_MedIconOption> _iconOptions = [
  _MedIconOption(
    id: 'capsule', 
    labelEn: 'Capsule', 
    labelBn: 'ক্যাপসুল',
    assetPath: 'assets/icons/pill.svg'
    ),
  _MedIconOption(
    id: 'tablet', 
    labelEn: 'Tablet', 
    labelBn: 'ট্যাবলেট',
    assetPath: 'assets/icons/round_pill.svg'
    ),
  _MedIconOption(
    id: 'bottle', 
    labelEn: 'Bottle', 
    labelBn: 'বোতল',
    assetPath: 'assets/icons/bottle.svg'
    ),
  _MedIconOption(
    id: 'injection', 
    labelEn: 'Injection', 
    labelBn: 'ইনজেকশন',
    assetPath: 'assets/icons/syringe.svg'
    ),
  _MedIconOption(
    id: 'drops', 
    labelEn: 'Drops', 
    labelBn: 'ড্রপস',
    assetPath: 'assets/icons/dropper.svg'
    ),
  _MedIconOption(
    id: 'topical', 
    labelEn: 'Topical', 
    labelBn: 'ক্রিম/মলম',
    assetPath: 'assets/icons/lotion.svg'
    ),
];

const List<MapEntry<String, String>> _medicineUnits = [
  MapEntry('mg', 'মি.গ্রা.'),
  MapEntry('mcg', 'মাইক্রোগ্রাম'),
  MapEntry('g', 'গ্রাম'),
  MapEntry('mL', 'মি.লি.'),
  MapEntry('L', 'লিটার'),
  MapEntry('tablet', 'ট্যাবলেট'),
  MapEntry('capsule', 'ক্যাপসুল'),
  MapEntry('drops', 'ড্রপ'),
  MapEntry('puff', 'পাফ'),
];

/// Su-first weekday chips for the Custom frequency day picker, paired
/// with their [DateTime.weekday] values (Monday=1 ... Sunday=7).
const List<MapEntry<String, int>> _weekdayChips = [
  MapEntry('Su', 7),
  MapEntry('Mo', 1),
  MapEntry('Tu', 2),
  MapEntry('We', 3),
  MapEntry('Th', 4),
  MapEntry('Fr', 5),
  MapEntry('Sa', 6),
];

const List<MapEntry<String, int>> _weekdayChipsBn = [
  MapEntry('রবি', 7),
  MapEntry('সোম', 1),
  MapEntry('মঙ্গল', 2),
  MapEntry('বুধ', 3),
  MapEntry('বৃহঃ', 4),
  MapEntry('শুক্র', 5),
  MapEntry('শনি', 6),
];

/// Shows the Add/Edit Medication bottom sheet and returns the resulting
/// [Medication] when saved, or null if cancelled/dismissed.
Future<Medication?> showAddMedicationSheet(
  BuildContext context, {
  Medication? existing,
}) {
  return showModalBottomSheet<Medication>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddMedicationSheet(existing: existing),
  );
}

class AddMedicationSheet extends StatefulWidget {
  final Medication? existing;
  const AddMedicationSheet({super.key, this.existing});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late String _selectedUnit;
  late String _selectedIconId;
  late MedicationFrequency _frequency;
  late List<TimeOfDay> _times;
  late Set<int> _customDays;

  static const List<TimeOfDay> _defaultTimes = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _amountController = TextEditingController(text: existing?.doseAmount.toString() ?? '');
    _selectedUnit = existing?.doseUnit ?? 'mg';    _selectedIconId = existing == null
    ? _iconOptions.first.id
    : _iconOptions.firstWhere(
        (o) => o.assetPath == existing.iconAsset,
        orElse: () => _iconOptions.first,
      ).id;
    _frequency = existing?.frequency ?? MedicationFrequency.once;
    _times = existing != null ? List.of(existing.times) : [const TimeOfDay(hour: 8, minute: 0)];
    _customDays = existing != null ? Set.of(existing.customDays) : {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectFrequency(MedicationFrequency frequency) {
    setState(() {
      _frequency = frequency;
      switch (frequency) {
        case MedicationFrequency.once:
          _times = [_defaultTimes[0]];
          break;
        case MedicationFrequency.twice:
          _times = [_defaultTimes[0], _defaultTimes[1]];
          break;
        case MedicationFrequency.thrice:
          _times = [_defaultTimes[0], _defaultTimes[1], _defaultTimes[2]];
          break;
        case MedicationFrequency.custom:
          // Custom frequency keeps whatever time rows already exist;
          // the user adds/removes them manually.
          break;
      }
    });
  }

  void _toggleCustomDay(int weekday) {
    setState(() {
      if (_customDays.contains(weekday)) {
        _customDays.remove(weekday);
      } else {
        _customDays.add(weekday);
      }
    });
  }

  Future<void> _editTime(int index) async {
    final picked = await showTimePicker(context: context, initialTime: _times[index]);
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
  }

  void _addTimeRow() {
    setState(() => _times.add(const TimeOfDay(hour: 12, minute: 0)));
  }

  void _removeTimeRow(int index) {
    if (_times.length <= 1) return;
    setState(() => _times.removeAt(index));
  }

  void _save() {
    final isBangla = context.read<LanguageProvider>().isBangla;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBangla ? 'ওষুধের নাম লিখুন' : 'Please enter the medicine name'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final iconOption = _iconOptions.firstWhere((o) => o.id == _selectedIconId);

    final medication = Medication(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      iconAsset: iconOption.assetPath,
      doseAmount: amount,
      doseUnit: _selectedUnit,
      frequency: _frequency,
      times: List.of(_times),
      customDays: _frequency == MedicationFrequency.custom ? _customDays.toList() : const [],
    );

    Navigator.of(context).pop(medication);
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final isEditing = widget.existing != null;
    final weekdayChips = isBangla ? _weekdayChipsBn : _weekdayChips;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF1DCE4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF7E4EC))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing
                        ? (isBangla ? 'ওষুধ সম্পাদনা করুন' : 'Edit Medication')
                        : (isBangla ? 'ওষুধ যোগ করুন' : 'Add Medication'),
                    style: AppText.sectionHeading.copyWith(fontSize: 19),
                  ),
                  Material(
                    color: const Color(0xFFFDEAF1),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(Icons.close, size: 18, color: DashboardBottomNav.primaryPink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormLabel(isBangla ? 'আইকন' : 'Icon'),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2
                      ),
                      itemCount: _iconOptions.length,
                      itemBuilder: (context, index) {
                        final option = _iconOptions[index];
                        final selected = option.id == _selectedIconId;
                        return Tooltip(
                          message: isBangla ? option.labelBn : option.labelEn,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setState(() => _selectedIconId = option.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFFCE0EC)
                                    : const Color(0xFFFDEAF1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? DashboardBottomNav.primaryPink
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  option.assetPath,
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    DashboardBottomNav.primaryPink,
                                    BlendMode.srcIn,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  isBangla ? option.labelBn : option.labelEn,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: DashboardBottomNav.primaryPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      );
                    },
                  ),
                    _FormLabel(isBangla ? 'ওষুধের নাম' : 'Medicine Name'),
                    const SizedBox(height: 8),
                    _AppTextField(
                      controller: _nameController,
                      hint: isBangla ? 'যেমন: ফলিক অ্যাসিড' : 'e.g. Folic Acid',
                    ),
                    _FormLabel(isBangla ? 'ডোজ' : 'Dose'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _AppTextField(
                            controller: _amountController,
                            hint: isBangla ? 'পরিমাণ (যেমন: ৪০০)' : 'Amount (e.g. 400)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 140,
                          child: DropdownMenu<String>(
                            key: ValueKey(_selectedUnit),
                            initialSelection: _selectedUnit,
                            

                            onSelected: (value) {
                              if (value != null) {
                                setState(() => _selectedUnit = value);
                              }
                            },

                            dropdownMenuEntries: _medicineUnits.map((unit) {
                              return DropdownMenuEntry<String>(
                                value: unit.key,
                                label: isBangla ? unit.value : unit.key,
                                labelWidget: Text(
                                  isBangla ? unit.value : unit.key,
                                  style: const TextStyle(
                                    color: DashboardBottomNav.primaryPink,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                )
                              );
                            }).toList(),

                            menuHeight: 250,

                            menuStyle: MenuStyle(
                              backgroundColor: const WidgetStatePropertyAll(Colors.white),
                              elevation: const WidgetStatePropertyAll(8),
                              shadowColor: WidgetStatePropertyAll(
                                Colors.black.withValues(alpha: 0.15),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),

                            inputDecorationTheme: InputDecorationTheme(
                              filled: true,
                              fillColor: const Color(0xFFFFFBFC),
                              isDense: true,
                                constraints: const BoxConstraints(
                                  minHeight: 48,
                                ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF5D9E4),
                                  width: 1.5,
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF5D9E4),
                                  width: 1.5,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: DashboardBottomNav.primaryPink,
                                  width: 1.5,
                                ),
                              ),
                            ),

                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: DashboardBottomNav.primaryPink,
                              fontWeight: FontWeight.w500,
                            ),

                            trailingIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: DashboardBottomNav.primaryPink,
                            ),

                            selectedTrailingIcon: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: DashboardBottomNav.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _FormLabel(isBangla ? 'কতবার' : 'Frequency'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FrequencyChip(
                          label: isBangla ? 'দিনে একবার' : 'Once daily',
                          selected: _frequency == MedicationFrequency.once,
                          onTap: () => _selectFrequency(MedicationFrequency.once),
                        ),
                        _FrequencyChip(
                          label: isBangla ? 'দিনে দুইবার' : 'Twice daily',
                          selected: _frequency == MedicationFrequency.twice,
                          onTap: () => _selectFrequency(MedicationFrequency.twice),
                        ),
                        _FrequencyChip(
                          label: isBangla ? 'দিনে তিনবার' : 'Three times daily',
                          selected: _frequency == MedicationFrequency.thrice,
                          onTap: () => _selectFrequency(MedicationFrequency.thrice),
                        ),
                        _FrequencyChip(
                          label: isBangla ? 'নির্দিষ্ট দিনে' : 'Custom',
                          selected: _frequency == MedicationFrequency.custom,
                          onTap: () => _selectFrequency(MedicationFrequency.custom),
                        ),
                      ],
                    ),
                    if (_frequency == MedicationFrequency.custom) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: weekdayChips.map((entry) {
                          final selected = _customDays.contains(entry.value);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _toggleCustomDay(entry.value),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selected ? DashboardBottomNav.primaryPink : const Color(0xFFFDEAF1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: selected ? Colors.white : DashboardBottomNav.primaryPink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    _FormLabel(isBangla ? 'সময়' : 'Time(s)'),
                    if (_frequency == MedicationFrequency.custom) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          isBangla
                              ? 'আপনার নির্বাচিত দিনগুলোর জন্য প্রতিটি ডোজের সময় যোগ করুন।'
                              : 'Add a time for each dose on your selected days.',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 8),
                    Column(
                      children: List.generate(_times.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => _editTime(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFF5D9E4), width: 1.5),
                                      color: const Color(0xFFFFFBFC),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _times[index].format(context), 
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: DashboardBottomNav.primaryPink,
                                            fontWeight: FontWeight.w700,
                                            )),
                                        Icon(Icons.access_time, size: 17, color: DashboardBottomNav.primaryPink),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Material(
                                color: const Color(0xFFFDEAF1),
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _removeTimeRow(index),
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Icon(Icons.close, size: 14, color: DashboardBottomNav.primaryPink),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    InkWell(
                      onTap: _addTimeRow,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline, size: 20, color: DashboardBottomNav.primaryPink),
                            const SizedBox(width: 6),
                            Text(
                              isBangla ? 'আরেকটি সময় যোগ করুন' : 'Add another time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: DashboardBottomNav.primaryPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF7E4EC))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDEAF1),
                        foregroundColor: DashboardBottomNav.primaryPink,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isBangla ? 'বাতিল' : 'Cancel',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DashboardBottomNav.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isBangla ? 'সংরক্ষণ করুন' : 'Save Medication',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: DashboardBottomNav.primaryPink,
        ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _AppTextField({required this.controller, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.muted),
        filled: true,
        fillColor: const Color(0xFFFFFBFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF5D9E4), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF5D9E4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: DashboardBottomNav.primaryPink, width: 1.5),
        ),
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FrequencyChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? DashboardBottomNav.primaryPink : const Color(0xFFFDEAF1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : DashboardBottomNav.primaryPink,
          ),
        ),
      ),
    );
  }
}
