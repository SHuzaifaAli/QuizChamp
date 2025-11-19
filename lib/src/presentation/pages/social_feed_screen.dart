import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/social_activity/social_activity_bloc.dart';
import '../blocs/social_activity/social_activity_event.dart';
import '../blocs/social_activity/social_activity_state.dart';

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshFeed(context),
          ),
        ],
      ),
      body: const SocialFeedBody(),
    );
  }

  void _refreshFeed(BuildContext context) {
    // Get current friend IDs and refresh
    context.read<SocialActivityBloc>().add(
      const RefreshActivityFeed(['friend1', 'friend2']), // Replace with actual friend IDs
    );
  }
}

class SocialFeedBody extends StatelessWidget {
  const SocialFeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialActivityBloc, SocialActivityState>(
      builder: (context, state) {
        if (state is SocialActivityLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SocialActivityError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadFeed(context),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is SocialActivityFeedLoaded && state.activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No activity yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'When your friends complete quizzes, their activities will appear here',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is SocialActivityFeedLoaded) {
          return RefreshIndicator(
            onRefresh: () async => _loadFeed(context),
            child: ListView.builder(
              itemCount: state.activities.length,
              itemBuilder: (context, index) {
                final activity = state.activities[index];
                return ActivityCard(activity: activity);
              },
            ),
          );
        }

        return Center(
          child: ElevatedButton(
            onPressed: () => _loadFeed(context),
            child: const Text('Load Feed'),
          ),
        );
      },
    );
  }

  void _loadFeed(BuildContext context) {
    // Replace with actual friend IDs from friends bloc
    context.read<SocialActivityBloc>().add(
      const LoadFriendsActivityFeed(['friend1', 'friend2']),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final dynamic activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: activity.userPhotoUrl != null
                      ? NetworkImage(activity.userPhotoUrl)
                      : null,
                  child: activity.userPhotoUrl == null
                      ? Text(activity.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.userName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        _formatTimestamp(activity.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActivityIcon(context, activity.type),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activity.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (activity.data != null) ...[
              const SizedBox(height: 8),
              _buildActivityDetails(context, activity),
            ],
            const SizedBox(height: 12),
            _buildReactionsSection(context, activity),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityIcon(BuildContext context, String activityType) {
    switch (activityType) {
      case 'quizCompleted':
        return const Icon(Icons.quiz, color: Colors.blue);
      case 'achievementUnlocked':
        return const Icon(Icons.emoji_events, color: Colors.amber);
      case 'newHighScore':
        return const Icon(Icons.trending_up, color: Colors.green);
      case 'streakMilestone':
        return const Icon(Icons.local_fire_department, color: Colors.orange);
      case 'challengeCompleted':
        return const Icon(Icons.sports_esports, color: Colors.purple);
      default:
        return const Icon(Icons.activity, color: Colors.grey);
    }
  }

  Widget _buildActivityDetails(BuildContext context, dynamic activity) {
    switch (activity.type) {
      case 'quizCompleted':
        final data = activity.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${data['score']}/${data['totalQuestions']}'),
            Text('Accuracy: ${((data['accuracy'] as double) * 100).toInt()}%'),
            Text('Category: ${data['category']}'),
            Text('Time: ${_formatDuration(Duration(seconds: data['timeTaken']))}'),
          ],
        );
      case 'achievementUnlocked':
        final data = activity.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Achievement: ${data['achievementTitle']}'),
            Text(data['achievementDescription']),
          ],
        );
      case 'newHighScore':
        final data = activity.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${data['score']}'),
            Text('Category: ${data['category']} (${data['difficulty']})'),
          ],
        );
      case 'streakMilestone':
        final data = activity.data;
        return Text('Streak: ${data['streakDays']} days');
      case 'challengeCompleted':
        final data = activity.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opponent: ${data['opponentName']}'),
            Text('Result: ${data['result']}'),
            Text('Score: ${data['score']}'),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReactionsSection(BuildContext context, dynamic activity) {
    final reactions = activity.reactions as Map<String, dynamic>? ?? {};
    
    return Row(
      children: [
        IconButton(
          onPressed: () => _addReaction(context, activity.id, 'like'),
          icon: const Icon(Icons.thumb_up, size: 20),
        ),
        Text('${reactions.values.where((r) => r == 'like').length}'),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () => _addReaction(context, activity.id, 'celebrate'),
          icon: const Icon(Icons.celebration, size: 20),
        ),
        Text('${reactions.values.where((r) => r == 'celebrate').length}'),
        const Spacer(),
        TextButton(
          onPressed: () => _showReactionsDialog(context, activity),
          child: const Text('View All'),
        ),
      ],
    );
  }

  void _addReaction(BuildContext context, String activityId, String reactionType) {
    // Replace with actual user ID
    const userId = 'current_user_id';
    context.read<SocialActivityBloc>().add(
      AddReactionToActivity(
        activityId: activityId,
        userId: userId,
        reactionType: reactionType == 'like' ? ReactionType.like : ReactionType.celebrate,
      ),
    );
  }

  void _showReactionsDialog(BuildContext context, dynamic activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactions'),
        content: const Text('Reactions list will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is DateTime) {
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }
    return 'Unknown time';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
