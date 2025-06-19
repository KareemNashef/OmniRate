// ==================== Entry Page Base ==================== //

// Flutter imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:omnirate/BasePages/Assets/add_comment.dart';

// Local imports
import 'package:omnirate/BasePages/Assets/animated_entry.dart';
import 'package:omnirate/BasePages/Assets/add_modal.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Feed/review_model.dart';
import 'package:omnirate/Main/animated_bar.dart';
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/list_use.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Entry Page Base Class ========== //

abstract class EntryPageBase<T extends MediaEntry> extends StatefulWidget {
  // ===== Input Variables ===== //
  final T inEntry;

  // ===== Constructor ===== //
  const EntryPageBase({super.key, required this.inEntry});
}

abstract class EntryPageBaseState<
  T extends MediaEntry,
  W extends EntryPageBase<T>
>
    extends State<W> {
  // ===== Class Variables ===== //

  T get entry => widget.inEntry;

  // Index of the currently selected page
  bool commentView = false;

  // Animation controllers for sequential animations
  late AnimationController entryAnimationController;
  late AnimationController entrySlideController;
  late AnimationController reviewSlideController;

  // Animations
  late Animation<double> entryScaleAnimation;
  late Animation<Offset> entrySlideAnimation;
  late Animation<Offset> reviewSlideAnimation;

  bool isAnimating = false;

  // Reviews list
  List<Review> reviews = [];
  bool reviewsLoaded = false;

  // ===== Class Methods ===== //

  void addToListMethod(String listType, String rating) async {
    if (listType == 'Remove') {
      await removeMediaEntry(
        widget.inEntry.mediaType.toString(),
        widget.inEntry.id,
      );
    } else {
      await addMediaEntry(
        widget.inEntry.mediaType.toString(),
        widget.inEntry.id,
        widget.inEntry.name,
        rating,
        listType,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          listType == 'Remove'
              ? 'Removed from list!'
              : (double.parse(rating) > 0
                  ? 'Added to $listType with $rating/10 rating!'
                  : 'Added to $listType!'),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: 2), // shorter time
      ),
    );

    setState(() {});
  }

  Future<Map<String, String>> getMediaStatusAndRating() async {
    final status = await getMediaStatus(
      widget.inEntry.mediaType.toString(),
      widget.inEntry.id,
    );

    final rating = await getMediaRating(
      widget.inEntry.mediaType.toString(),
      widget.inEntry.id,
    );

    return {'status': status ?? '', 'rating': rating ?? '0'};
  }

  Future<void> getReviews() async {
    final firebaseService = FirebaseService();
    reviews =
        (await firebaseService.getReviews(widget.inEntry)).reversed.toList();

    setState(() {
      reviewsLoaded = true;
    });
  }

  String? getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  Future<void> animateToCommentView() async {
    if (isAnimating) return;
    isAnimating = true;

    entryAnimationController.forward();
    await Future.wait([
      entrySlideController.forward(),
      reviewSlideController.forward(),
    ]);

    setState(() {
      commentView = true;
    });

    isAnimating = false;
  }

  Future<void> animateToEntryView() async {
    if (isAnimating) return;
    isAnimating = true;

    await Future.wait([
      reviewSlideController.reverse(),
      entrySlideController.reverse(),
    ]);

    setState(() {
      commentView = false;
    });

    entryAnimationController.reverse();

    isAnimating = false;
  }

  Future<void> addReview(String inReview) async {
    // Get the rating of a media entry
    final rating = await getMediaRating(
      widget.inEntry.mediaType.toString(),
      widget.inEntry.id,
    );

    final firebaseService = FirebaseService();
    await firebaseService.addReview(
      widget.inEntry,
      rating.toString(),
      inReview,
    );

    await getReviews();
    setState(() {});
  }

  Future<void> deleteReview(DateTime inTime) async {
    final firebaseService = FirebaseService();
    await firebaseService.deleteReview(widget.inEntry, inTime);

    await getReviews();
    setState(() {});
  }

  // ===== Class Widgets ===== //

  Widget entryMain({bool inCommentView = false}) {
    return AnimatedBackgroundCard(
      inEntry: widget.inEntry,
      commentPage: inCommentView,
    );
  }

  Widget infoLine(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: value == "" ? "N/A" : value,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.85),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() => Divider(
    height: 16,
    thickness: 1,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
  );

  Widget addToList() {
    return SizedBox(
      width: double.infinity,
      child: FutureBuilder<Map<String, String>>(
        future: getMediaStatusAndRating(),
        builder: (context, snapshot) {
          String buttonText = "Add to My List";
          IconData buttonIcon = Icons.playlist_add;

          List<Color> gradientColors = [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.8),
            Theme.of(
              context,
            ).colorScheme.tertiaryContainer.withValues(alpha: 0.8),
          ];

          String? rating;

          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            final status = data['status']!;
            rating = data['rating']!;

            switch (status) {
              case "Current":
                buttonText =
                    widget.inEntry.mediaType.toString() == "MediaType.game"
                        ? "Currently Playing"
                        : "Currently Watching";
                buttonIcon = Icons.play_circle_fill;
                gradientColors = [Colors.blue.shade200, Colors.blue.shade400];
                break;
              case "Planned":
                buttonText =
                    widget.inEntry.mediaType.toString() == "MediaType.game"
                        ? "Planned to Play"
                        : "Planned to Watch";
                buttonIcon = Icons.schedule;
                gradientColors = [
                  Colors.orange.shade200,
                  Colors.orange.shade400,
                ];
                break;
              case "Completed":
                buttonText = "Completed";
                buttonIcon = Icons.check_circle;
                gradientColors = [Colors.green.shade200, Colors.green.shade400];
                break;
              case "Dropped":
                buttonText = "Dropped";
                buttonIcon = Icons.remove_circle;
                gradientColors = [Colors.red.shade200, Colors.red.shade400];
                break;
            }
          }

          return Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder:
                        (context) => AddToListModal(
                          onAdd:
                              (list, rating) =>
                                  addToListMethod(list, rating.toString()),
                          mediaType: widget.inEntry.mediaType.toString(),
                          mediaID: widget.inEntry.id,
                        ),
                  ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        buttonIcon,
                        color:
                            buttonText == "Add to My List"
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.shadow,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        buttonText +
                            (buttonText != "Add to My List" && rating != null
                                ? (rating == "0.0"
                                    ? "  •  Not Rated Yet"
                                    : "  •  $rating/10")
                                : ""),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              buttonText == "Add to My List"
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget reviewsBox() {
    return Column(
      children: [
        // Section header
        sectionHeader(
          context,
          'Reviews & Comments',
          "Community feedback and reviews.",
        ),

        // Reviews container
        Column(
          children: [
            // Modern Loading indicator with shimmer effect
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
                            'Gathering community feedback',
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

            // Actual reviews using _reviews data
            if (reviewsLoaded && reviews.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Review count badge only
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: buttonDecoration(context),
                          child: Text(
                            '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Review cards
                    ...List.generate(reviews.length, (index) {
                      final firebaseService = FirebaseService();
                      final review = reviews[index];
                      final userName = review.userName;
                      final userEmail = review.userEmail;
                      final rating = review.rating;
                      final reviewText = review.review;
                      final timestamp = review.timestamp;

                      // Format timestamp
                      String formatTimestamp(DateTime? timestamp) {
                        if (timestamp == null) return 'Recently';
                        final now = DateTime.now();
                        final difference = now.difference(timestamp);

                        if (difference.inDays > 7) {
                          return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
                        } else if (difference.inDays > 0) {
                          return '${difference.inDays}d ago';
                        } else if (difference.inHours > 0) {
                          return '${difference.inHours}h ago';
                        } else if (difference.inMinutes > 0) {
                          return '${difference.inMinutes}m ago';
                        } else {
                          return 'Just now';
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: containerDecoration(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info header
                              Row(
                                children: [
                                  // Avatar
                                  FutureBuilder<int?>(
                                    future: firebaseService
                                        .getAvatarIndexFirebase(review.userId),
                                    builder: (context, snapshot) {
                                      final index = snapshot.data ?? 0;
                                      return CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundImage: AssetImage(
                                            'assets/ProfilePics/pic_${index + 1}.png',
                                          ),
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(width: 12),

                                  // User details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          formatTimestamp(timestamp),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Delete button if user owns the review
                                  if (userEmail == getUserEmail())
                                    Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => deleteReview(timestamp),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.red.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                              color: Colors.red.shade600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Rating badge
                                  ratingsIndicator(context, rating),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Review content with enhanced styling
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.4),
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).shadowColor.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  reviewText,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.9),
                                    fontSize: 16,
                                    height: 1.6,
                                    letterSpacing: 0.3,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Padding
                    const SizedBox(height: 300),
                  ],
                ),
              ),
            // Padding
            SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  Widget addCommentFAB() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: buttonDecoration(context),

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(20),

            onTap:
                () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => AddCommentModal(
                        onSubmit: (review) => addReview(review),
                        mediaType:
                            widget.inEntry.mediaType == MediaType.game
                                ? 'game'
                                : widget.inEntry.mediaType == MediaType.movie
                                ? 'movie'
                                : 'show',
                      ),
                ),

            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'Add Review',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget commentContent() {
    return SlideTransition(
      position: reviewSlideAnimation,
      child: Column(
        key: const ValueKey('comment_content'),
        children: [reviewsBox(), const SizedBox(height: 90)],
      ),
    );
  }

  Widget navigationBar() {
    final icon = switch (widget.inEntry.mediaType) {
      MediaType.game => Icons.videogame_asset_rounded,
      MediaType.movie => Icons.movie,
      MediaType.show => Icons.tv,
    };
    final title = switch (widget.inEntry.mediaType) {
      MediaType.game => 'Game',
      MediaType.movie => 'Movie',
      MediaType.show => 'Show',
    };

    return AnimatedBottomBar(
      items: [
        AnimatedBottomBarItem(icon: icon, title: title),
        const AnimatedBottomBarItem(icon: Icons.comment, title: 'Reviews'),
      ],
      initialIndex: commentView ? 1 : 0,
      onTabSelected: (index) async {
        if (isAnimating) return;

        if (index == 1 && !commentView) {
          await animateToCommentView();
        } else if (index == 0 && commentView) {
          await animateToEntryView();
        }
      },
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
