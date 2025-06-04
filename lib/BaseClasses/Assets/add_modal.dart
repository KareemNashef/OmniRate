// Flutter imports
import 'package:flutter/material.dart';

class AddToListModal extends StatefulWidget {
  final void Function(String listType, double rating) onAdd;

  const AddToListModal({super.key, required this.onAdd});

  @override
  State<AddToListModal> createState() => _AddToListModalState();
}

class _AddToListModalState extends State<AddToListModal> {
  String selectedList = 'Current';
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  child: const Text('Add to List'),
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
