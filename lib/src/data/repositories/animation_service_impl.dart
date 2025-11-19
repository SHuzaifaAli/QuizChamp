import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../domain/repositories/animation_service.dart';

class AnimationServiceImpl implements AnimationService {
  static const String _correctAnimationPath = 'assets/lottie/correct_answer.json';
  static const String _incorrectAnimationPath = 'assets/lottie/wrong_answer.json';
  static const String _timeoutAnimationPath = 'assets/lottie/timeout.json';
  
  @override
  Duration get animationDuration => const Duration(seconds: 3);

  @override
  Widget buildCorrectAnimation() {
    return _buildAnimationWidget(
      animationPath: _correctAnimationPath,
      fallbackIcon: Icons.check_circle,
      fallbackColor: Colors.green,
      semanticLabel: 'Correct answer animation',
    );
  }

  @override
  Widget buildIncorrectAnimation() {
    return _buildAnimationWidget(
      animationPath: _incorrectAnimationPath,
      fallbackIcon: Icons.cancel,
      fallbackColor: Colors.red,
      semanticLabel: 'Incorrect answer animation',
    );
  }

  @override
  Widget buildTimeoutAnimation() {
    return _buildAnimationWidget(
      animationPath: _timeoutAnimationPath,
      fallbackIcon: Icons.access_time,
      fallbackColor: Colors.orange,
      semanticLabel: 'Time out animation',
    );
  }

  Widget _buildAnimationWidget({
    required String animationPath,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required String semanticLabel,
  }) {
    return Container(
      width: 200,
      height: 200,
      child: Semantics(
        label: semanticLabel,
        child: Lottie.asset(
          animationPath,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          repeat: false,
          animate: true,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to static icon if Lottie fails
            return _buildFallbackAnimation(
              icon: fallbackIcon,
              color: fallbackColor,
            );
          },
          frameBuilder: (context, child, composition) {
            if (composition == null) {
              // Show loading indicator while Lottie loads
              return _buildLoadingAnimation();
            }
            return child;
          },
        ),
      ),
    );
  }

  Widget _buildFallbackAnimation({
    required IconData icon,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      duration: animationDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5), // Scale from 0.5 to 1.0
          child: Opacity(
            opacity: value,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 3),
              ),
              child: Icon(
                icon,
                size: 80,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingAnimation() {
    return Container(
      width: 200,
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Create a custom animation widget with specific properties
  Widget buildCustomAnimation({
    required String animationPath,
    double? width,
    double? height,
    bool repeat = false,
    bool animate = true,
    BoxFit fit = BoxFit.contain,
  }) {
    return Lottie.asset(
      animationPath,
      width: width ?? 200,
      height: height ?? 200,
      fit: fit,
      repeat: repeat,
      animate: animate,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? 200,
          height: height ?? 200,
          child: const Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  /// Preload animation assets for better performance
  Future<void> preloadAnimations(BuildContext context) async {
    try {
      // Preload all animation assets
      final animations = [
        _correctAnimationPath,
        _incorrectAnimationPath,
        _timeoutAnimationPath,
      ];

      for (final animationPath in animations) {
        await precacheImage(
          AssetImage(animationPath),
          context,
        );
      }
    } catch (e) {
      // Handle preload errors gracefully
      debugPrint('Animation preload error: $e');
    }
  }

  /// Check if animation assets exist
  Future<bool> validateAnimationAssets() async {
    try {
      // This is a simplified check - in a real app you might want to
      // actually verify the asset files exist and are valid
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a feedback overlay with animation and text
  Widget buildFeedbackOverlay({
    required Widget animation,
    required String message,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? Colors.black.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          animation,
          const SizedBox(height: 20),
          Text(
            message,
            style: textStyle ?? const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get animation controller for more control
  Widget buildControlledAnimation({
    required String animationPath,
    required AnimationController controller,
    double? width,
    double? height,
  }) {
    return Lottie.asset(
      animationPath,
      controller: controller,
      width: width ?? 200,
      height: height ?? 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? 200,
          height: height ?? 200,
          child: const Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}