// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Settings/settings_main.dart';

// ===== List page base ===== //
class ListPageBase extends StatefulWidget {

  final String listType;

  const ListPageBase({
    Key? key, 
    required this.listType,
  }) : super(key: key);

  @override
  State<ListPageBase> createState() => ListPageBaseState();
}

class ListPageBaseState extends State<ListPageBase>
    with SingleTickerProviderStateMixin {
  // ===== Class Variables ===== //

  late TabController _tabController;

  // ===== Class Methods ===== //

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  // ===== Class Widgets ===== //

  Widget listGrid() {
    return GridView.builder(
      // Grid Properties
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: (9 / 16) * 0.8,
      ),
      itemCount: 12,

      itemBuilder: (context, index) {
        // Use modulo to cycle through colors deterministically based on index
        final color = Colors.primaries[index % Colors.primaries.length];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail
            Expanded(
              child: AspectRatio(
                aspectRatio: 9 / 16, // Explicit 9:16 aspect ratio
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Padding
            const SizedBox(height: 8),

            // Title
            Text(
              "Entry $index",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.listType} List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Planned'),
            Tab(text: 'Completed'),
            Tab(text: 'Dropped'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [listGrid(), listGrid(), listGrid(), listGrid()],
      ),
    );
  }
}
