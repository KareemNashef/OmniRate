// ==================== Friend Cards ==================== //

// Flutter imports

import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Feed/friend_model.dart';
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Friend Card Class ========== //

class FriendCard extends StatelessWidget {
  // ===== Input Variables ===== //

  final Friend friend;
  final VoidCallback onRemove;
  final VoidCallback onCancel;

  // ===== Constructor ===== //

  const FriendCard({
    super.key,
    required this.friend,
    required this.onRemove,
    required this.onCancel,
  });

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: containerDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Avatar
          FutureBuilder<int?>(
            future: firebaseService.getAvatarIndexFirebase(friend.id),
            builder: (context, snapshot) {
              final index = snapshot.data ?? 0;
              return CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(
                    'assets/ProfilePics/pic_${index + 1}.png',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              friend.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Remove button
          if (friend.status == FriendStatus.accepted)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.person_remove),
              color: Colors.red,
              tooltip: 'Remove Friend',
            ),

          // Requested indicator
          if (friend.status == FriendStatus.requested)
            GestureDetector(
              onTap: () {
                onCancel();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Requested',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ========== Friend Request Card Class ========== //

class FriendRequestCard extends StatelessWidget {
  // ===== Input Variables ===== //
  final Friend friend;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  // ===== Constructor ===== //

  const FriendRequestCard({
    super.key,
    required this.friend,
    required this.onAccept,
    required this.onDecline,
  });

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: containerDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Avatar
          FutureBuilder<int?>(
            future: firebaseService.getAvatarIndexFirebase(friend.id),
            builder: (context, snapshot) {
              final index = snapshot.data ?? 0;
              return CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(
                    'assets/ProfilePics/pic_${index + 1}.png',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              friend.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Accept button
          IconButton(
            onPressed: onAccept,
            icon: const Icon(Icons.check),
            color: Colors.green,
            tooltip: 'Accept Request',
          ),

          // Decline button
          IconButton(
            onPressed: onDecline,
            icon: const Icon(Icons.close),
            color: Colors.red,
            tooltip: 'Decline Request',
          ),
        ],
      ),
    );
  }
}

// ========== Add Friend Dialog Class ========== //

class AddFriendDialog extends StatefulWidget {
  // ===== Input Variables ===== //

  final List<Friend> friends;
  final List<Friend> pendingRequests;

  // ===== Constructor ===== //

  const AddFriendDialog({
    super.key,
    required this.friends,
    required this.pendingRequests,
  });

  @override
  AddFriendDialogState createState() => AddFriendDialogState();
}

class AddFriendDialogState extends State<AddFriendDialog> {
  // ===== Class variables ===== //

  // Controllers
  final TextEditingController _controller = TextEditingController();

  // Services
  final friendsService = FirebaseService();

  // Variables
  List<Map<String, dynamic>> _users = [];
  final List<String> _requestedUsers = [];
  bool _loading = false;

  // ===== Helper Methods ===== //

  void _search() async {
    if (_controller.text.length < 2) return;

    setState(() => _loading = true);
    _users = await friendsService.searchUsers(_controller.text);
    setState(() => _loading = false);
  }

  bool _isAlreadyFriend(String userId) {
    return widget.friends.any(
      (friend) => friend.id == userId && friend.status == FriendStatus.accepted,
    );
  }

  bool _isPendingRequest(String userId) {
    return widget.pendingRequests.any((friend) => friend.id == userId);
  }

  bool _isRequested(String userId) {
    return widget.friends.any(
      (friend) =>
          (friend.id == userId && friend.status == FriendStatus.requested) ||
          _requestedUsers.contains(userId),
    );
  }

  // ===== Widget Builders ===== //

  Widget _buildUserTile(Map<String, dynamic> user) {
    final userId = user['id'];
    final userName = user['userName'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: containerDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            FutureBuilder<int?>(
              future: friendsService.getAvatarIndexFirebase(userId),
              builder: (context, snapshot) {
                final avatarIndex = snapshot.data ?? 0;
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    'assets/ProfilePics/pic_${avatarIndex + 1}.png',
                  ),
                );
              },
            ),

            const SizedBox(width: 12),

            // Username
            Expanded(
              child: Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            // Action button/indicator
            _buildActionButton(userId),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String userId) {
    // Already friends indicator
    if (_isAlreadyFriend(userId)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: const Text(
          'Friends',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }

    // Pending request indicator
    if (_isPendingRequest(userId)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: const Text(
          'Pending',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }

    // Requested indicator
    if (_isRequested(userId)) {
      return Container(
        // Padding
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

        // Theme
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),

        // Content
        child: const Text(
          'Requested',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }

    // Add button
    return GestureDetector(
      onTap: () async {
        await friendsService.sendFriendRequest(userId);
        setState(() {
          _requestedUsers.add(userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Friend request sent!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: const Text(
          'Add',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          gradient: gradientBackground(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  const Text(
                    'Add Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search username...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => _search(),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Flexible(
              child:
                  _controller.text.length < 2
                      ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Type at least 2 characters to search',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : _loading
                      ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                      : _users.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No users found',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shrinkWrap: true,
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            return _buildUserTile(_users[index]);
                          },
                        ),
                      ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
