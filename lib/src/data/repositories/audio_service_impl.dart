import 'package:audioplayers/audioplayers.dart';
import '../../domain/repositories/audio_service.dart';

class AudioServiceImpl implements AudioService {
  final AudioPlayer _audioPlayer;
  bool _isMuted = false;
  
  // Audio file paths
  static const String _correctSoundPath = 'audio/correct.mp3';
  static const String _incorrectSoundPath = 'audio/wrong.mp3';
  static const String _timeoutSoundPath = 'audio/timeout.mp3';

  AudioServiceImpl({AudioPlayer? audioPlayer}) 
      : _audioPlayer = audioPlayer ?? AudioPlayer() {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    // Configure audio player settings
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    
    // Handle audio interruptions (calls, other apps)
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        // Audio finished playing or was interrupted
        _handleAudioCompletion();
      }
    });
  }

  @override
  bool get isMuted => _isMuted;

  @override
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    
    if (_isMuted) {
      // Stop any currently playing audio
      await _audioPlayer.stop();
    }
  }

  @override
  Future<void> playCorrectSound() async {
    await _playSound(_correctSoundPath);
  }

  @override
  Future<void> playIncorrectSound() async {
    await _playSound(_incorrectSoundPath);
  }

  @override
  Future<void> playTimeoutSound() async {
    await _playSound(_timeoutSoundPath);
  }

  Future<void> _playSound(String soundPath) async {
    if (_isMuted) {
      return; // Don't play if muted
    }

    try {
      // Stop any currently playing sound
      await _audioPlayer.stop();
      
      // Play the new sound
      await _audioPlayer.play(AssetSource(soundPath));
      
      // Set a timeout to ensure sound doesn't play longer than 2 seconds
      Future.delayed(const Duration(seconds: 2), () async {
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.stop();
        }
      });
    } catch (e) {
      // Handle audio playback errors gracefully
      // In production, you might want to log this error
      print('Audio playback error: $e');
    }
  }

  void _handleAudioCompletion() {
    // Handle any cleanup needed when audio completes
    // This could include notifying listeners or updating UI state
  }

  /// Preload audio files for better performance
  Future<void> preloadAudioFiles() async {
    if (_isMuted) return;

    try {
      // Preload all sound files
      final sounds = [_correctSoundPath, _incorrectSoundPath, _timeoutSoundPath];
      
      for (final soundPath in sounds) {
        // Create a temporary player to preload
        final tempPlayer = AudioPlayer();
        await tempPlayer.setSource(AssetSource(soundPath));
        await tempPlayer.dispose();
      }
    } catch (e) {
      // Handle preload errors gracefully
      print('Audio preload error: $e');
    }
  }

  /// Test audio functionality
  Future<bool> testAudioPlayback() async {
    if (_isMuted) return true;

    try {
      await _audioPlayer.play(AssetSource(_correctSoundPath));
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.stop();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Set volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Volume setting error: $e');
    }
  }

  /// Get current volume level
  Future<double> getVolume() async {
    try {
      // AudioPlayer doesn't have a direct getVolume method
      // Return a default value or maintain volume state
      return 1.0;
    } catch (e) {
      return 1.0;
    }
  }

  /// Dispose of audio resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    } catch (e) {
      print('Audio disposal error: $e');
    }
  }

  /// Handle system audio focus changes
  void handleAudioFocusChange(bool hasFocus) {
    if (!hasFocus) {
      // Pause or stop audio when losing focus
      _audioPlayer.stop();
    }
  }

  /// Check if audio is currently playing
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  /// Stop any currently playing audio
  Future<void> stopCurrentAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Stop audio error: $e');
    }
  }
}