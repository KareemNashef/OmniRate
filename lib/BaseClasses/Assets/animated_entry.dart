// Flutter imports
import 'dart:ui';
import 'package:flutter/material.dart';


class AnimatedBackgroundCard extends StatefulWidget {
  final String inTitle;
  final String inPath;
  final String inArtwork;
  final String inRating;

  const AnimatedBackgroundCard({
    super.key,
    required this.inTitle,
    required this.inPath,
    this.inArtwork = "N/A",
    required this.inRating,
  });

  @override
  AnimatedBackgroundCardState createState() => AnimatedBackgroundCardState();
}

class AnimatedBackgroundCardState extends State<AnimatedBackgroundCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget entryMain(String inTitle, String inPath, String inRating) {
    return SizedBox(
      height: 290,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Background image with animation
                Positioned(
                  left: -50, // Extend beyond left edge
                  right: -50, // Extend beyond right edge
                  top: 0,
                  bottom: 0,
                  child: Transform.translate(
                    offset: Offset(_animation.value * 50, 0), // Reduced scroll distance
                    child: Container(
                      decoration: BoxDecoration(
                        image: widget.inArtwork == 'N/A'
    ? null
    : DecorationImage(
        image: NetworkImage(widget.inArtwork),
        fit: BoxFit.cover,
      ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Content overlay
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Thumbnail
                      Container(
                        width: 135,
                        height: 240,
                        decoration: BoxDecoration(
image: DecorationImage(
  image: NetworkImage(
    inPath.startsWith('file')
      ? 'https://www.igdb.com/assets/no_cover_show-ef1e36c00e101c2fb23d15bb80edd9667bbf604a12fc0267a66033afea320c65.png'
      : inPath,
  ),
  fit: BoxFit.cover,
), // TODO
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      // Padding
                      SizedBox(width: 10),
                      // Title and rating
                      SizedBox(
                        width: 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title
                            Text(
                              inTitle,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),

                            // Padding
                            SizedBox(height: 8),

                            // Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  inRating,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return entryMain(widget.inTitle, widget.inPath, widget.inRating);
  }
}