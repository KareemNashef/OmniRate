// Flutter imports
import 'package:flutter/material.dart';

// ========== Entry page ========== //

class EntryBase extends StatefulWidget {
  const EntryBase({super.key});

  @override
  EntryBaseState createState() => EntryBaseState();
}

class EntryBaseState extends State<EntryBase> {
  // ===== Class Widgets ===== //

  // Entry main
  Widget entryMain() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Thumbnail
        Container(
          width: 135,
          height: 240,
          decoration: BoxDecoration(
            color:
                Colors.primaries[DateTime.now().millisecondsSinceEpoch %
                    Colors.primaries.length],
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Padding
        SizedBox(width: 10),

        // Title
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entry',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Rating',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Add to list button
  Widget addToList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: Text('Add to list'),
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
