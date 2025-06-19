// ==================== Feed Page ==================== //

// Flutter imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:omnirate/Feed/friend_cards.dart';
import 'package:omnirate/Feed/friend_model.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Feed/review_card.dart';
import 'package:omnirate/Feed/review_model.dart';
import 'package:omnirate/Shared/firebase_service.dart';

// ========== Feed page ========== //

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  // ===== Class variables ===== //

  // Tab controller
  late TabController _tabController;

  // Firebase instance
  final firebaseService = FirebaseService();

  // Data
  List<Review> reviews = [];
  List<Review> myReviews = [];
  bool reviewsLoaded = false;

  List<Friend> friends = [];
  List<Friend> pendingRequests = [];

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    getReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== Helper Methods ===== //

  Future<void> getReviews() async {
    await getFriends();

    // Clear reviews
    reviews.clear();
    myReviews.clear();

    // Get all reviews
    for (Friend friend in friends) {
      if (friend.status == FriendStatus.accepted) {
        reviews.addAll(await firebaseService.getUserReviews(friend.id));
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      myReviews.addAll(await firebaseService.getUserReviews(user.uid));
    }

    // Sort reviews by timestamp
    reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      reviewsLoaded = true;
    });
  }

  Future<void> getFriends() async {
    // Get all friends
    final allFriends = await firebaseService.getFriends();

    // Clear lists
    friends.clear();
    pendingRequests.clear();

    // Split to pending and friends
    for (Friend friend in allFriends) {
      if (friend.status == FriendStatus.pending) {
        pendingRequests.add(friend);
      } else {
        friends.add(friend);
      }
    }

    setState(() {});
  }

  Future<void> _showAddFriendDialog() async {
    showDialog(
      context: context,
      builder:
          (context) => AddFriendDialog(
            friends: friends,
            pendingRequests: pendingRequests,
          ),
    );
    await getFriends();
    setState(() {});
  }

  Future<void> _acceptFriend(Friend friend) async {
    await firebaseService.acceptFriendRequest(friend);
    setState(() {
      pendingRequests.remove(friend);
      friends.add(
        Friend(id: friend.id, name: friend.name, status: FriendStatus.accepted),
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${friend.name} added to friends!')));
  }

  Future<void> _declineFriend(Friend friend) async {
    await firebaseService.declineFriendRequest(friend);
    setState(() {
      pendingRequests.remove(friend);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Friend request declined')));
  }

  void _removeFriend(Friend friend) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              // Padding
              padding: const EdgeInsets.all(20),

              // Theme
              decoration: BoxDecoration(
                gradient: gradientBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),

              // Content
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Remove Friend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),

                  // Padding
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Are you sure you want to remove ${friend.name} from your friends list?',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  // Padding
                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Keep
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Keep',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // Padding
                      const SizedBox(width: 8),

                      // Cancel Request
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          // Cancel friend request
                          await firebaseService.cancelFriendRequest(friend);

                          // Remove from friends list
                          setState(() => friends.remove(friend));

                          // Close dialog
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Friend removed!')),
                          );
                        },
                        child: const Text('Remove Friend'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _cancelFriendRequest(Friend friend) async {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              // Padding
              padding: const EdgeInsets.all(20),

              // Theme
              decoration: BoxDecoration(
                gradient: gradientBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),

              // Content
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Cancel Friend Request',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),

                  // Padding
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Are you sure you want to cancel the friend request to "${friend.name}"?',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  // Padding
                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Keep
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Keep',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // Padding
                      const SizedBox(width: 8),

                      // Cancel Request
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          // Cancel friend request
                          await firebaseService.cancelFriendRequest(friend);

                          // Remove from friends list
                          setState(() => friends.remove(friend));

                          // Close dialog
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Friend request cancelled'),
                            ),
                          );
                        },
                        child: const Text('Cancel Request'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // ===== Widget Builders ===== //

  Widget _buildModernAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.95),

      // Tabs
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,

            // Indicator
            indicator: containerDecoration(context),
            dividerColor: Colors.transparent,

            // Tabs style
            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),

            // Tabs
            tabs: [
              _buildModernTab('Reviews', Icons.rate_review),
              _buildModernTab('Feed', Icons.forum),
              _buildModernTab('Friends', Icons.group_add),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTab(String text, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await getReviews();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Loading indicator
            if (!reviewsLoaded)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    // Animated loading container
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: containerDecoration(context),
                      child: Column(
                        children: [
                          // Modern circular progress indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 3,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading Reviews...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gathering feedback from your friends!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Shimmer placeholder cards
                    const SizedBox(height: 20),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                          left: 20,
                          right: 20,
                        ),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 80,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 60,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Empty state with witty encouragement
            if (reviewsLoaded && reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: containerDecoration(context),
                      child: Column(
                        children: [
                          // Empty state icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.2),
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.rate_review_outlined,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Witty headline
                          Text(
                            '🦗 Cricket Sounds...',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Encouraging subtext
                          Text(
                            'No reviews yet, but yours could be the first!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Padding
                    const SizedBox(height: 220),
                  ],
                ),
              ),

            if (reviewsLoaded && reviews.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Review cards
                    ...List.generate(
                      reviews.length,
                      (index) => ReviewCard(review: reviews[index]),
                    ),
                  ],
                ),
              ),

            // Padding
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReviewsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await getReviews();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Loading indicator
            if (!reviewsLoaded)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    // Animated loading container
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: containerDecoration(context),
                      child: Column(
                        children: [
                          // Modern circular progress indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 3,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading Reviews...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gathering feedback from your friends!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Shimmer placeholder cards
                    const SizedBox(height: 20),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                          left: 20,
                          right: 20,
                        ),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 80,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 60,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Empty state with witty encouragement
            if (reviewsLoaded && myReviews.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: containerDecoration(context),
                      child: Column(
                        children: [
                          // Empty state icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.2),
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.rate_review_outlined,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Witty headline
                          Text(
                            '🦗 Cricket Sounds...',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Encouraging subtext
                          Text(
                            'You haven’t reviewed anything yet. Start by adding your first review!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Padding
                    const SizedBox(height: 220),
                  ],
                ),
              ),

            if (reviewsLoaded && myReviews.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Review cards
                    ...List.generate(
                      myReviews.length,
                      (index) => ReviewCard(review: myReviews[index]),
                    ),
                  ],
                ),
              ),

            // Padding
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await getFriends();
        // Add your refresh logic here
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Pending Requests
          if (pendingRequests.isNotEmpty) ...[
            sectionHeader(
              context,
              "Friend Requests",
              "These people want to be your friends!",
            ),
            ...pendingRequests.map(
              (friend) => FriendRequestCard(
                friend: friend,
                onAccept: () => _acceptFriend(friend),
                onDecline: () => _declineFriend(friend),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Friends header row
          if (friends.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  sectionHeader(context, "Friends", "These are your friends!"),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Add Friend',
                    onPressed: _showAddFriendDialog,
                  ),
                ],
              ),
            ),

          // Friends list or placeholder
          if (friends.isEmpty)
            Container(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Padding
                  const SizedBox(height: 80),

                  // Empty state icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: containerDecoration(context),
                    child: Icon(
                      Icons.diversity_1_outlined,
                      size: 60,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  // Padding
                  const SizedBox(height: 24),

                  // Empty state text
                  Text(
                    "This is where you'll see all your friends and friend requests. Start connecting with people to build your network!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.9),
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Padding
                  const SizedBox(height: 32),

                  // Add friends button
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showAddFriendDialog(),
                        child: Ink(
                          decoration: buttonDecoration(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon
                                Icon(
                                  Icons.person_add,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),

                                // Padding
                                const SizedBox(width: 12),

                                // Text
                                Text(
                                  "Add Friend",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...friends.map(
              (friend) => FriendCard(
                friend: friend,
                onRemove: () {
                  _removeFriend(friend);
                  setState(() {});
                },
                onCancel: () {
                  _cancelFriendRequest(friend);
                  setState(() {});
                },
              ),
            ),

          // Padding
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Content
      body: Container(
        decoration: BoxDecoration(gradient: gradientBackground(context)),

        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [_buildModernAppBar()];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildMyReviewsTab(),
              _buildFeedTab(),
              _buildFriendsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
