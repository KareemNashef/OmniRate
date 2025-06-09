// ==================== Entry Page Base ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/Assets/animated_entry.dart';
import 'package:omnirate/BasePages/Assets/add_modal.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Shared/list_use.dart';

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

  // ===== Class Widgets ===== //

  Widget entryMain() {
    return AnimatedBackgroundCard(inEntry: widget.inEntry);
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

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
