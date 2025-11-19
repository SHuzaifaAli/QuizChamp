import 'package:flutter/material.dart';
import '../../domain/entities/question_entity.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(int)? onAnswerSelected;
  final int? selectedAnswerIndex;
  final bool showCorrectAnswer;
  final bool isInteractionEnabled;
  final bool isTimeout;

  const QuestionCard({
    Key? key,
    required this.question,
    this.onAnswerSelected,
    this.selectedAnswerIndex,
    this.showCorrectAnswer = false,
    this.isInteractionEnabled = true,
    this.isTimeout = false,
  }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildCard(context),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuestionText(context),
            const SizedBox(height: 32),
            Expanded(
              child: _buildAnswerOptions(context),
            ),
            if (widget.isTimeout) _buildTimeoutMessage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.question.questionText,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnswerOptions(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.question.shuffledAnswers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildAnswerOption(context, index);
      },
    );
  }

  Widget _buildAnswerOption(BuildContext context, int index) {
    final answer = widget.question.shuffledAnswers[index];
    final isSelected = widget.selectedAnswerIndex == index;
    final isCorrect = index == widget.question.correctAnswerIndex;
    
    Color? backgroundColor;
    Color? textColor;
    IconData? icon;

    if (widget.showCorrectAnswer) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    }

    return Material(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onTap: widget.isInteractionEnabled && !widget.showCorrectAnswer
            ? () => widget.onAnswerSelected?.call(index)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: backgroundColor != null
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor != null
                      ? (textColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.2)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: icon != null
                      ? Icon(
                          icon,
                          size: 20,
                          color: textColor ?? Theme.of(context).colorScheme.primary,
                        )
                      : Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor ?? Theme.of(context).colorScheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  answer,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeoutMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Time\'s up! The correct answer is highlighted.',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}