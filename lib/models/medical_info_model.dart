class MedicalInfoModel {
  final String bloodType;
  final List<String> allergies;
  final List<String> medications;
  final String emergencyContact;
  final String medicalConditions;
  final String notes;

  const MedicalInfoModel({
    required this.bloodType,
    required this.allergies,
    required this.medications,
    required this.emergencyContact,
    required this.medicalConditions,
    required this.notes,
  });

  factory MedicalInfoModel.empty() {
    return const MedicalInfoModel(
      bloodType: '',
      allergies: [],
      medications: [],
      emergencyContact: '',
      medicalConditions: '',
      notes: '',
    );
  }

  factory MedicalInfoModel.fromJson(Map<String, dynamic> json) {
    return MedicalInfoModel(
      bloodType: json['bloodType'] as String? ?? '',
      allergies: List<String>.from(json['allergies'] as List? ?? []),
      medications: List<String>.from(json['medications'] as List? ?? []),
      emergencyContact: json['emergencyContact'] as String? ?? '',
      medicalConditions: json['medicalConditions'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'emergencyContact': emergencyContact,
      'medicalConditions': medicalConditions,
      'notes': notes,
    };
  }

  MedicalInfoModel copyWith({
    String? bloodType,
    List<String>? allergies,
    List<String>? medications,
    String? emergencyContact,
    String? medicalConditions,
    String? notes,
  }) {
    return MedicalInfoModel(
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'MedicalInfoModel(bloodType: $bloodType, allergies: $allergies, medications: $medications)';
  }
}
