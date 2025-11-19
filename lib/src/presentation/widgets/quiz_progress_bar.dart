import 'package:flutter/material.dart';

class QuizProgressBar extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const QuizProgressBar({
    Key? key,
    required this.currentQuestion,
    required this.totalQuestions,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
  }) : super(key: key);

  @override
  State<QuizProgressBar> createState() => _QuizProgressBarState();
}

class _QuizProgressBarState extends State<QuizProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _calculateProgress(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(QuizProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentQuestion != widget.currentQuestion) {
      _previousProgress = _progressAnimation.value;
      final newProgress = _calculateProgress();
      
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    if (widget.totalQuestions == 0) return 0.0;
    return widget.currentQuestion / widget.totalQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${widget.currentQuestion} of ${widget.totalQuestions}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(_calculateProgress() * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  color: widget.backgroundColor ?? 
                         Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      gradient: LinearGradient(
                        colors: [
                          widget.progressColor ?? Theme.of(context).colorScheme.primary,
                          (widget.progressColor ?? Theme.of(context).colorScheme.primary)
                              .withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CircularQuizProgressBar extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;

  const CircularQuizProgressBar({
    Key? key,
    required this.currentQuestion,
    required this.totalQuestions,
    this.size = 60.0,
    this.strokeWidth = 6.0,
    this.progressColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<CircularQuizProgressBar> createState() => _CircularQuizProgressBarState();
}

class _CircularQuizProgressBarState extends State<CircularQuizProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _calculateProgress(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(CircularQuizProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentQuestion != widget.currentQuestion) {
      final newProgress = _calculateProgress();
      
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    if (widget.totalQuestions == 0) return 0.0;
    return widget.currentQuestion / widget.totalQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: _progressAnimation.value,
                strokeWidth: widget.strokeWidth,
                backgroundColor: widget.backgroundColor ?? 
                               Theme.of(context).colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.progressColor ?? Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.currentQuestion}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'of ${widget.totalQuestions}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;
  final double stepSize;

  const StepProgressBar({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
    this.stepSize = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: stepSize,
          height: stepSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? (activeColor ?? Theme.of(context).colorScheme.primary)
                : (inactiveColor ?? Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            border: isCurrent
                ? Border.all(
                    color: activeColor ?? Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: isCurrent
              ? Icon(
                  Icons.circle,
                  size: stepSize * 0.6,
                  color: activeColor ?? Theme.of(context).colorScheme.primary,
                )
              : null,
        );
      }),
    );
  }
}