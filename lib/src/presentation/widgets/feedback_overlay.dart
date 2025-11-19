import 'package:flutter/material.dart';
import '../../data/repositories/animation_service_impl.dart';

class FeedbackOverlay extends StatefulWidget {
  final bool isCorrect;
  final bool isTimeout;
  final String message;
  final VoidCallback? onAnimationComplete;

  const FeedbackOverlay({
    Key? key,
    required this.isCorrect,
    this.isTimeout = false,
    required this.message,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationServiceImpl _animationService;

  @override
  void initState() {
    super.initState();
    _animationService = AnimationServiceImpl();
    
    _controller = AnimationController(
      duration: _animationService.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    _controller.forward();

    // Auto-complete after animation duration
    Future.delayed(_animationService.animationDuration, () {
      if (mounted) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildFeedbackContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie animation
          _buildAnimation(),
          const SizedBox(height: 24),
          
          // Message
          Text(
            widget.message,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getMessageColor(),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Additional feedback
          const SizedBox(height: 16),
          _buildAdditionalFeedback(context),
        ],
      ),
    );
  }

  Widget _buildAnimation() {
    if (widget.isTimeout) {
      return _animationService.buildTimeoutAnimation();
    } else if (widget.isCorrect) {
      return _animationService.buildCorrectAnimation();
    } else {
      return _animationService.buildIncorrectAnimation();
    }
  }

  Widget _buildAdditionalFeedback(BuildContext context) {
    String feedbackText;
    IconData feedbackIcon;
    Color feedbackColor;

    if (widget.isTimeout) {
      feedbackText = 'Better luck next time!';
      feedbackIcon = Icons.access_time;
      feedbackColor = Colors.orange;
    } else if (widget.isCorrect) {
      feedbackText = 'Great job!';
      feedbackIcon = Icons.thumb_up;
      feedbackColor = Colors.green;
    } else {
      feedbackText = 'Keep trying!';
      feedbackIcon = Icons.refresh;
      feedbackColor = Colors.red;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          feedbackIcon,
          color: feedbackColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          feedbackText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: feedbackColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getMessageColor() {
    if (widget.isTimeout) {
      return Colors.orange;
    } else if (widget.isCorrect) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}

class SimpleFeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final String message;
  final Color? backgroundColor;

  const SimpleFeedbackOverlay({
    Key? key,
    required this.isCorrect,
    required this.message,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                size: 80,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}