import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  
  DateTime? _dueDate;
  String _bloodGroup = 'O+';
  final List<String> _selectedConditions = [];

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _commonConditions = [
    'Hypertension',
    'Diabetes',
    'Thyroid disorders',
    'Asthma',
    'None'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 300)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your due date')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.createOrUpdateProfile(
      _nameController.text.trim(),
      int.parse(_ageController.text.trim()),
      _dueDate!.toIso8601String(),
      _bloodGroup,
      _selectedConditions,
      _emergencyPhoneController.text.trim(),
    );

    if (success) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tell us about yourself',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps us customize your pregnancy timeline and assessment model.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _ageController,
                  labelText: 'Age',
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Due Date Selector
                InkWell(
                  onTap: () => _selectDueDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, color: theme.primaryColor),
                            const SizedBox(width: 12),
                            Text(
                              _dueDate == null
                                  ? 'Estimated Due Date'
                                  : 'Due Date: ${dateFormat.format(_dueDate!)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _dueDate == null ? theme.hintColor : theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Blood Group Selector
                DropdownButtonFormField<String>(
                  value: _bloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    prefixIcon: Icon(Icons.water_drop_outlined, color: Colors.teal),
                  ),
                  items: _bloodGroups.map((bg) {
                    return DropdownMenuItem(
                      value: bg,
                      child: Text(bg),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _bloodGroup = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emergencyPhoneController,
                  labelText: 'Emergency Contact Phone',
                  prefixIcon: Icons.contact_phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Please enter a valid emergency contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Medical History (select all that apply)',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _commonConditions.map((condition) {
                    final isSelected = _selectedConditions.contains(condition);
                    return ChoiceChip(
                      label: Text(condition),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (condition == 'None') {
                            _selectedConditions.clear();
                            _selectedConditions.add('None');
                          } else {
                            _selectedConditions.remove('None');
                            if (selected) {
                              _selectedConditions.add(condition);
                            } else {
                              _selectedConditions.remove(condition);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: 'Complete Setup',
                      isLoading: auth.isLoading,
                      onPressed: _saveProfile,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


