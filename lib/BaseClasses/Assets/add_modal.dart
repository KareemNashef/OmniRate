// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Shared/list_use.dart';

class AddToListModal extends StatefulWidget {
  final void Function(String listType, double rating) onAdd;
  final String mediaType;
  final String mediaName;

  const AddToListModal({
    super.key, 
    required this.onAdd,
    required this.mediaType,
    required this.mediaName,
  });

  @override
  State<AddToListModal> createState() => _AddToListModalState();
}

class _AddToListModalState extends State<AddToListModal> {
  String selectedList = 'Current';
  double rating = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  Future<void> _loadCurrentStatus() async {
    try {
      // Get current status and rating
      final currentStatus = await getMediaStatus(widget.mediaType, widget.mediaName);
      final currentRating = await getMediaRating(widget.mediaType, widget.mediaName);
      
      setState(() {
        // Set default list selection based on current status
        if (currentStatus != null) {
          selectedList = currentStatus;
        }
        
        // Set default rating if user has rated this media
        if (currentRating != null) {
          rating = double.tryParse(currentRating) ?? 0.0;
        }
        
        isLoading = false;
      });
    } catch (e) {
      // Handle error and set defaults
      setState(() {
        selectedList = 'Current';
        rating = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add to List',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text('Select List',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Current', 'Planned', 'Completed', 'Dropped'].map((list) {
              bool isSelected = selectedList == list;
              return FilterChip(
                selected: isSelected,
                onSelected: (_) => setState(() => selectedList = list),
                label: Text(list),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.onPrimaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Rating',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Slider(
            value: rating,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            onChanged: (value) => setState(() => rating = value),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Text(
              rating == 0 ? 'No rating' : '${rating.toStringAsFixed(1)}/10.0',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: rating == 0
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAdd(selectedList, rating);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Update List'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}