import 'package:flutter/material.dart';
import '../../domain/entities/quiz_session_entity.dart';

class QuizResultsCard extends StatefulWidget {
  final QuizSession session;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracyPercentage;
  final Duration totalTime;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onGoHome;

  const QuizResultsCard({
    Key? key,
    required this.session,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracyPercentage,
    required this.totalTime,
    this.onPlayAgain,
    this.onGoHome,
  }) : super(key: key);

  @override
  State<QuizResultsCard> createState() => _QuizResultsCardState();
}

class _QuizResultsCardState extends State<QuizResultsCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildResultsCard(context),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildScoreCircle(context),
            const SizedBox(height: 24),
            _buildStatistics(context),
            const SizedBox(height: 16),
            _buildPerformanceMessage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(context) {
    return Column(
      children: [
        Icon(
          _getResultIcon(),
          size: 48,
          color: _getResultColor(),
        ),
        const SizedBox(height: 8),
        Text(
          'Quiz Complete!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.correctAnswers}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getResultColor(),
            ),
          ),
          Text(
            'out of ${widget.totalQuestions}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${widget.accuracyPercentage.round()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _getResultColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final minutes = widget.totalTime.inMinutes;
    final seconds = widget.totalTime.inSeconds % 60;
    final averageTime = widget.totalQuestions > 0
        ? Duration(seconds: widget.totalTime.inSeconds ~/ widget.totalQuestions)
        : Duration.zero;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          context,
          icon: Icons.access_time,
          label: 'Total Time',
          value: '${minutes}m ${seconds}s',
        ),
        _buildStatItem(
          context,
          icon: Icons.speed,
          label: 'Avg/Question',
          value: '${averageTime.inSeconds}s',
        ),
        _buildStatItem(
          context,
          icon: Icons.trending_up,
          label: 'Accuracy',
          value: '${widget.accuracyPercentage.round()}%',
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMessage(BuildContext context) {
    String message;
    IconData icon;
    Color color;

    if (widget.accuracyPercentage >= 90) {
      message = 'Outstanding! You\'re a quiz master!';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (widget.accuracyPercentage >= 80) {
      message = 'Excellent work! Keep it up!';
      icon = Icons.star;
      color = Colors.green;
    } else if (widget.accuracyPercentage >= 70) {
      message = 'Good job! You\'re getting better!';
      icon = Icons.thumb_up;
      color = Colors.blue;
    } else if (widget.accuracyPercentage >= 50) {
      message = 'Not bad! Practice makes perfect!';
      icon = Icons.trending_up;
      color = Colors.orange;
    } else {
      message = 'Keep practicing! You\'ll improve!';
      icon = Icons.refresh;
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onGoHome,
            icon: const Icon(Icons.home),
            label: const Text('Home'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onPlayAgain,
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getResultIcon() {
    if (widget.accuracyPercentage >= 90) {
      return Icons.emoji_events;
    } else if (widget.accuracyPercentage >= 70) {
      return Icons.star;
    } else if (widget.accuracyPercentage >= 50) {
      return Icons.thumb_up;
    } else {
      return Icons.refresh;
    }
  }

  Color _getResultColor() {
    if (widget.accuracyPercentage >= 90) {
      return Colors.amber;
    } else if (widget.accuracyPercentage >= 70) {
      return Colors.green;
    } else if (widget.accuracyPercentage >= 50) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }
}