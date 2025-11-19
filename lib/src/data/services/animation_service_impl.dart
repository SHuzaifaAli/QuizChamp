import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_champ/src/domain/repositories/animation_service.dart';

class AnimationServiceImpl implements AnimationService {
  static const String correctAnimationPath = 'assets/lottie/correct_answer.json';
  static const String incorrectAnimationPath = 'assets/lottie/wrong_answer.json';
  static const String timeoutAnimationPath = 'assets/lottie/wrong_answer.json'; // Using wrong animation for timeout

  @override
  Duration get animationDuration => const Duration(seconds: 3);

  @override
  Widget buildCorrectAnimation() {
    return _buildAnimationWidget(
      animationPath: correctAnimationPath,
      fallbackIcon: Icons.check_circle,
      fallbackColor: Colors.green,
    );
  }

  @override
  Widget buildIncorrectAnimation() {
    return _buildAnimationWidget(
      animationPath: incorrectAnimationPath,
      fallbackIcon: Icons.cancel,
      fallbackColor: Colors.red,
    );
  }

  @override
  Widget buildTimeoutAnimation() {
    return _buildAnimationWidget(
      animationPath: timeoutAnimationPath,
      fallbackIcon: Icons.access_time,
      fallbackColor: Colors.orange,
    );
  }

  Widget _buildAnimationWidget({
    required String animationPath,
    required IconData fallbackIcon,
    required Color fallbackColor,
  }) {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lottie animation with fallback
          _buildLottieWithFallback(
            animationPath: animationPath,
            fallbackIcon: fallbackIcon,
            fallbackColor: fallbackColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLottieWithFallback({
    required String animationPath,
    required IconData fallbackIcon,
    required Color fallbackColor,
  }) {
    return FutureBuilder<bool>(
      future: _checkAssetExists(animationPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Lottie.asset(
            animationPath,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            repeat: false,
            animate: true,
            onLoaded: (composition) {
              // Animation loaded successfully
            },
            errorBuilder: (context, error, stackTrace) {
              // Fallback to static icon if Lottie fails
              return _buildFallbackIcon(fallbackIcon, fallbackColor);
            },
          );
        } else {
          // Asset doesn't exist, use fallback
          return _buildFallbackIcon(fallbackIcon, fallbackColor);
        }
      },
    );
  }

  Widget _buildFallbackIcon(IconData icon, Color color) {
    return AnimatedContainer(
      duration: animationDuration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Icon(
                  icon,
                  size: 120,
                  color: color.withOpacity(value),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(
                  width: 100 * value,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<bool> _checkAssetExists(String assetPath) async {
    try {
      // This is a simple check - in a real app you might want to use
      // a more sophisticated asset existence check
      await Future.delayed(const Duration(milliseconds: 100));
      return true; // Assume assets exist for now
    } catch (e) {
      return false;
    }
  }
}