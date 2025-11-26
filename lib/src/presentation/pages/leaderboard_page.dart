import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_champ/src/domain/entities/leaderboard_entity.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';
import 'package:quiz_champ/src/presentation/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/leaderboard/leaderboard_event.dart';
import 'package:quiz_champ/src/presentation/blocs/leaderboard/leaderboard_state.dart';

class LeaderboardPage extends StatefulWidget {
  final UserEntity user;
  const LeaderboardPage({super.key, required this.user});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load initial data
    context.read<LeaderboardBloc>().add(
          LoadGlobalLeaderboard(),
        );
    context.read<LeaderboardBloc>().add(
          LoadUserRank(userId: widget.user.id),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global', icon: Icon(Icons.public)),
            Tab(text: 'Friends', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalLeaderboard(),
          _buildFriendsLeaderboard(),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard() {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GlobalLeaderboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<LeaderboardBloc>().add(
                    RefreshLeaderboard(userId: widget.user.id),
                  );
            },
            child: _buildLeaderboardList(state.leaderboard),
          );
        } else if (state is LeaderboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<LeaderboardBloc>().add(
                          LoadGlobalLeaderboard(),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('Pull to refresh leaderboard'));
      },
    );
  }

  Widget _buildFriendsLeaderboard() {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FriendsLeaderboardLoaded) {
          if (state.leaderboard.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No friends on leaderboard yet'),
                  SizedBox(height: 8),
                  Text('Add friends to see their scores!'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<LeaderboardBloc>().add(
                    RefreshLeaderboard(userId: widget.user.id),
                  );
            },
            child: _buildLeaderboardList(state.leaderboard),
          );
        } else if (state is LeaderboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<LeaderboardBloc>().add(
                          LoadFriendsLeaderboard(userId: widget.user.id),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('Add friends to see their scores!'));
      },
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntity> leaderboard) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        final isCurrentUser = entry.userId == widget.user.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isCurrentUser ? 8 : 2,
          color: isCurrentUser ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRankColor(entry.rank),
              child: Text(
                '${entry.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.displayName,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.totalPoints} points'),
                Text(
                  '${entry.totalQuizzes} quizzes • ${entry.accuracyPercentage.toStringAsFixed(1)}% accuracy',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🔥 ${entry.currentStreak}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Rank #${entry.rank}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(entry.rank),
                  ),
                ),
              ],
            ),
            onTap: () {
              // Could show user profile details
            },
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade600;
      default:
        return Colors.blue;
    }
  }
}
