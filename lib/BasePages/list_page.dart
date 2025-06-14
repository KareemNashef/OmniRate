// ==================== Modern List Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Local imports
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/Shared/list_use.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shows/show_entry.dart';

// Enum for sorting options
enum SortOption { nameAsc, nameDesc, ratingHigh, ratingLow, dateAdded }

// Enum for view modes
enum ViewMode { grid, list }

// ========== Modern List Page Class ========== //

class ListPage extends StatefulWidget {
  // ===== Input Variables ===== //
  final String listType;

  // ===== Constructor ===== //
  const ListPage({super.key, required this.listType});

  @override
  State<ListPage> createState() => ListPageState();
}

class ListPageState extends State<ListPage> with TickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Controllers
  late TabController _tabController;
  late AnimationController _searchAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Variables for Search and Sort
  bool _isSearchVisible = false;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.nameAsc;
  ViewMode _currentViewMode = ViewMode.grid;

  // Data storage for each tab
  Map<String, List<dynamic>> tabData = {
    'All': [],
    'Current': [],
    'Planned': [],
    'Completed': [],
    'Dropped': [],
  };

  Map<String, List<dynamic>> userEntryData = {
    'All': [],
    'Current': [],
    'Planned': [],
    'Completed': [],
    'Dropped': [],
  };

  Map<String, bool> isLoading = {
    'All': true,
    'Current': true,
    'Planned': true,
    'Completed': true,
    'Dropped': true,
  };

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initialize animations
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });

    _fabAnimationController.forward();
    loadAllData();
  }

  Future<void> loadAllData() async {
    print(await HiveHelper.getAllIDs());
    final statuses = ['All', 'Current', 'Planned', 'Completed', 'Dropped'];
    final allItems = await getMediaByType(widget.listType);

    for (final status in statuses) {
      tabData[status] = [];
      userEntryData[status] = [];
    }

    for (final item in allItems) {
      final content = switch (widget.listType) {
        'Games' => await getGame(item.id),
        'Shows' => await getShow(item.id),
        _ => await getMovie(item.id),
      };

      // Add item to the corresponding tab
      tabData[item.status]?.add(content);
      userEntryData[item.status]?.add(item);

      // Add item to the All tab
      tabData['All']?.add(content);
      userEntryData['All']?.add(item);
    }

    for (var status in statuses) {
      isLoading[status] = false;
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // ===== Helper Methods ===== //

  String getEmptyListTitle(String type, String status) {
    switch (status) {
      case 'All':
        return 'Your ${type.toLowerCase()} collection awaits';
      case 'Current':
        return 'Nothing in progress';
      case 'Planned':
        return 'Your watchlist is empty';
      case 'Completed':
        return 'No completed ${type.toLowerCase()} yet';
      case 'Dropped':
        return 'Clean slate';
      default:
        return 'Nothing here yet';
    }
  }

  String getEmptyListSubtitle(String type, String status) {
    switch (status) {
      case 'All':
        return 'Start building your ${type.toLowerCase()} library';
      case 'Current':
        return 'Pick something to start your journey';
      case 'Planned':
        return 'Add ${type.toLowerCase()} you want to explore';
      case 'Completed':
        return 'Finished ${type.toLowerCase()} will appear here';
      case 'Dropped':
        return 'Sometimes it\'s okay to move on';
      default:
        return 'Your ${type.toLowerCase()} will appear here';
    }
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'Games':
        return Colors.blue;
      case 'Shows':
        return Colors.green;
      case 'Movies':
        return Colors.orange;
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'All':
        return const Color(0xFF8B5CF6);
      case 'Current':
        return const Color(0xFF3B82F6);
      case 'Planned':
        return const Color(0xFFF59E0B);
      case 'Completed':
        return const Color(0xFF10B981);
      case 'Dropped':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'All':
        return Icons.dashboard_rounded;
      case 'Current':
        return Icons.play_circle_fill_rounded;
      case 'Planned':
        return Icons.bookmark_add_rounded;
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Dropped':
        return Icons.remove_circle_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimationController.forward();
        _searchFocusNode.requestFocus();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });
  }

  Future<void> _navigateToEntry(dynamic entry) async {
    HapticFeedback.lightImpact();

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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    // Reload data when returning
    loadAllData();
  }

  // ===== Widget Builders ===== //

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.95),
      elevation: 0,
      shadowColor: Colors.transparent,
      forceElevated: false,

      // Title Space
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            _isSearchVisible
                // Search bar
                ? SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.listType.toLowerCase()}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 24),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                )
                // List type title
                : Center(
                  child: SizedBox(
                    height: 50,
                    width: 140,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: getTypeColor(
                          widget.listType,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getListTypeIcon(),
                            size: 24,
                            color: getTypeColor(widget.listType),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.listType,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: getTypeColor(widget.listType),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      ),

      // Tabs
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,

            // Indicator
            indicator: containerDecoration(context),
            dividerColor: Colors.transparent,

            // Tabs style
            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),

            // Tabs
            tabs: [
              _buildModernTab('All', getStatusIcon('All')),
              _buildModernTab('Current', getStatusIcon('Current')),
              _buildModernTab('Planned', getStatusIcon('Planned')),
              _buildModernTab('Completed', getStatusIcon('Completed')),
              _buildModernTab('Dropped', getStatusIcon('Dropped')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTab(String text, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildSortMenuItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }

  IconData _getListTypeIcon() {
    switch (widget.listType.toLowerCase()) {
      case 'games':
        return Icons.sports_esports_rounded;
      case 'movies':
        return Icons.movie_rounded;
      case 'shows':
        return Icons.tv_rounded;
      default:
        return Icons.list_rounded;
    }
  }

  Widget _buildContent(String status) {
    // Loading Screen
    if (isLoading[status] == true) {
      return _buildLoadingState();
    }

    final initialEntries = tabData[status] ?? [];
    final initialUserEntries = userEntryData[status] ?? [];

    // Combine and process data
    List<Map<String, dynamic>> combinedList = [];
    for (int i = 0; i < initialEntries.length; i++) {
      final media = initialEntries[i];
      final userEntry =
          initialUserEntries.length > i ? initialUserEntries[i] : null;

      combinedList.add({'media': media, 'user': userEntry});
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      combinedList =
          combinedList.where((item) {
            final mediaName = item['media'].name as String;
            return mediaName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
    }

    // Sort the list
    combinedList.sort((a, b) {
      final mediaA = a['media'];
      final mediaB = b['media'];
      final userA = a['user'];
      final userB = b['user'];

      switch (_currentSortOption) {
        case SortOption.nameAsc:
          return mediaA.name.toLowerCase().compareTo(mediaB.name.toLowerCase());
        case SortOption.nameDesc:
          return mediaB.name.toLowerCase().compareTo(mediaA.name.toLowerCase());
        case SortOption.ratingHigh:
          final ratingA = double.tryParse(userA?.rating ?? '') ?? -1;
          final ratingB = double.tryParse(userB?.rating ?? '') ?? -1;
          return ratingB.compareTo(ratingA);
        case SortOption.ratingLow:
          final ratingA = double.tryParse(userA?.rating ?? '') ?? 11;
          final ratingB = double.tryParse(userB?.rating ?? '') ?? 11;
          return ratingA.compareTo(ratingB);
        case SortOption.dateAdded:
          // Assuming newer entries are added later in the list
          return b['media'].id.compareTo(a['media'].id);
      }
    });

    // Empty state
    if (combinedList.isEmpty) {
      return _buildEmptyState(status, initialEntries.isNotEmpty);
    }

    return _currentViewMode == ViewMode.grid
        ? _buildGridView(combinedList)
        : _buildListView(combinedList);
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Loading indicator
        Container(
          padding: const EdgeInsets.all(20),
          decoration: buttonDecoration(context),
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
        ),

        // Padding
        const SizedBox(height: 24),

        // Loading text
        Text(
          'Loading your ${widget.listType.toLowerCase()}...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String status, bool hasSearchResults) {
    // Empty Search
    if (_searchQuery.isNotEmpty && hasSearchResults) {
      return _buildNoSearchResults();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                getStatusColor(status).withValues(alpha: 0.15),
                getStatusColor(status).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: getStatusColor(status).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            getStatusIcon(status),
            size: 64,
            color: getStatusColor(status).withValues(alpha: 0.8),
          ),
        ),

        // Padding
        const SizedBox(height: 32),

        // Title
        Text(
          getEmptyListTitle(widget.listType, status),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          getEmptyListSubtitle(widget.listType, status),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
            ),
          ),

          // Padding
          const SizedBox(height: 24),

          // Text
          Text(
            'No results found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for "$_searchQuery" with different terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> combinedList) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.52,
      ),
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        final item = combinedList[index];
        final entry = item['media'];
        final userEntry = item['user'];
        return _buildGridItem(entry, userEntry);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> combinedList) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        final item = combinedList[index];
        final entry = item['media'];
        final userEntry = item['user'];
        return _buildListItem(entry, userEntry, index);
      },
    );
  }

  Widget _buildGridItem(dynamic entry, dynamic userEntry) {
    final rating = userEntry?.rating;

    return GestureDetector(
      onTap: () => _navigateToEntry(entry),
      child: Container(
        // Theme
        decoration: containerDecoration(context),

        // Content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail with gradient overlay
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [buildImageFromUrl(entry.thumbnailUrl ?? '')],
                      ),
                    ),
                  ),

                  // Rating badge
                  if (rating != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade500,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!(rating.toString() == '0.0'))
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString() == '0.0' ? 'Not Rated' : rating,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Title and info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    entry.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),

                  // Status
                  if (userEntry != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(
                          userEntry.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userEntry.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(userEntry.status),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(dynamic entry, dynamic userEntry, int index) {
    final rating = userEntry?.rating;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _navigateToEntry(entry),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: containerDecoration(context),
          child: Row(
            children: [
              // Thumbnail
              Hero(
                tag: 'media_${entry.id}_list',
                child: Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: buildImageFromUrl(entry.thumbnailUrl ?? ''),
                  ),
                ),
              ),

              // Padding
              const SizedBox(width: 16),

              // Entry Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      entry.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),

                    // Padding
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // Status
                        if (userEntry != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(
                                userEntry.status,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  getStatusIcon(userEntry.status),
                                  size: 14,
                                  color: getStatusColor(userEntry.status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userEntry.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: getStatusColor(userEntry.status),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Rating
                          if (rating != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade400,
                                    Colors.orange.shade500,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!(rating.toString() == '0.0'))
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toString() == '0.0'
                                        ? 'Not Rated'
                                        : rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Actions Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grid/List
              if (!_isSearchVisible)
                Container(
                  // Padding
                  margin: const EdgeInsets.only(right: 8),

                  // Theme
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                    ),

                    // Background
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.tertiaryContainer,
                      ],
                    ),

                    // Glow
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),

                  child: IconButton(
                    icon: Icon(
                      _currentViewMode == ViewMode.grid
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentViewMode =
                            _currentViewMode == ViewMode.grid
                                ? ViewMode.list
                                : ViewMode.grid;
                      });
                    },
                  ),
                ),

              // Sort
              if (!_isSearchVisible)
                Container(
                  // Padding
                  margin: const EdgeInsets.only(right: 8),

                  // Theme
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                    ),

                    // Background
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.tertiaryContainer,
                      ],
                    ),

                    // Glow
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),

                  child: PopupMenuButton<SortOption>(
                    offset: const Offset(55, -220),
                    onSelected: (SortOption result) {
                      setState(() {
                        _currentSortOption = result;
                      });
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(Icons.sort_rounded, size: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem(
                            value: SortOption.nameAsc,
                            child: _buildSortMenuItem(
                              Icons.sort_by_alpha_rounded,
                              'Name (A-Z)',
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.nameDesc,
                            child: _buildSortMenuItem(
                              Icons.sort_by_alpha_rounded,
                              'Name (Z-A)',
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.ratingHigh,
                            child: _buildSortMenuItem(
                              Icons.star_rounded,
                              'Rating (High to Low)',
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.ratingLow,
                            child: _buildSortMenuItem(
                              Icons.star_outline_rounded,
                              'Rating (Low to High)',
                            ),
                          ),
                        ],
                  ),
                ),

              // Search button
              Container(
                // Padding
                margin: const EdgeInsets.only(right: 0),

                // Theme
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),

                  // Background
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.tertiaryContainer,
                    ],
                  ),

                  // Glow
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),

                // Icon
                child: IconButton(
                  icon: Icon(
                    _isSearchVisible
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    size: 20,
                  ),
                  onPressed: _toggleSearch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingActionButton(),

      // Content
      body: Container(
        decoration: BoxDecoration(gradient: gradientBackground(context)),

        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [_buildModernAppBar()];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildContent('All'),
              _buildContent('Current'),
              _buildContent('Planned'),
              _buildContent('Completed'),
              _buildContent('Dropped'),
            ],
          ),
        ),
      ),
    );
  }
}
