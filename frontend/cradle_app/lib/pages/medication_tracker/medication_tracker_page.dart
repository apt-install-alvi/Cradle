import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import './models/medication.dart';
import './models/scheduled_dose.dart';
import '../../providers/language_provider.dart';
import '../../providers/medication_provider.dart';
import './widgets/adherence_calendar_card.dart';
import './widgets/dose_card.dart';
import './widgets/medication_list_card.dart';
import './widgets/add_medication_sheet.dart';

class MedicationTrackerPage extends StatefulWidget {
  const MedicationTrackerPage({super.key});

  @override
  State<MedicationTrackerPage> createState() => _MedicationTrackerPageState();
}

class _MedicationTrackerPageState extends State<MedicationTrackerPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _openAddMedicationSheet({Medication? existing}) async {
    final result = await showAddMedicationSheet(context, existing: existing);
    if (result == null) return;

    if (mounted) {
      final provider = context.read<MedicationProvider>();
      await provider.addMedication(result);
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    final isBangla = context.read<LanguageProvider>().isBangla;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isBangla ? 'ওষুধ মুছে ফেলবেন?' : 'Delete Medication?',
            style: AppText.sectionHeading,
          ),
          content: Text(
            isBangla
                ? '"${medication.name}" তালিকা থেকে সরানো হবে। আপনি কি নিশ্চিত?'
                : '"${medication.name}" will be removed from your medication list.\n\nAre you sure?',
            style: AppText.subtext,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFDEAF1),
                foregroundColor: DashboardBottomNav.primaryPink,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(isBangla ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(isBangla ? 'মুছুন' : 'Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    // TODO: Implement delete in provider and backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete not yet implemented in backend')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final provider = context.watch<MedicationProvider?>();

    if (provider == null || provider.isLoading) {
      return GradientScaffold(
        bottomNavigationBar: const DashboardBottomNav(selectedIndex: 3),
        child: Center(
          child: provider == null
            ? const Text("Please log in to use the tracker")
            : const CircularProgressIndicator(),
        ),
      );
    }

    final todayDoses = provider.todayDoses;
    final medications = provider.medications;
    final adherenceByDate = provider.adherenceByDate;

    final morningDoses = todayDoses.where((d) => d.period == DosePeriod.morning).toList();
    final afternoonDoses = todayDoses.where((d) => d.period == DosePeriod.afternoon).toList();
    final nightDoses = todayDoses.where((d) => d.period == DosePeriod.night).toList();

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(selectedIndex: 3),
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await provider.fetchMedications();
              await provider.fetchAdherence();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    isBangla ? 'ওষুধ ট্র্যাকার' : 'Medication Tracker',
                    style: AppText.headerTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBangla
                        ? "আজকের ডোজ এবং আপনার ওষুধের তালিকা সম্পর্কে সচেতন থাকুন।"
                        : "Stay on track with today's doses and your medication list.",
                    style: AppText.subtext,
                  ),
                  const SizedBox(height: 18),
                  AdherenceCalendarCard(
                    adherenceByDate: adherenceByDate,
                    initialMonth: DateTime.now(),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    isBangla ? "আজকের সময়সূচী" : "Today's Schedule",
                    style: AppText.sectionHeading.copyWith(fontSize: 20),
                  ),
                  if (morningDoses.isNotEmpty)
                    _DoseTimelineGroup(
                      label: dosePeriodLabel(DosePeriod.morning, isBangla),
                      doses: morningDoses,
                      onToggle: provider.toggleDoseTaken,
                    ),
                  if (afternoonDoses.isNotEmpty)
                    _DoseTimelineGroup(
                      label: dosePeriodLabel(DosePeriod.afternoon, isBangla),
                      doses: afternoonDoses,
                      onToggle: provider.toggleDoseTaken,
                    ),
                  if (nightDoses.isNotEmpty)
                    _DoseTimelineGroup(
                      label: dosePeriodLabel(DosePeriod.night, isBangla),
                      doses: nightDoses,
                      onToggle: provider.toggleDoseTaken,
                    ),
                  if (todayDoses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          isBangla ? "আজ কোনো ওষুধের ডোজ নেই" : "No medication doses for today",
                          style: AppText.subtext,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    isBangla ? 'আমার ওষুধসমূহ' : 'My Medications',
                    style: AppText.sectionHeading.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  if (medications.isEmpty)
                    Center(
                      child: Text(
                        isBangla ? "কোনো ওষুধ যোগ করা হয়নি" : "No medications added",
                        style: AppText.subtext,
                      ),
                    ),
                  for (final med in medications)
                    MedicationListCard(
                      medication: med,
                      onEdit: () => _openAddMedicationSheet(existing: med),
                      onDelete: () => _deleteMedication(med),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 140,
            child: Material(
              color: DashboardBottomNav.primaryPink,
              shape: const CircleBorder(),
              elevation: 6,
              shadowColor: DashboardBottomNav.primaryPink.withValues(alpha: .4),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openAddMedicationSheet(),
                child: const SizedBox(
                  width: 58,
                  height: 58,
                  child: Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseTimelineGroup extends StatelessWidget {
  final String label;
  final List<ScheduledDose> doses;
  final ValueChanged<ScheduledDose> onToggle;

  const _DoseTimelineGroup({
    required this.label,
    required this.doses,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: DashboardBottomNav.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: DashboardBottomNav.primaryPink,
                  ),
                ),
              ],
            ),
          ),
          for (final dose in doses)
            DoseCard(dose: dose, onToggle: () => onToggle(dose)),
        ],
      ),
    );
  }
}
