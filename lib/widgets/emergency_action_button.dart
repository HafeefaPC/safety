import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmergencyActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  const EmergencyActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  factory EmergencyActionButton.emergency({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return EmergencyActionButton(
      text: text,
      icon: icon,
      backgroundColor: const Color(AppConstants.primaryColorValue),
      textColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  factory EmergencyActionButton.safe({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return EmergencyActionButton(
      text: text,
      icon: icon,
      backgroundColor: const Color(AppConstants.successColorValue),
      textColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  factory EmergencyActionButton.warning({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return EmergencyActionButton(
      text: text,
      icon: icon,
      backgroundColor: const Color(AppConstants.warningColorValue),
      textColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppConstants.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: AppConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
