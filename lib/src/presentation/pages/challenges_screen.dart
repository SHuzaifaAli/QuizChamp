import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/challenges/challenges_bloc.dart';
import '../blocs/challenges/challenges_event.dart';
import '../blocs/challenges/challenges_state.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const ChallengesBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChallengeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateChallengeDialog(),
    );
  }
}

class ChallengesBody extends StatefulWidget {
  const ChallengesBody({super.key});

  @override
  State<ChallengesBody> createState() => _ChallengesBodyState();
}

class _ChallengesBodyState extends State<ChallengesBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              PendingChallengesTab(),
              ActiveChallengesTab(),
              CompletedChallengesTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class PendingChallengesTab extends StatelessWidget {
  const PendingChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengesBloc, ChallengesState>(
      builder: (context, state) {
        if (state is ChallengesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChallengesError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is ChallengesLoaded && state.pendingChallenges.isEmpty) {
          return const Center(
            child: Text('No pending challenges'),
          );
        }

        if (state is ChallengesLoaded) {
          return ListView.builder(
            itemCount: state.pendingChallenges.length,
            itemBuilder: (context, index) {
              final challenge = state.pendingChallenges[index];
              return ChallengeCard(
                challenge: challenge,
                onAccept: () => _acceptChallenge(context, challenge.id),
                onDecline: () => _declineChallenge(context, challenge.id),
              );
            },
          );
        }

        return const Center(child: Text('Load your challenges'));
      },
    );
  }

  void _acceptChallenge(BuildContext context, String challengeId) {
    context.read<ChallengesBloc>().add(AcceptChallenge(challengeId));
  }

  void _declineChallenge(BuildContext context, String challengeId) {
    context.read<ChallengesBloc>().add(DeclineChallenge(challengeId));
  }
}

class ActiveChallengesTab extends StatelessWidget {
  const ActiveChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengesBloc, ChallengesState>(
      builder: (context, state) {
        if (state is ChallengesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChallengesError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is ChallengesLoaded && state.activeChallenges.isEmpty) {
          return const Center(
            child: Text('No active challenges'),
          );
        }

        if (state is ChallengesLoaded) {
          return ListView.builder(
            itemCount: state.activeChallenges.length,
            itemBuilder: (context, index) {
              final challenge = state.activeChallenges[index];
              return ActiveChallengeCard(challenge: challenge);
            },
          );
        }

        return const Center(child: Text('Load your challenges'));
      },
    );
  }
}

class CompletedChallengesTab extends StatelessWidget {
  const CompletedChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengesBloc, ChallengesState>(
      builder: (context, state) {
        if (state is ChallengesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChallengesError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is ChallengesLoaded && state.completedChallenges.isEmpty) {
          return const Center(
            child: Text('No completed challenges'),
          );
        }

        if (state is ChallengesLoaded) {
          return ListView.builder(
            itemCount: state.completedChallenges.length,
            itemBuilder: (context, index) {
              final challenge = state.completedChallenges[index];
              return CompletedChallengeCard(challenge: challenge);
            },
          );
        }

        return const Center(child: Text('Load your challenges'));
      },
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final dynamic challenge;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge from ${challenge.challengerName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Category: ${challenge.category}'),
            Text('Difficulty: ${challenge.difficulty}'),
            Text('Questions: ${challenge.questions?.length ?? 0}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDecline,
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveChallengeCard extends StatelessWidget {
  final dynamic challenge;

  const ActiveChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge with ${challenge.challengerName ?? challenge.challengedName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Category: ${challenge.category}'),
            Text('Difficulty: ${challenge.difficulty}'),
            Text('Status: ${challenge.status}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startChallenge(context, challenge.id),
              child: const Text('Start Challenge'),
            ),
          ],
        ),
      ),
    );
  }

  void _startChallenge(BuildContext context, String challengeId) {
    // Navigate to challenge quiz screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting challenge...')),
    );
  }
}

class CompletedChallengeCard extends StatelessWidget {
  final dynamic challenge;

  const CompletedChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge with ${challenge.challengerName ?? challenge.challengedName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Category: ${challenge.category}'),
            Text('Difficulty: ${challenge.difficulty}'),
            if (challenge.challengerScore != null && challenge.challengedScore != null) ...[
              Text('Your Score: ${challenge.challengerScore}'),
              Text('Opponent Score: ${challenge.challengedScore}'),
            ],
            Text('Completed: ${challenge.completedAt ?? 'Unknown'}'),
          ],
        ),
      ),
    );
  }
}

class CreateChallengeDialog extends StatelessWidget {
  const CreateChallengeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Challenge'),
      content: const Text('Challenge creation form will be implemented here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Implement challenge creation
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
