import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_info_model.dart';
import '../utils/constants.dart';

class PreferencesService {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Emergency Contacts
  static Future<void> saveEmergencyContacts(List<String> contacts) async {
    await prefs.setStringList(AppConstants.emergencyContactsKey, contacts);
  }
  
  static List<String> getEmergencyContacts() {
    return prefs.getStringList(AppConstants.emergencyContactsKey) ?? [];
  }
  
  // Medical Information
  static Future<void> saveMedicalInfo(MedicalInfoModel medicalInfo) async {
    final jsonString = jsonEncode(medicalInfo.toJson());
    await prefs.setString(AppConstants.medicalInfoKey, jsonString);
  }
  
  static MedicalInfoModel getMedicalInfo() {
    final jsonString = prefs.getString(AppConstants.medicalInfoKey);
    if (jsonString == null) {
      return MedicalInfoModel.empty();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return MedicalInfoModel.fromJson(json);
    } catch (e) {
      return MedicalInfoModel.empty();
    }
  }
  
  // Check-in Timer
  static Future<void> saveCheckInTimer(int minutes) async {
    await prefs.setInt(AppConstants.checkInTimerKey, minutes);
  }
  
  static int getCheckInTimer() {
    return prefs.getInt(AppConstants.checkInTimerKey) ?? AppConstants.emergencyCheckInMinutes;
  }
  
  // Generic String Storage
  static Future<void> saveString(String key, String value) async {
    await prefs.setString(key, value);
  }
  
  static String? getString(String key) {
    return prefs.getString(key);
  }
  
  // Generic Bool Storage
  static Future<void> saveBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }
  
  // Clear all data
  static Future<void> clearAll() async {
    await prefs.clear();
  }
  
  // Clear specific key
  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }
}
