import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/hearts/hearts_bloc.dart';
import '../blocs/hearts/hearts_state.dart';

class HeartsWidget extends StatelessWidget {
  final bool showRegenerationTimer;
  final TextStyle? textStyle;

  const HeartsWidget({
    super.key,
    this.showRegenerationTimer = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeartsBloc, HeartsState>(
      builder: (context, state) {
        if (state is HeartsLoaded) {
          return _buildHeartsDisplay(context, state);
        }
        return _buildLoadingHearts();
      },
    );
  }

  Widget _buildHeartsDisplay(BuildContext context, HeartsLoaded state) {
    final heartsService = context.read<HeartsBloc>().service;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              state.maxHearts,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  index < state.currentHearts
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 24,
                  color: index < state.currentHearts
                      ? Colors.red
                      : Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${state.currentHearts}/${state.maxHearts}',
              style: textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        if (showRegenerationTimer && state.currentHearts < state.maxHearts)
          FutureBuilder<Duration>(
            future: heartsService.getTimeToNextHeart(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Next heart in: ${_formatDuration(snapshot.data!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildLoadingHearts() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]!),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '...',
          style: textStyle?.copyWith(
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return 'soon';
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class CompactHeartsWidget extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;
  final double iconSize;
  final TextStyle? textStyle;

  const CompactHeartsWidget({
    super.key,
    required this.currentHearts,
    required this.maxHearts,
    this.iconSize = 20,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          maxHearts,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              index < currentHearts ? Icons.favorite : Icons.favorite_border,
              size: iconSize,
              color: index < currentHearts ? Colors.red : Colors.grey[400],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$currentHearts/$maxHearts',
          style: textStyle ??
              Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class HeartsDisplayWidget extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;
  final bool isAnimating;
  final double heartSize;

  const HeartsDisplayWidget({
    super.key,
    required this.currentHearts,
    required this.maxHearts,
    this.isAnimating = false,
    this.heartSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          maxHearts,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              index < currentHearts ? Icons.favorite : Icons.favorite_border,
              size: heartSize,
              color: index < currentHearts
                  ? (isAnimating ? Colors.pink : Colors.red)
                  : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}
