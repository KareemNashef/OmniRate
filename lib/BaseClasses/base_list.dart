// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/Shared/list_use.dart';
import 'package:omnirate/Shows/show_entry.dart';

// ========== List page base ========== //
class ListPageBase extends StatefulWidget {
  // ===== Class Variables ===== //
  final String listType;

  const ListPageBase({super.key, required this.listType});

  @override
  State<ListPageBase> createState() => ListPageBaseState();
}

class ListPageBaseState extends State<ListPageBase>
    with SingleTickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Controllers
  late TabController _tabController;

  // Data storage for each tab
  Map<String, List<dynamic>> tabData = {
    'Current': [],
    'Planned': [],
    'Completed': [],
    'Dropped': [],
  };

  Map<String, bool> isLoading = {
    'Current': true,
    'Planned': true,
    'Completed': true,
    'Dropped': true,
  };

  // ===== Class Methods ===== //

  // Initialize controllers
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  // Load data for all tabs
  Future<void> _loadAllData() async {
    final statuses = ['Current', 'Planned', 'Completed', 'Dropped'];

    for (String status in statuses) {
      await _loadDataForStatus(status);
    }
  }

  // Load data for specific status
  Future<void> _loadDataForStatus(String status) async {
    try {
      // Get user media entries for this status
      final userEntries = await getMediaByStatus(widget.listType, status);

      List<dynamic> mediaEntries = [];

      // Fetch detailed media info for each entry
      for (var userEntry in userEntries) {
        dynamic media;

        switch (widget.listType.toLowerCase()) {
          case 'games':
            media = await getGame(userEntry.name);
            break;
          case 'shows':
            media = await getShow(userEntry.name);
            break;
          case 'movies':
            media = await getMovie(userEntry.name);
            break;
        }

        if (media != null) {
          mediaEntries.add(media);
        }
      }

      if (mounted) {
        setState(() {
          tabData[status] = mediaEntries;
          isLoading[status] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          tabData[status] = [];
          isLoading[status] = false;
        });
      }
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== Class Widgets ===== //

  // Build list grid for specific status
  Widget listGrid(String status) {
    if (isLoading[status] == true) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = tabData[status] ?? [];

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 64,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No ${widget.listType.toLowerCase()} in $status yet!',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Start building your ${widget.listType.toLowerCase()} collection by adding some entries.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      // Grid Properties
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: (9 / 16) * 0.8,
      ),
      itemCount: entries.length,

      itemBuilder: (context, index) {
        final entry = entries[index];

        return GestureDetector(
          onTap: () async {
            Widget page;
            switch (widget.listType) {
              case "Games":
                page = GameEntry(inEntry: entry as Game);
                break;
              case "Shows":
                page = ShowEntry(inEntry: entry as Show);
                break;
              case "Movies":
                page = MovieEntry(inEntry: entry as Movie);
                break;
              default:
                return;
            }
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
            _loadAllData(); // Reload when returning
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail
              Expanded(
                child: AspectRatio(
                  aspectRatio: 9 / 16, // Explicit 9:16 aspect ratio
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image:
                          entry.thumbnailUrl != null &&
                                  entry.thumbnailUrl!.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(entry.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                      color:
                          entry.thumbnailUrl == null ||
                                  entry.thumbnailUrl!.isEmpty
                              ? Colors.primaries[index %
                                  Colors.primaries.length]
                              : null,
                    ),
                    child:
                        entry.thumbnailUrl == null ||
                                entry.thumbnailUrl!.isEmpty
                            ? Center(
                              child: Icon(
                                _getIconForType(widget.listType),
                                size: 32,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            )
                            : null,
                  ),
                ),
              ),

              // Padding
              const SizedBox(height: 8),

              // Title
              Text(
                entry.name ?? "Unknown ${widget.listType}",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Get appropriate icon for media type
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'game':
        return Icons.videogame_asset;
      case 'show':
        return Icons.tv;
      case 'movie':
        return Icons.movie;
      default:
        return Icons.library_books;
    }
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
        children: [
          listGrid('Current'),
          listGrid('Planned'),
          listGrid('Completed'),
          listGrid('Dropped'),
        ],
      ),
    );
  }
}
