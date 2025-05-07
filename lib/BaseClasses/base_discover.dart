// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Games/games_filters.dart';
import 'package:omnirate/Movies/movies_filters.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shows/shows_filters.dart';

// ========== List page base ========== //

class DiscoverPageBase extends StatefulWidget {
  final String inType;

  // Constructor with required parameters
  const DiscoverPageBase({Key? key, required this.inType}) : super(key: key);

  @override
  State<DiscoverPageBase> createState() => DiscoverPageBaseState();
}

class DiscoverPageBaseState extends State<DiscoverPageBase> {
  // ===== Class Variables ===== //

  List<String> usedPaths = [];
  List<String> usedTitles = [];

  // ===== Class Methods ===== //

  // Initialize the lists
  @override
  void initState() {
    super.initState();
    if (widget.inType == "Games") {
      usedPaths = gamesPaths;
      usedTitles = gamesList;
    } else if (widget.inType == "Shows") {
      usedPaths = showsPaths;
      usedTitles = showsList;
    } else if (widget.inType == "Movies") {
      usedPaths = moviesPaths;
      usedTitles = moviesList;
    }
  }

  // ===== Class Widgets ===== //

  // Build list grid
  Widget listGrid(List<String> inPaths, List<String> inTitles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: 100 / 200, // Thumbnail height + spacing
      ),
      itemCount: inPaths.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 160,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(inPaths[index]),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              inTitles[index],
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        );
      },
    );
  }

  // Filter button
  Widget filterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.filter_list),
        label: Text('Filters'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (widget.inType == "Games") {
            showModalBottomSheet(
              context: context,
              builder: (context) => GamesFilterPage(),
            );
          } else if (widget.inType == "Shows") {
            showModalBottomSheet(
              context: context,
              builder: (context) => ShowsFilterPage(),
            );
          } else if (widget.inType == "Movies") {
            showModalBottomSheet(
              context: context,
              builder: (context) => MoviesFilterPage(),
            );
          }
        },
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Remove the back arrow
        automaticallyImplyLeading: false,

        // Set the height
        toolbarHeight: 120,

        title: Column(
          children: [
            Text(
              "Discover",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Padding
            SizedBox(height: 8),

            // Filter
            filterButton(),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(children: [listGrid(usedPaths, usedTitles)]),
      ),
    );
  }
}
