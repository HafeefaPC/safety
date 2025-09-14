import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;
  static Timer? _vibrationTimer;
  
  static Future<bool> requestAudioPermission() async {
    final status = await Permission.audio.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> isAudioPermissionGranted() async {
    final status = await Permission.audio.status;
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> playSiren() async {
    try {
      if (_isPlaying) {
        return true; // Already playing
      }
      
      _isPlaying = true;
      
      // Set maximum volume and loop mode
      await _audioPlayer.setVolume(1.0); // Maximum volume
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Use vibration as primary siren method since audio sources are unreliable
      _startVibrationPattern();
      
      // Try to play a simple system sound (optional)
      final List<String> audioSources = [
        '/system/media/audio/notifications/notification.ogg',
        '/system/media/audio/ui/Effect_Tick.ogg',
      ];
      
      // Try to play audio (optional, vibration is primary)
      for (String source in audioSources) {
        try {
          await _audioPlayer.play(DeviceFileSource(source));
          print('Successfully playing siren from: $source');
          break;
        } catch (e) {
          print('Failed to play from $source: $e');
          continue;
        }
      }
      
      return true;
    } catch (e) {
      print('Error playing siren: $e');
      _isPlaying = false;
      return false;
    }
  }
  
  static void _startVibrationPattern() {
    _vibrationTimer?.cancel();
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isPlaying) {
        HapticFeedback.heavyImpact();
      } else {
        timer.cancel();
      }
    });
  }
  
  static Future<void> stopSiren() async {
    try {
      // Stop audio
      await _audioPlayer.stop();
      
      // Stop vibration
      _vibrationTimer?.cancel();
      
      // Reset state
      _isPlaying = false;
      
      print('Siren stopped successfully');
    } catch (e) {
      print('Error stopping siren: $e');
      _isPlaying = false;
    }
  }
  
  static bool get isPlaying => _isPlaying;
  
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
    _isPlaying = false;
  }
  
  static Future<bool> playBeep() async {
    try {
      if (!await isAudioPermissionGranted()) {
        final granted = await requestAudioPermission();
        if (!granted) {
          return false;
        }
      }
      
      // Play a short beep sound
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Use system notification sound
      await _audioPlayer.play(DeviceFileSource('/system/media/audio/notifications/notification.ogg'));
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
