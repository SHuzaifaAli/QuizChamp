import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_champ/src/domain/entities/friend_entity.dart';
import 'package:quiz_champ/src/domain/entities/friend_request_entity.dart';
import 'package:quiz_champ/src/presentation/blocs/friends/friends_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/friends/friends_event.dart';
import 'package:quiz_champ/src/presentation/blocs/friends/friends_state.dart';
import 'package:quiz_champ/src/presentation/widgets/common/loading_widget.dart';
import 'package:quiz_champ/src/presentation/widgets/common/error_widget.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    // TODO: Get current user ID from auth service
    _currentUserId = 'current_user_id'; // Placeholder
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildFriendRequestsSection(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<FriendsBloc>().add(ClearSearchResultsEvent());
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                context.read<FriendsBloc>().add(SearchUsersEvent(
                    query: query, currentUserId: _currentUserId));
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Search for users by their display name or email address',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRequestsSection() {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendRequestsLoaded && state.requests.isNotEmpty) {
          return ExpansionTile(
            title: Text(
              'Friend Requests (${state.requests.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: state.requests
                .map((request) => _buildFriendRequestTile(request))
                .toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFriendRequestTile(FriendRequest request) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: request.fromUserPhotoUrl != null
            ? NetworkImage(request.fromUserPhotoUrl!)
            : null,
        child: request.fromUserPhotoUrl == null
            ? Text(request.fromUserName[0].toUpperCase())
            : null,
      ),
      title: Text(request.fromUserName),
      subtitle: request.message.isNotEmpty ? Text(request.message) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              context
                  .read<FriendsBloc>()
                  .add(AcceptFriendRequestEvent(requestId: request.id));
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              context
                  .read<FriendsBloc>()
                  .add(DeclineFriendRequestEvent(requestId: request.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const LoadingWidget();
        }

        if (state is FriendsError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              if (_searchController.text.trim().isNotEmpty) {
                context.read<FriendsBloc>().add(SearchUsersEvent(
                      query: _searchController.text,
                      currentUserId: _currentUserId,
                    ));
              }
            },
          );
        }

        if (state is UsersSearchLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with a different name or email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return _buildUserTile(user);
            },
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_search,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Find Friends',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for users by name or email',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserTile(Friend user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.displayName[0].toUpperCase())
              : null,
        ),
        title: Text(user.displayName),
        subtitle: user.email!.isNotEmpty ? Text(user.email.toString()) : null,
        trailing: ElevatedButton(
          onPressed: () => _showSendFriendRequestDialog(user),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Friend'),
        ),
      ),
    );
  }

  void _showSendFriendRequestDialog(Friend user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Friend Request to ${user.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Send a message with your friend request (optional):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Hi! I\'d like to be friends on QuizChamp!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintMaxLines: 3,
                ),
                maxLength: 200,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _messageController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<FriendsBloc>().add(SendFriendRequestEvent(
                      fromUserId: _currentUserId,
                      toUserId: user.id,
                      message: _messageController.text.trim(),
                    ));
                _messageController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Friend request sent to ${user.displayName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }
}
