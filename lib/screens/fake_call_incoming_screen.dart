import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';

class FakeCallIncomingScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;

  const FakeCallIncomingScreen({
    super.key,
    required this.callerName,
    required this.callerNumber,
  });

  @override
  State<FakeCallIncomingScreen> createState() => _FakeCallIncomingScreenState();
}

class _FakeCallIncomingScreenState extends State<FakeCallIncomingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startRinging();
    
    // Prevent back button
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _audioPlayer.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  Future<void> _startRinging() async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Try different ringtone paths
      final List<String> ringtonePaths = [
        '/system/media/audio/ringtones/ring.ogg',
        '/system/media/audio/ringtones/ring.mp3',
        '/system/media/audio/ringtones/ring.wav',
        '/system/media/audio/notifications/notification.ogg',
        '/system/media/audio/notifications/notification.mp3',
        '/system/media/audio/alarms/Alarm_Classic.ogg',
        '/system/media/audio/alarms/Alarm_Classic.mp3',
        '/system/media/audio/ui/Effect_Tick.ogg',
        '/system/media/audio/ui/Effect_Tick.mp3',
      ];
      
      bool played = false;
      for (String path in ringtonePaths) {
        try {
          await _audioPlayer.play(DeviceFileSource(path));
          played = true;
          break;
        } catch (e) {
          continue;
        }
      }
      
      if (!played) {
        // If no system sound works, try playing a simple tone
        print('No system sounds available, using fallback');
      }
    } catch (e) {
      print('Error starting ringtone: $e');
    }
  }

  void _answerCall() {
    setState(() {
      _isRinging = false;
    });
    _audioPlayer.stop();
    _pulseController.stop();
    
    // Show call answered screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Call Answered'),
        content: Text('You are now in a call with ${widget.callerName}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to fake call screen
            },
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  void _declineCall() {
    _audioPlayer.stop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Caller Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Caller Avatar with pulse animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isRinging ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(AppConstants.primaryColorValue),
                              boxShadow: _isRinging
                                  ? [
                                      BoxShadow(
                                        color: const Color(AppConstants.primaryColorValue)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                widget.callerName.isNotEmpty 
                                    ? widget.callerName[0].toUpperCase() 
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Caller Name
                    Text(
                      widget.callerName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Caller Number
                    Text(
                      widget.callerNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Call Status
                    if (_isRinging)
                      const Text(
                        'Incoming call...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Action Buttons
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline Button
                      GestureDetector(
                        onTap: _declineCall,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      
                      // Answer Button
                      GestureDetector(
                        onTap: _answerCall,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
