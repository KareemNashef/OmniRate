// ==================== Add To List Modal ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/list_use.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Add To List Modal Class ========== //

class AddToListModal extends StatefulWidget {
  // ===== Input Variables ===== //
  final void Function(String listType, double rating) onAdd;
  final String mediaType;
  final String mediaID;

  // ===== Constructor ===== //
  const AddToListModal({
    super.key,
    required this.onAdd,
    required this.mediaType,
    required this.mediaID,
  });

  @override
  State<AddToListModal> createState() => _AddToListModalState();
}

class _AddToListModalState extends State<AddToListModal> {
  // ===== Class Variables ===== //

  // Default values
  String selectedList = 'Current';
  double rating = 0;
  bool isLoading = true;

  bool inList = false;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  // ===== Class Methods ===== //

  Future<void> _loadCurrentStatus() async {
    try {
      // Get current status and rating
      final currentStatus = await getMediaStatus(
        widget.mediaType,
        widget.mediaID,
      );
      final currentRating = await getMediaRating(
        widget.mediaType,
        widget.mediaID,
      );

      setState(() {
        // Set default list selection based on current status
        if (currentStatus != null) {
          selectedList = currentStatus;
          inList = true;
        }

        // Set default rating if user has rated this media
        if (currentRating != null) {
          rating = double.parse(currentRating);
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        selectedList = 'Current';
        rating = 0;
        isLoading = false;
      });
    }
  }

  // ===== Class Widgets ===== //

  Widget listSelector() {
    return Row(
      children:
          ['Current', 'Planned', 'Completed', 'Dropped'].asMap().entries.map((
            entry,
          ) {
            int idx = entry.key;
            String label = entry.value;
            bool isSelected = selectedList == label;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedList = label;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.horizontal(
                      left: idx == 0 ? Radius.circular(12) : Radius.zero,
                      right: idx == 3 ? Radius.circular(12) : Radius.zero,
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget ratingSelector() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.3),
            trackHeight: 4,
            thumbColor: Theme.of(context).colorScheme.primaryContainer,
            overlayColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
            valueIndicatorColor: Theme.of(context).colorScheme.primary,
            valueIndicatorTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: rating,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            label: rating.toStringAsFixed(1),
            onChanged: (value) => setState(() => rating = value),
          ),
        ),

        // Padding
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradientContainer(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 20,
                color:
                    rating > 0
                        ? Colors.amber
                        : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 8),

              Text(
                rating == 0 ? 'No rating' : rating.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget actionButtons() {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Padding
        const SizedBox(width: 12),

        // Conditionally show Remove Button
        if (inList) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                widget.onAdd('Remove', 0.0);
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Remove',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),
        ],

        // Update Button
        Expanded(
          child: Container(
            decoration: buttonDecoration(context),
            child: Material(
              color: Colors.transparent,

              child: InkWell(
                borderRadius: BorderRadius.circular(20),

                onTap: () {
                  widget.onAdd(selectedList, rating);
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      'Update List',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        // Theme
        decoration: BoxDecoration(
          gradient: gradientBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),

        // Padding
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),

        // Content
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Container(
      // Theme
      decoration: BoxDecoration(
        gradient: gradientBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),

      // Padding
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),

      // Content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Padding
          const SizedBox(height: 20),

          // Title
          sectionHeader(
            context,
            'Add to List',
            'Choose a list and rate this ${widget.mediaType.split('.').last}',
          ),

          // Padding
          const SizedBox(height: 16),

          // List selector
          listSelector(),

          // Padding
          const SizedBox(height: 16),

          // Rating selector
          ratingSelector(),

          // Padding
          const SizedBox(height: 16),

          // Action buttons
          actionButtons(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
