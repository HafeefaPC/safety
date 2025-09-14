import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/emergency_action_button.dart';
import '../models/medical_info_model.dart';
import '../services/preferences_service.dart';
import '../utils/constants.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  late MedicalInfoModel _medicalInfo;
  final _formKey = GlobalKey<FormState>();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadMedicalInfo() {
    _medicalInfo = PreferencesService.getMedicalInfo();
    _updateControllers();
  }

  void _updateControllers() {
    _bloodTypeController.text = _medicalInfo.bloodType;
    _allergiesController.text = _medicalInfo.allergies.join(', ');
    _medicationsController.text = _medicalInfo.medications.join(', ');
    _emergencyContactController.text = _medicalInfo.emergencyContact;
    _medicalConditionsController.text = _medicalInfo.medicalConditions;
    _notesController.text = _medicalInfo.notes;
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
    
    if (!_isEditing) {
      _updateControllers();
    }
  }

  Future<void> _saveMedicalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedInfo = MedicalInfoModel(
      bloodType: _bloodTypeController.text.trim(),
      allergies: _allergiesController.text.trim().isEmpty 
          ? [] 
          : _allergiesController.text.trim().split(',').map((e) => e.trim()).toList(),
      medications: _medicationsController.text.trim().isEmpty 
          ? [] 
          : _medicationsController.text.trim().split(',').map((e) => e.trim()).toList(),
      emergencyContact: _emergencyContactController.text.trim(),
      medicalConditions: _medicalConditionsController.text.trim(),
      notes: _notesController.text.trim(),
    );

    await PreferencesService.saveMedicalInfo(updatedInfo);
    setState(() {
      _medicalInfo = updatedInfo;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical information saved successfully'),
          backgroundColor: Color(AppConstants.successColorValue),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Medical Information',
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveMedicalInfo : _toggleEdit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Blood Type
              _buildInfoCard(
                title: 'Blood Type',
                child: TextFormField(
                  controller: _bloodTypeController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    hintText: 'e.g., O+, A-, B+, AB-',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isEditing && value != null && value.isNotEmpty) {
                      final bloodType = value.trim().toUpperCase();
                      if (!RegExp(r'^(A|B|AB|O)[+-]$').hasMatch(bloodType)) {
                        return 'Please enter a valid blood type (e.g., O+, A-, B+, AB-)';
                      }
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Allergies
              _buildInfoCard(
                title: 'Allergies',
                child: TextFormField(
                  controller: _allergiesController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Penicillin, Nuts, Shellfish (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Medications
              _buildInfoCard(
                title: 'Current Medications',
                child: TextFormField(
                  controller: _medicationsController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Metformin, Lisinopril (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Medical Conditions
              _buildInfoCard(
                title: 'Medical Conditions',
                child: TextFormField(
                  controller: _medicalConditionsController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Diabetes, Hypertension, Asthma',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Emergency Contact
              _buildInfoCard(
                title: 'Emergency Contact',
                child: TextFormField(
                  controller: _emergencyContactController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    hintText: 'Name and phone number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Additional Notes
              _buildInfoCard(
                title: 'Additional Notes',
                child: TextFormField(
                  controller: _notesController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    hintText: 'Any other important medical information',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              if (_isEditing) ...[
                EmergencyActionButton.safe(
                  text: 'Save Information',
                  icon: Icons.save,
                  onPressed: _saveMedicalInfo,
                ),
                const SizedBox(height: 8),
                EmergencyActionButton.warning(
                  text: 'Cancel',
                  icon: Icons.cancel,
                  onPressed: _toggleEdit,
                ),
              ] else ...[
                EmergencyActionButton.warning(
                  text: 'Edit Information',
                  icon: Icons.edit,
                  onPressed: _toggleEdit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
