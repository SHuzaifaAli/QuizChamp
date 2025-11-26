import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_champ/src/core/di/injection_container.dart' as di;
import 'package:quiz_champ/src/presentation/pages/add_friends_screen.dart';
import 'package:quiz_champ/src/presentation/pages/share_app_screen.dart';
import 'package:quiz_champ/src/presentation/pages/leaderboard_page.dart';

import '../../domain/entities/user_entity.dart';
import '../blocs/leaderboard/leaderboard_bloc.dart';

class TestNavigationScreen extends StatelessWidget {
  const TestNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserEntity user = UserEntity(id: "12", displayName: "User", email: "test@email", createdAt: DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizChamp - Test Navigation'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Features Test',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildNavigationButton(
              context,
              title: 'Add Friends',
              subtitle: 'Search and add new friends',
              icon: Icons.person_add,
              color: Colors.green,
              onTap: () => _navigateToScreen(context, const AddFriendsScreen()),
            ),
            
            const SizedBox(height: 16),
            
            _buildNavigationButton(
              context,
              title: 'Share App',
              subtitle: 'Share QuizChamp with friends',
              icon: Icons.share,
              color: Colors.blue,
              onTap: () => _navigateToScreen(context, const ShareAppScreen()),
            ),
            
            const SizedBox(height: 16),
            
            _buildNavigationButton(
              context,
              title: 'Leaderboard',
              subtitle: 'View global and friends leaderboard',
              icon: Icons.leaderboard,
              color: Colors.orange,
              onTap: () => _navigateToScreen(
                context, 
                MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => di.sl<LeaderboardBloc>()),
                  ],
                  child:  LeaderboardPage(user: user,),
                ),
              ),
            ),
            
            const Spacer(),
            
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features Implemented:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Firestore security rules'),
                    const Text('✅ Add friends with search'),
                    const Text('✅ Friend request management'),
                    const Text('✅ Share app with invite codes'),
                    const Text('✅ QR code generation'),
                    const Text('✅ Link sharing functionality'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
