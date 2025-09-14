import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> canMakePhoneCall() async {
    try {
      final Uri testUri = Uri(scheme: 'tel', path: '1234567890');
      return await canLaunchUrl(testUri);
    } catch (e) {
      return false;
    }
  }
  
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // If it starts with country code, keep it as is
    if (digitsOnly.length > 10) {
      return digitsOnly;
    }
    
    // If it's a 10-digit number, assume it's a local number
    if (digitsOnly.length == 10) {
      return digitsOnly;
    }
    
    // Return as is for other cases
    return phoneNumber;
  }
  
  static bool isValidPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10;
  }
}
