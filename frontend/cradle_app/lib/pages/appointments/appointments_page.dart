import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  List<dynamic> _appointments = [];
  List<dynamic> _reminders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apptRes = await ApiService.getAppointments();
      final remRes = await ApiService.getMedicationReminders();
      
      setState(() {
        _appointments = apptRes['success'] == true ? apptRes['data'] : [];
        _reminders = remRes['success'] == true ? remRes['data'] : [];
      });
    } catch (_) {}

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showAddAppointmentDialog() async {
    final doctorController = TextEditingController();
    final clinicController = TextEditingController();
    final purposeController = TextEditingController();
    DateTime? selectedDateTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Appointment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: doctorController,
                      labelText: 'Doctor Name',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: clinicController,
                      labelText: 'Clinic Name',
                      prefixIcon: Icons.local_hospital_outlined,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: purposeController,
                      labelText: 'Purpose',
                      prefixIcon: Icons.info_outline,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      title: Text(
                        selectedDateTime == null
                            ? 'Select Date & Time'
                            : DateFormat('yyyy-MM-dd hh:mm a').format(selectedDateTime!),
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          if (!context.mounted) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (doctorController.text.trim().isEmpty || selectedDateTime == null) {
                      return;
                    }
                    final apptData = {
                      'doctorName': doctorController.text.trim(),
                      'clinicName': clinicController.text.trim(),
                      'purpose': purposeController.text.trim(),
                      'dateTime': selectedDateTime!.toIso8601String(),
                    };
                    final res = await ApiService.createAppointment(apptData);
                    if (res['success'] == true) {
                      _loadData();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddReminderDialog() async {
    final medController = TextEditingController();
    final dosageController = TextEditingController();
    final timeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Medication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: medController,
                labelText: 'Medication Name',
                prefixIcon: Icons.medication_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: dosageController,
                labelText: 'Dosage (e.g. 1 pill)',
                prefixIcon: Icons.science_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: timeController,
                labelText: 'Time of Day (e.g. 08:00)',
                prefixIcon: Icons.alarm_outlined,
                hintText: 'HH:MM format',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (medController.text.trim().isEmpty || timeController.text.trim().isEmpty) {
                  return;
                }
                final reminderData = {
                  'medicationName': medController.text.trim(),
                  'dosage': dosageController.text.trim(),
                  'timeOfDay': [timeController.text.trim()],
                };
                final res = await ApiService.createMedicationReminder(reminderData);
                if (res['success'] == true) {
                  _loadData();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments & Meds'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Appointments', icon: Icon(Icons.calendar_today_rounded)),
            Tab(text: 'Medications', icon: Icon(Icons.medication_rounded)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsTab(),
                _buildMedicationsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddAppointmentDialog();
          } else {
            _showAddReminderDialog();
          }
        },
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_appointments.isEmpty) {
      return const Center(child: Text('No upcoming appointments.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appt = _appointments[index];
        final DateTime dateTime = DateTime.tryParse(appt['dateTime'] ?? '') ?? DateTime.now();
        final doctor = appt['doctorName'] ?? 'Unknown Doctor';
        final clinic = appt['clinicName'] ?? '';
        final purpose = appt['purpose'] ?? '';
        final status = appt['status'] ?? 'SCHEDULED';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              foregroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person_rounded),
            ),
            title: Text(doctor, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (clinic.isNotEmpty) Text(clinic),
                if (purpose.isNotEmpty) Text('Purpose: $purpose', style: const TextStyle(fontSize: 12)),
                Text(
                  DateFormat('EEE, MMM dd • hh:mm a').format(dateTime),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicationsTab() {
    if (_reminders.isEmpty) {
      return const Center(child: Text('No active medication reminders.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final rem = _reminders[index];
        final name = rem['medicationName'] ?? '';
        final dosage = rem['dosage'] ?? '';
        final times = rem['timeOfDay'] as List? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade50,
              foregroundColor: Colors.indigo,
              child: const Icon(Icons.medication_rounded),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Dosage: $dosage • Time: ${times.join(', ')}',
              style: const TextStyle(fontSize: 13),
            ),
            trailing: const Icon(Icons.alarm_on, color: Colors.indigo),
          ),
        );
      },
    );
  }
}


