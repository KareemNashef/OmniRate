// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/Assets/animated_entry.dart';
import 'package:omnirate/BaseClasses/Assets/add_modal.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Shared/list_use.dart';

// ========== Entry page ========== //

abstract class EntryBase<T extends MediaEntry> extends StatefulWidget {
  final T inEntry;

  const EntryBase({super.key, required this.inEntry});
}

abstract class EntryBaseState<T extends MediaEntry, W extends EntryBase<T>>
    extends State<W> {
  T get entry => widget.inEntry as T;

  // ===== Class Widgets ===== //

  // Entry main
  Widget entryMain() {
    return AnimatedBackgroundCard(inEntry: widget.inEntry);
  }

// Add to list button
// Add to list button
Widget addToList() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: SizedBox(
      width: double.infinity,
      child: FutureBuilder<String?>(
        future: getMediaStatus(widget.inEntry.mediaType.toString(), widget.inEntry.name),
        builder: (context, snapshot) {
          String buttonText = "Add to My List";
          Color backgroundColor = Theme.of(context).colorScheme.primaryContainer;
          Color foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
          IconData buttonIcon = Icons.playlist_add;
          
          if (snapshot.hasData && snapshot.data != null) {
            final status = snapshot.data!;
            switch (status) {
              case "Current":
                buttonText = "Currently Watching";
                backgroundColor = Colors.blue.shade100;
                foregroundColor = Colors.blue.shade800;
                buttonIcon = Icons.play_circle_fill;
                break;
              case "Planned":
                buttonText = "Planned to Watch";
                backgroundColor = Colors.orange.shade100;
                foregroundColor = Colors.orange.shade800;
                buttonIcon = Icons.schedule;
                break;
              case "Completed":
                buttonText = "Completed";
                backgroundColor = Colors.green.shade100;
                foregroundColor = Colors.green.shade800;
                buttonIcon = Icons.check_circle;
                break;
              case "Dropped":
                buttonText = "Dropped";
                backgroundColor = Colors.red.shade100;
                foregroundColor = Colors.red.shade800;
                buttonIcon = Icons.remove_circle;
                break;
            }
          }
          
          return ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddToListModal(
                onAdd: (list, rating) => _addToList(list, rating),
                mediaType: widget.inEntry.mediaType.toString(),
                mediaName: widget.inEntry.name,
              ),
            ),
            icon: Icon(buttonIcon),
            label: Text(
              buttonText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    ),
  );
}
  // ===== Class Functions ===== //

  // Function to handle adding to list
  void _addToList(String listType, double rating) async {

    await addMediaEntry(
      widget.inEntry.mediaType.toString(),
      widget.inEntry.name,
      rating,
      listType,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          rating > 0
              ? 'Added to $listType with ${rating.toStringAsFixed(1)}/10 rating!'
              : 'Added to $listType!',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    setState(() {
      
    });
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
