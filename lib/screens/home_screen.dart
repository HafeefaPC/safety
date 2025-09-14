import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../widgets/custom_app_bar.dart';
import '../widgets/emergency_action_button.dart';
import '../widgets/helpline_card.dart';
import '../data/static_helpline_data.dart';
import '../services/telephony_service.dart';
import '../services/audio_service.dart';
import '../services/preferences_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import 'fake_call_screen.dart';
import 'medical_info_screen.dart';
import 'emergency_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  bool _isShakeEnabled = true;
  Timer? _emergencyTimer;
  bool _isEmergencyMode = false;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isSirenPlaying = false;
  late AnimationController _hourglassController;
  late Animation<double> _hourglassAnimation;
  
  // Shake detection variables
  DateTime? _lastShakeTime;
  int _shakeCount = 0;
  static const int _requiredShakes = 3; // Need 3 rapid shakes
  static const Duration _shakeWindow = Duration(seconds: 1); // Within 1 second

  @override
  void initState() {
    super.initState();
    _startShakeDetection();
    _setupHourglassAnimation();
  }

  void _setupHourglassAnimation() {
    _hourglassController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _hourglassAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hourglassController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    _emergencyTimer?.cancel();
    _hourglassController.dispose();
    super.dispose();
  }

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!_isShakeEnabled || _isSirenPlaying) return; // Disable shake detection when siren is playing
      
      // Calculate acceleration magnitude
      final acceleration = event.x.abs() + event.y.abs() + event.z.abs();
      final now = DateTime.now();
      
      // Check if this is a significant shake
      if (acceleration > AppConstants.shakeThreshold * 1.5) {
        // Reset shake count if too much time has passed
        if (_lastShakeTime != null && now.difference(_lastShakeTime!) > _shakeWindow) {
          _shakeCount = 0;
        }
        
        _shakeCount++;
        _lastShakeTime = now;
        
        // Trigger only after required number of rapid shakes
        if (_shakeCount >= _requiredShakes) {
          _onShakeDetected();
          _shakeCount = 0; // Reset after triggering
        }
      }
    });
  }

  void _onShakeDetected() {
    if (!_isShakeEnabled) return;
    
    setState(() {
      _isShakeEnabled = false;
    });
    
    // Reset shake detection variables
    _shakeCount = 0;
    _lastShakeTime = null;
    
    _sendEmergencyLocation();
    
    // Re-enable shake detection after timeout
    Timer(AppConstants.shakeTimeout, () {
      if (mounted) {
        setState(() {
          _isShakeEnabled = true;
        });
      }
    });
  }

  Future<void> _sendEmergencyLocation() async {
    final contacts = PreferencesService.getEmergencyContacts();
    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add emergency contacts first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Request location permission first
    final hasPermission = await LocationService.requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        final shouldOpenSettings = await _showLocationPermissionDialog();
        if (shouldOpenSettings) {
          await LocationService.openLocationSettings();
        }
      }
      return;
    }

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get current location
    final position = await LocationService.getCurrentLocation();
    
    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get current location. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show location details and confirm sending
    final locationConfirmed = await _showLocationDetailsDialog(position);
    if (!locationConfirmed) return;

    // Show loading for SMS sending
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final success = await TelephonyService.sendEmergencyLocationSms();
    
    // Close loading dialog
    if (mounted) Navigator.of(context).pop();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Emergency location sent!' : 'Failed to send location'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _showTimerSettingsDialog() async {
    int selectedMinutes = AppConstants.emergencyCheckInMinutes;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Set Timer Duration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select how long the emergency timer should run:'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeButton('1 min', 1, selectedMinutes, setState, () => selectedMinutes = 1),
                    _buildTimeButton('3 min', 3, selectedMinutes, setState, () => selectedMinutes = 3),
                    _buildTimeButton('5 min', 5, selectedMinutes, setState, () => selectedMinutes = 5),
                    _buildTimeButton('10 min', 10, selectedMinutes, setState, () => selectedMinutes = 10),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  PreferencesService.saveCheckInTimer(selectedMinutes);
                  Navigator.of(context).pop();
                  _startEmergencyTimerWithDuration(selectedMinutes);
                },
                child: const Text('Start Timer'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeButton(String label, int minutes, int selected, StateSetter setState, VoidCallback onTap) {
    final isSelected = minutes == selected;
    return GestureDetector(
      onTap: () {
        onTap();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<bool> _showLocationDetailsDialog(dynamic position) async {
    final latitude = position.latitude;
    final longitude = position.longitude;
    final mapsUrl = LocationService.generateGoogleMapsUrl(latitude, longitude);
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your current location:'),
            const SizedBox(height: 8),
            Text('Latitude: ${latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 8),
            const Text('This location will be sent to your emergency contacts.'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Open maps to show location
                // You can implement this if needed
              },
              child: const Text('View on Map'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send Location'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _sendSafeMessage() async {
    final contacts = PreferencesService.getEmergencyContacts();
    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add emergency contacts first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final success = await TelephonyService.sendSafeMessage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Safe message sent!' : 'Failed to send message'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _startEmergencyTimer() {
    if (_isEmergencyMode) return;
    
    final contacts = PreferencesService.getEmergencyContacts();
    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add emergency contacts first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Show timer settings dialog
    _showTimerSettingsDialog();
  }

  void _startEmergencyTimerWithDuration(int minutes) {
    if (_isEmergencyMode) return;
    
    setState(() {
      _isEmergencyMode = true;
      _remainingSeconds = minutes * 60;
      _totalSeconds = minutes * 60;
    });
    
    // Start hourglass animation
    _hourglassController.repeat();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Emergency timer started! You have $minutes minutes to stop it.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    
    // Start countdown timer
    _emergencyTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
          
          if (_remainingSeconds <= 0) {
            timer.cancel();
            _sendEmergencyTimeoutMessage();
            setState(() {
              _isEmergencyMode = false;
            });
            _hourglassController.stop();
          }
        }
      },
    );
  }

  Future<void> _sendEmergencyTimeoutMessage() async {
    final contacts = PreferencesService.getEmergencyContacts();
    if (contacts.isEmpty) return;

    // Send custom timeout message
    final success = await TelephonyService.sendCustomSms(
      'EMERGENCY! I have not checked in within the specified time. Please contact me immediately and check my location. I may need help!'
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Emergency timeout message sent!' : 'Failed to send timeout message'),
          backgroundColor: success ? Colors.red : Colors.orange,
        ),
      );
    }
  }

  void _stopEmergencyTimer() {
    _emergencyTimer?.cancel();
    _hourglassController.stop();
    setState(() {
      _isEmergencyMode = false;
      _remainingSeconds = 0;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency timer stopped!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _playSiren() async {
    if (_isSirenPlaying) {
      // If siren is already playing, stop it
      await AudioService.stopSiren();
      setState(() {
        _isSirenPlaying = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Siren stopped!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Start playing siren
      final success = await AudioService.playSiren();
      setState(() {
        _isSirenPlaying = success;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Siren started! Tap again to stop.' : 'Failed to play siren'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToFakeCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FakeCallScreen(),
      ),
    );
  }

  void _navigateToMedicalInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicalInfoScreen(),
      ),
    );
  }

  void _navigateToEmergencyContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyContactsScreen(),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<bool> _showLocationPermissionDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to send your current location in emergencies. '
          'Would you like to open settings to enable location permission?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppConstants.appName,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency Actions
            Card(
              elevation: AppConstants.cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    const Text(
                      'Emergency Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Timer Status Indicator with Countdown
                    if (_isEmergencyMode)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Animated Hourglass
                                AnimatedBuilder(
                                  animation: _hourglassAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _hourglassAnimation.value * 6.28, // 2π radians
                                      child: const Icon(
                                        Icons.hourglass_empty,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    const Text(
                                      'Emergency Timer Active!',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(_remainingSeconds),
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Progress bar
                            LinearProgressIndicator(
                              value: _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0,
                              backgroundColor: Colors.red.withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ],
                        ),
                      ),
                    EmergencyActionButton.emergency(
                      text: 'Send Location',
                      icon: Icons.location_on,
                      onPressed: _sendEmergencyLocation,
                    ),
                    const SizedBox(height: 8),
                    EmergencyActionButton.safe(
                      text: "I'm Safe",
                      icon: Icons.check_circle,
                      onPressed: _sendSafeMessage,
                    ),
                    const SizedBox(height: 8),
                    EmergencyActionButton.warning(
                      text: _isEmergencyMode ? 'Stop Timer' : 'Start Check-in Timer',
                      icon: _isEmergencyMode ? Icons.stop : Icons.timer,
                      onPressed: _isEmergencyMode ? _stopEmergencyTimer : _startEmergencyTimer,
                    ),
                    const SizedBox(height: 8),
                    EmergencyActionButton.emergency(
                      text: _isSirenPlaying ? 'Stop Siren' : 'Play Siren',
                      icon: _isSirenPlaying ? Icons.volume_off : Icons.volume_up,
                      onPressed: _playSiren,
                    ),
                    const SizedBox(height: 8),
                    EmergencyActionButton.warning(
                      text: 'Fake Call',
                      icon: Icons.phone,
                      onPressed: _navigateToFakeCall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Access
            Card(
              elevation: AppConstants.cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: EmergencyActionButton.warning(
                            text: 'Medical Info',
                            icon: Icons.medical_services,
                            onPressed: _navigateToMedicalInfo,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: EmergencyActionButton.warning(
                            text: 'Contacts',
                            icon: Icons.contacts,
                            onPressed: _navigateToEmergencyContacts,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Helpline Numbers
            const Text(
              'Emergency Helplines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Emergency Category
            ...StaticHelplineData.getHelplinesByCategory('Emergency')
                .map((helpline) => HelplineCard(helpline: helpline)),
            
            // Women Safety Category
            ...StaticHelplineData.getHelplinesByCategory('Women Safety')
                .map((helpline) => HelplineCard(helpline: helpline)),
            
            // Other Categories
            ...StaticHelplineData.getHelplinesByCategory('Mental Health')
                .map((helpline) => HelplineCard(helpline: helpline)),
          ],
        ),
      ),
    );
  }
}
