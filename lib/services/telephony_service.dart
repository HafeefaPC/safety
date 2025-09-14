import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../services/preferences_service.dart';
import '../utils/constants.dart';

class TelephonyService {
  
  static Future<bool> sendSms(String phoneNumber, String message) async {
    try {
      // Try different SMS URI formats
      Uri smsUri;
      
      // First try with sms: scheme
      smsUri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
      
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      }
      
      // If that doesn't work, try with smsto: scheme
      smsUri = Uri.parse('smsto:$phoneNumber?body=${Uri.encodeComponent(message)}');
      
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      }
      
      // If that doesn't work, try without body
      smsUri = Uri.parse('sms:$phoneNumber');
      
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> sendEmergencyLocationSms() async {
    try {
      final contacts = PreferencesService.getEmergencyContacts();
      print('Emergency contacts: $contacts');
      if (contacts.isEmpty) {
        print('No emergency contacts found');
        return false;
      }
      
      final locationMessage = await LocationService.getLocationMessage();
      print('Location message: $locationMessage');
      if (locationMessage == null) {
        print('Failed to get location message');
        return false;
      }
      
      bool allSent = true;
      for (final contact in contacts) {
        print('Sending SMS to: $contact');
        final sent = await sendSms(contact, locationMessage);
        print('SMS sent to $contact: $sent');
        if (!sent) {
          allSent = false;
        }
      }
      
      print('All SMS sent: $allSent');
      return allSent;
    } catch (e) {
      print('Error in sendEmergencyLocationSms: $e');
      return false;
    }
  }
  
  static Future<bool> sendSafeMessage() async {
    try {
      final contacts = PreferencesService.getEmergencyContacts();
      if (contacts.isEmpty) {
        return false;
      }
      
      bool allSent = true;
      for (final contact in contacts) {
        final sent = await sendSms(contact, AppConstants.safeMessage);
        if (!sent) {
          allSent = false;
        }
      }
      
      return allSent;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> sendCustomSms(String message) async {
    try {
      final contacts = PreferencesService.getEmergencyContacts();
      if (contacts.isEmpty) {
        return false;
      }
      
      bool allSent = true;
      for (final contact in contacts) {
        final sent = await sendSms(contact, message);
        if (!sent) {
          allSent = false;
        }
      }
      
      return allSent;
    } catch (e) {
      return false;
    }
  }
  
  static bool isValidPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10;
  }
  
  static String formatPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly;
  }
}
