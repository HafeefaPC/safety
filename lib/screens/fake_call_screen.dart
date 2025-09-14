import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/emergency_action_button.dart';
import '../utils/constants.dart';
import 'fake_call_incoming_screen.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isCallActive = false;
  String _callerName = 'Unknown Caller';
  String _callerNumber = '+1 234 567 8900';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
  }

  Future<void> _scheduleFakeCall() async {
    if (_isCallActive) return;

    setState(() {
      _isCallActive = true;
    });

    // Schedule notification after delay
    await Future.delayed(const Duration(seconds: AppConstants.fakeCallDelaySeconds));
    
    if (!mounted) return;

    await _showFakeCallNotification();
    
    // Navigate to a fake call screen that plays ringtone
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FakeCallIncomingScreen(
            callerName: _callerName,
            callerNumber: _callerNumber,
          ),
        ),
      );
    }
  }

  Future<void> _showFakeCallNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'fake_call_channel',
      'Fake Call Notifications',
      channelDescription: 'Notifications for fake incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Incoming Call',
      '$_callerName ($_callerNumber)',
      details,
    );
  }

  void _endFakeCall() {
    setState(() {
      _isCallActive = false;
    });
    _notifications.cancel(1);
  }

  void _changeCallerInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Caller Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Caller Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _callerName = value,
              controller: TextEditingController(text: _callerName),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Caller Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _callerNumber = value,
              controller: TextEditingController(text: _callerNumber),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fake Call',
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Caller Information Card
            Card(
              elevation: AppConstants.cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    const Text(
                      'Caller Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(AppConstants.primaryColorValue),
                      child: Text(
                        _callerName.isNotEmpty ? _callerName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _callerName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _callerNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    EmergencyActionButton.warning(
                      text: 'Change Caller Info',
                      icon: Icons.edit,
                      onPressed: _changeCallerInfo,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Call Status
            if (_isCallActive)
              Card(
                elevation: AppConstants.cardElevation,
                color: Colors.green.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.phone_in_talk,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Fake Call Scheduled',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Call will appear in ${AppConstants.fakeCallDelaySeconds} seconds',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            EmergencyActionButton.emergency(
              text: _isCallActive ? 'Cancel Call' : 'Schedule Fake Call',
              icon: _isCallActive ? Icons.call_end : Icons.phone,
              onPressed: _isCallActive ? _endFakeCall : _scheduleFakeCall,
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Card(
              elevation: AppConstants.cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Set the caller name and number\n'
                      '• Tap "Schedule Fake Call" to start\n'
                      '• The fake call will appear as a notification\n'
                      '• This is for safety purposes only',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
