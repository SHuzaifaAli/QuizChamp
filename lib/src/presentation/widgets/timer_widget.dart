import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimerWidget extends StatefulWidget {
  final int remainingTime;
  final int totalTime;
  final VoidCallback? onTimeUp;

  const TimerWidget({
    Key? key,
    required this.remainingTime,
    required this.totalTime,
    this.onTimeUp,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start pulsing when time is running low
    if (widget.remainingTime <= 10 && widget.remainingTime > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Call onTimeUp when time reaches 0
    if (widget.remainingTime == 0 && oldWidget.remainingTime > 0) {
      widget.onTimeUp?.call();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.remainingTime / widget.totalTime;
    final isLowTime = widget.remainingTime <= 10;
    final isVeryLowTime = widget.remainingTime <= 5;

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isLowTime ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress indicator
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(context, widget.remainingTime),
                      ),
                    ),
                  ),
                  
                  // Time text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.remainingTime}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(context, widget.remainingTime),
                        ),
                      ),
                      Text(
                        'seconds',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getTextColor(context, widget.remainingTime).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  
                  // Warning indicator for very low time
                  if (isVeryLowTime && widget.remainingTime > 0)
                    Positioned(
                      top: 10,
                      child: Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getProgressColor(BuildContext context, int remainingTime) {
    if (remainingTime <= 5) {
      return Colors.red;
    } else if (remainingTime <= 10) {
      return Colors.orange;
    } else if (remainingTime <= 15) {
      return Colors.yellow.shade700;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getTextColor(BuildContext context, int remainingTime) {
    if (remainingTime <= 5) {
      return Colors.red;
    } else if (remainingTime <= 10) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.onSurface;
    }
  }
}

class LinearTimerWidget extends StatelessWidget {
  final int remainingTime;
  final int totalTime;
  final double height;

  const LinearTimerWidget({
    Key? key,
    required this.remainingTime,
    required this.totalTime,
    this.height = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = remainingTime / totalTime;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: _getProgressColor(context, remainingTime),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(BuildContext context, int remainingTime) {
    if (remainingTime <= 5) {
      return Colors.red;
    } else if (remainingTime <= 10) {
      return Colors.orange;
    } else if (remainingTime <= 15) {
      return Colors.yellow.shade700;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}