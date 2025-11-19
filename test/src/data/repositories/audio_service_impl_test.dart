import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_champ/src/data/repositories/audio_service_impl.dart';

import 'audio_service_impl_test.mocks.dart';

@GenerateMocks([AudioPlayer])
void main() {
  group('AudioServiceImpl', () {
    late AudioServiceImpl audioService;
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();
      audioService = AudioServiceImpl(audioPlayer: mockAudioPlayer);
    });

    group('Mute functionality', () {
      test('should start unmuted by default', () {
        expect(audioService.isMuted, false);
      });

      test('should set muted state correctly', () async {
        await audioService.setMuted(true);
        expect(audioService.isMuted, true);

        await audioService.setMuted(false);
        expect(audioService.isMuted, false);
      });

      test('should stop audio when muted', () async {
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});

        await audioService.setMuted(true);

        verify(mockAudioPlayer.stop()).called(1);
      });
    });

    group('Sound playback', () {
      setUp(() {
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});
        when(mockAudioPlayer.play(any)).thenAnswer((_) async {});
        when(mockAudioPlayer.setReleaseMode(any)).thenReturn(null);
      });

      test('should play correct sound when not muted', () async {
        await audioService.playCorrectSound();

        verify(mockAudioPlayer.stop()).called(1);
        verify(mockAudioPlayer.play(any)).called(1);
      });

      test('should play incorrect sound when not muted', () async {
        await audioService.playIncorrectSound();

        verify(mockAudioPlayer.stop()).called(1);
        verify(mockAudioPlayer.play(any)).called(1);
      });

      test('should play timeout sound when not muted', () async {
        await audioService.playTimeoutSound();

        verify(mockAudioPlayer.stop()).called(1);
        verify(mockAudioPlayer.play(any)).called(1);
      });

      test('should not play sound when muted', () async {
        await audioService.setMuted(true);
        clearInteractions(mockAudioPlayer);

        await audioService.playCorrectSound();
        await audioService.playIncorrectSound();
        await audioService.playTimeoutSound();

        verifyNever(mockAudioPlayer.play(any));
      });

      test('should stop current audio before playing new sound', () async {
        await audioService.playCorrectSound();

        verify(mockAudioPlayer.stop()).called(1);
        verify(mockAudioPlayer.play(any)).called(1);
      });
    });

    group('Volume control', () {
      setUp(() {
        when(mockAudioPlayer.setVolume(any)).thenAnswer((_) async {});
      });

      test('should set volume within valid range', () async {
        await audioService.setVolume(0.5);
        verify(mockAudioPlayer.setVolume(0.5)).called(1);

        await audioService.setVolume(0.0);
        verify(mockAudioPlayer.setVolume(0.0)).called(1);

        await audioService.setVolume(1.0);
        verify(mockAudioPlayer.setVolume(1.0)).called(1);
      });

      test('should clamp volume to valid range', () async {
        await audioService.setVolume(-0.5);
        verify(mockAudioPlayer.setVolume(0.0)).called(1);

        await audioService.setVolume(1.5);
        verify(mockAudioPlayer.setVolume(1.0)).called(1);
      });

      test('should return default volume when getting volume', () async {
        final volume = await audioService.getVolume();
        expect(volume, 1.0);
      });
    });

    group('Audio player state', () {
      test('should return false for isPlaying when not playing', () {
        when(mockAudioPlayer.state).thenReturn(PlayerState.stopped);
        expect(audioService.isPlaying, false);
      });

      test('should return true for isPlaying when playing', () {
        when(mockAudioPlayer.state).thenReturn(PlayerState.playing);
        expect(audioService.isPlaying, true);
      });

      test('should stop current audio', () async {
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});

        await audioService.stopCurrentAudio();

        verify(mockAudioPlayer.stop()).called(1);
      });
    });

    group('Audio focus handling', () {
      test('should stop audio when losing focus', () {
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});

        audioService.handleAudioFocusChange(false);

        verify(mockAudioPlayer.stop()).called(1);
      });

      test('should not stop audio when gaining focus', () {
        audioService.handleAudioFocusChange(true);

        verifyNever(mockAudioPlayer.stop());
      });
    });

    group('Resource management', () {
      test('should dispose audio player resources', () async {
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});
        when(mockAudioPlayer.dispose()).thenAnswer((_) async {});

        await audioService.dispose();

        verify(mockAudioPlayer.stop()).called(1);
        verify(mockAudioPlayer.dispose()).called(1);
      });
    });

    group('Error handling', () {
      test('should handle playback errors gracefully', () async {
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});
        when(mockAudioPlayer.play(any)).thenThrow(Exception('Playback error'));

        // Should not throw exception
        expect(() => audioService.playCorrectSound(), returnsNormally);
      });

      test('should handle volume setting errors gracefully', () async {
        when(mockAudioPlayer.setVolume(any)).thenThrow(Exception('Volume error'));

        // Should not throw exception
        expect(() => audioService.setVolume(0.5), returnsNormally);
      });

      test('should handle disposal errors gracefully', () async {
        when(mockAudioPlayer.stop()).thenThrow(Exception('Stop error'));
        when(mockAudioPlayer.dispose()).thenThrow(Exception('Dispose error'));

        // Should not throw exception
        expect(() => audioService.dispose(), returnsNormally);
      });
    });

    group('Audio testing', () {
      test('should return true for successful audio test when not muted', () async {
        when(mockAudioPlayer.play(any)).thenAnswer((_) async {});
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});

        final result = await audioService.testAudioPlayback();

        expect(result, true);
        verify(mockAudioPlayer.play(any)).called(1);
        verify(mockAudioPlayer.stop()).called(1);
      });

      test('should return true for audio test when muted', () async {
        await audioService.setMuted(true);

        final result = await audioService.testAudioPlayback();

        expect(result, true);
        verifyNever(mockAudioPlayer.play(any));
      });

      test('should return false for failed audio test', () async {
        when(mockAudioPlayer.play(any)).thenThrow(Exception('Test error'));

        final result = await audioService.testAudioPlayback();

        expect(result, false);
      });
    });
  });
}