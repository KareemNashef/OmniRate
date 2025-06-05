// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/Assets/animated_entry.dart';
import 'package:omnirate/BaseClasses/Assets/add_modal.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Database/model_game.dart';

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
  Widget addToList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed:
              () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => AddToListModal(
                      onAdd: (list, rating) => _addToList(list, rating),
                    ),
              ),
          icon: Icon(Icons.playlist_add),
          label: Text(
            "Add to My List",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // ===== Class Functions ===== //

  // Function to handle adding to list
  void _addToList(String listType, double rating) {
    // TODO

    // Example: You might want to call an API, update local storage, etc.
    // showSnackBar or show success message
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
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
