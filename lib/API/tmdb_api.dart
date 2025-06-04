// ==================== TMDB API - Shows And Movies ==================== //
// Documentation: https://developer.themoviedb.org/docs/getting-started
// Call testing: https://www.postman.com/
// API Key: b0660f1133aa5458af9be7244a2988ee

// Flutter imports
// ...
import 'dart:convert';
import 'package:http/http.dart' as http;

// Local imports
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// ========== Helper Consts ==========

// API Keys and urls
// GenreToIDMap
// ...

const String _apiKey = 'b0660f1133aa5458af9be7244a2988ee';
const String _baseUrl = 'https://api.themoviedb.org/3';
const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

// ===== Genre to ID Map (Movies) =====
const Map<String, int> genreToIDMap = {
  'Action': 28,
  'Adventure': 12,
  'Animation': 16,
  'Comedy': 35,
  'Crime': 80,
  'Documentary': 99,
  'Drama': 18,
  'Family': 10751,
  'Fantasy': 14,
  'History': 36,
  'Horror': 27,
  'Music': 10402,
  'Mystery': 9648,
  'Romance': 10749,
  'Science Fiction': 878,
  'TV Movie': 10770,
  'Thriller': 53,
  'War': 10752,
  'Western': 37,
};

// ===== Genre to ID Map (TV Shows) =====
const Map<String, int> tvGenreToIDMap = {
  'Action & Adventure': 10759,
  'Animation': 16,
  'Comedy': 35,
  'Crime': 80,
  'Documentary': 99,
  'Drama': 18,
  'Family': 10751,
  'Kids': 10762,
  'Mystery': 9648,
  'News': 10763,
  'Reality': 10764,
  'Sci-Fi & Fantasy': 10765,
  'Soap': 10766,
  'Talk': 10767,
  'War & Politics': 10768,
  'Western': 37,
};













// ========== Main Functions - Movies ==========

// Func: getMovieEntry
// Input: Movie name
// Output: Movie object
Future<Movie> getMovieEntry(String inName) async {
  final searchUrl = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(inName)}');

  final searchResponse = await http.get(searchUrl);

  if (searchResponse.statusCode == 200) {
    final searchData = jsonDecode(searchResponse.body);
    final List results = searchData['results'];

    if (results.isEmpty) {
      throw Exception('No movie found with name: $inName');
    }

    final movieId = results.first['id'];
    final movieUrl = Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey');

    final movieResponse = await http.get(movieUrl);

    if (movieResponse.statusCode == 200) {
      final movieData = jsonDecode(movieResponse.body);

      return Movie(
        name: movieData['title'] ?? 'Unknown',
        thumbnailUrl: '$_imageBaseUrl${movieData['poster_path'] ?? ''}',
        backdropUrl: '$_imageBaseUrl${movieData['backdrop_path'] ?? ''}',
        rating: (movieData['vote_average'] as num?)?.toDouble() ?? 0.0,
        releaseStatus: movieData['release_date'] ?? 'N/A',
        genres: (movieData['genres'] as List).map((g) => g['name'].toString()).toList(),
        overview: movieData['overview'] ?? 'N/A',
        budget: movieData['budget']?.toString() ?? 'N/A',
        revenue: movieData['revenue']?.toString() ?? 'N/A',
      );
    } else {
      throw Exception('Failed to fetch full movie details');
    }
  } else {
    throw Exception('Failed to search movie');
  }
}


// Func: getFilteredMovies
// Input: List<String> genres, String category, String minRating
// Output: List<Movie> moviesList - Sized to 20;
Future<Map<String, String>> getFilteredMovies(
    List<String> inGenres, String inCategory, String inMinRating ,{int resultNum = 20}) async {
  try {
    // Convert genre names to TMDB genre IDs
    final genreIds = inGenres
        .map((genre) => genreToIDMap[genre])
        .where((id) => id != null)
        .join(',');

    // Get today's date in YYYY-MM-DD format
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Determine release date filter
    String releaseDateParam = '';
    if (inCategory == 'available') {
      releaseDateParam = '&primary_release_date.lte=$todayStr';
    } else if (inCategory == 'upcoming') {
      releaseDateParam = '&primary_release_date.gte=$todayStr';
    }

    // Build the full URL
    final url = Uri.parse(
      '$_baseUrl/discover/movie?api_key=$_apiKey'
      '&with_genres=$genreIds'
      '&vote_average.gte=$inMinRating'
      '$releaseDateParam'
      '&sort_by=popularity.desc'
      '&page=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      // Build map: movie name => poster URL
      final Map<String, String> moviesMap = {};
      for (var movie in results.take(resultNum)) {
        final name = movie['title'] ?? 'Unknown';
        final posterPath = movie['poster_path'];
        if (posterPath != null) {
          moviesMap[name] = '$_imageBaseUrl$posterPath';
        }
      }

      return moviesMap;
    } else {
      throw Exception('Failed to load filtered movies');
    }
  } catch (e) {
    throw Exception('Error fetching filtered movies: $e');
  }
}

/*
// Func: getUpcomingMovies
// Input: None
// Output: Map<string,string> moviesList - Sized to 10;
// https://api.themoviedb.org/3/discover/movie?primary_release_date.gte=2025-06-04&region=US
Future<Map<String, String>> getUpcomingMovies() async {
  try {
    // Format today's date as YYYY-MM-DD
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Build the request URL
    final url = Uri.parse(
      '$_baseUrl/discover/movie?api_key=$_apiKey'
      '&primary_release_date.gte=$todayStr'
      '&region=US'
      '&sort_by=popularity.desc'
      '&page=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      // Map movie name to its poster URL (if available)
      final Map<String, String> upcomingMovies = {};

      for (var movie in results.take(10)) {
        final title = movie['title'] ?? 'Unknown';
        final posterPath = movie['poster_path'];
        final posterUrl = posterPath != null ? '$_imageBaseUrl$posterPath' : '';

        upcomingMovies[title] = posterUrl;
      }

      return upcomingMovies;
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  } catch (e) {
    throw Exception('Error fetching upcoming movies: $e');
  }
}
*/



// Func: getUpcomingMovies
// Input: None
// Output: Map<string,string> moviesList - Sized to 10;
// https://api.themoviedb.org/3/discover/movie?primary_release_date.gte=2025-06-04&region=US
Future<Map<String, String>> getUpcomingMovies() async {
  return await getFilteredMovies([], 'upcoming', '0', resultNum: 10);
}

/*
// Func: getLatestMovies
// Input: None
// Output: Map<string,string moviesList - Sized to 10;
// https://api.themoviedb.org/3/movie/now_playing
Future<Map<String, String>> getLatestMovies() async {
  try {
    final url = Uri.parse(
      '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=en-US&page=1&region=US',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      final Map<String, String> latestMovies = {};

      for (var movie in results.take(10)) {
        final title = movie['title'] ?? 'Unknown';
        final posterPath = movie['poster_path'];
        final posterUrl = posterPath != null ? '$_imageBaseUrl$posterPath' : '';

        latestMovies[title] = posterUrl;
      }

      return latestMovies;
    } else {
      throw Exception('Failed to load latest movies');
    }
  } catch (e) {
    throw Exception('Error fetching latest movies: $e');
  }
}*/



// Func: getLatestMovies
// Input: None
// Output: Map<string,string moviesList - Sized to 10;
// https://api.themoviedb.org/3/movie/now_playing
Future<Map<String, String>> getLatestMovies() async {
  return await getFilteredMovies([], 'available', '0', resultNum: 10);
}


// Func: getTopMovies
// Input: None
// Output: Map<string,string> moviesList - Sized to 10;
// https://api.themoviedb.org/3/movie/top_rated
Future<Map<String, String>> getTopMovies() async {
  try {
    final url = Uri.parse(
      '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=en-US&page=1&region=US',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      final Map<String, String> topMovies = {};

      for (var movie in results.take(10)) {
        final title = movie['title'] ?? 'Unknown';
        final posterPath = movie['poster_path'];
        final posterUrl = posterPath != null ? '$_imageBaseUrl$posterPath' : '';

        topMovies[title] = posterUrl;
      }

      return topMovies;
    } else {
      throw Exception('Failed to load top-rated movies');
    }
  } catch (e) {
    throw Exception('Error fetching top-rated movies: $e');
  }
}



// ========== Main Functions - Shows ==========

// Func: getShowEntry
// Input: Show name
// Output: Show object
Future<Show> getShowEntry(String inName) async {
  try {
    // Search for the show
    final searchUrl = Uri.parse(
      '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(inName)}',
    );
    final searchResponse = await http.get(searchUrl);

    if (searchResponse.statusCode != 200) {
      throw Exception('Failed to search for TV show.');
    }

    final searchResults = jsonDecode(searchResponse.body)['results'] as List;
    if (searchResults.isEmpty) {
      throw Exception('No TV show found with name: $inName');
    }

    final showId = searchResults.first['id'];

    // Get show details
    final showUrl = Uri.parse('$_baseUrl/tv/$showId?api_key=$_apiKey');
    final showResponse = await http.get(showUrl);

    if (showResponse.statusCode != 200) {
      throw Exception('Failed to get show details.');
    }

    final showData = jsonDecode(showResponse.body);
    final List seasons = showData['seasons'] ?? [];

    // Extract and convert season details
    final List<String> seasonsNames = [];
    final List<String> seasonsThumbnailsUrls = [];
    final List<String> seasonsAirDates = [];
    final List<int> seasonsEpisodeCounts = [];
    final List<String> seasonsOverviews = [];

    for (final season in seasons) {
      seasonsNames.add(season['name'] ?? 'N/A');
      seasonsThumbnailsUrls.add(
        season['poster_path'] != null ? '$_imageBaseUrl${season['poster_path']}' : '',
      );
      seasonsAirDates.add(season['air_date'] ?? 'N/A');
      seasonsEpisodeCounts.add(season['episode_count'] ?? 0);
      seasonsOverviews.add(season['overview'] ?? 'N/A');
    }

    return Show(
      name: showData['name'] ?? 'Unknown',
      thumbnailUrl: '$_imageBaseUrl${showData['poster_path'] ?? ''}',
      backdropUrl: '$_imageBaseUrl${showData['backdrop_path'] ?? ''}',
      rating: (showData['vote_average'] as num?)?.toDouble() ?? 0.0,

      releaseStatus: showData['status'] ?? 'Unknown',
      firstAir: showData['first_air_date'] ?? 'N/A',
      lastAir: showData['last_air_date'] ?? 'N/A',
      episodesNum: showData['number_of_episodes'] ?? 0,
      seasonsNum: showData['number_of_seasons'] ?? 0,
      genres: (showData['genres'] as List).map((g) => g['name'].toString()).toList(),
      overview: showData['overview'] ?? 'N/A',

      seasonsNames: seasonsNames,
      seasonsThumbnailsUrls: seasonsThumbnailsUrls,
      seasonsAirDates: seasonsAirDates,
      seasonsEpisodeCounts: seasonsEpisodeCounts,
      seasonsOverviews: seasonsOverviews,

      status: showData['status'] ?? 'Unknown',
      userRating: 0.0, // Initialize to 0.0, update via user input later ******************
    );
  } catch (e) {
    throw Exception('Error fetching show entry: $e');
  }
}

// Func: getFilteredShows
// Input: List<String> genres, String category, String minRating
// Output: Map<String, String> showsList - Sized to 20;
Future<Map<String, String>> getFilteredShows(List<String> inGenres, String inCategory, String inMinRating, {int resultNum = 20}) async {
  try {
    final genreIds = inGenres
        .where((g) => tvGenreToIDMap.containsKey(g))
        .map((g) => tvGenreToIDMap[g].toString())
        .join(',');

    final today = DateTime.now().toIso8601String().split('T').first;
    final baseUrl = '$_baseUrl/discover/tv';
    final params = {
      'api_key': _apiKey,
      'language': 'en-US',
      'sort_by': 'popularity.desc',
      'with_genres': genreIds,
      'vote_average.gte': inMinRating,
      'page': '1',
    };

    // Add filter based on category
    if (inCategory.toLowerCase() == 'upcoming') {
      params['first_air_date.gte'] = today;
    } else if (inCategory.toLowerCase() == 'available') {
      params['first_air_date.lte'] = today;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch filtered shows');
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List;

    final Map<String, String> showsList = {};

    for (final show in results.take(resultNum)) {
      final name = show['name'] ?? 'Unknown';
      final thumbnail = show['poster_path'] != null
          ? '$_imageBaseUrl${show['poster_path']}'
          : '';

      showsList[name] = thumbnail;
    }

    return showsList;
  } catch (e) {
    throw Exception('Error in getFilteredShows: $e');
  }
}




// Func: getUpcomingShows
// Input: None
// Output: Map<String, String> showsList - Sized to 10;
// https://api.themoviedb.org/3/discover/tv?first_air_date.gte=2025-06-04
Future<Map<String, String>> getUpcomingShows() async {
  return await getFilteredShows([], 'upcoming', '0', resultNum: 10);
}





/*
Future<Map<String, String>> getUpcomingShows() async {
  try {
    // Format today's date as YYYY-MM-DD manually
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final url = Uri.parse(
      '$_baseUrl/discover/tv?api_key=$_apiKey&language=en-US&sort_by=first_air_date.asc&first_air_date.gte=$todayStr&page=1&region=US',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      final Map<String, String> upcomingShows = {};

      for (var show in results.take(10)) {
        final name = show['name'] ?? 'Unknown';
        final posterPath = show['poster_path'];
        final posterUrl =
            posterPath != null ? '$_imageBaseUrl$posterPath' : '';

        upcomingShows[name] = posterUrl;
      }

      return upcomingShows;
    } else {
      throw Exception('Failed to load upcoming TV shows');
    }
  } catch (e) {
    throw Exception('Error fetching upcoming TV shows: $e');
  }
}

////////////////////////////

Future<Map<String, String>> getLatestShows() async {
  try {
    final url = Uri.parse(
      '$_baseUrl/discover/tv?api_key=$_apiKey&language=en-US&sort_by=first_air_date.desc&first_air_date.gte=2025-04-01&page=1&region=US',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      final Map<String, String> latestShows = {};

      for (var show in results.take(10)) {
        final name = show['name'] ?? 'Unknown';
        final posterPath = show['poster_path'];
        final posterUrl = posterPath != null ? '$_imageBaseUrl$posterPath' : '';

        latestShows[name] = posterUrl;
      }

      return latestShows;
    } else {
      throw Exception('Failed to load latest TV shows');
    }
  } catch (e) {
    throw Exception('Error fetching latest TV shows: $e');
  }
}

*/

// Func: getLatestShows
// Input: None
// Output: Map<String, String> showsList - Sized to 10;
// https://api.themoviedb.org/3/discover/tv?first_air_date.gte=2025-04-01
Future<Map<String, String>> getLatestShows() async {
  return await getFilteredShows([], 'available', '0', resultNum: 10);
}



// Func: getTopShows
// Input: None
// Output: Map<String, String> showsList - Sized to 10;
// API: https://api.themoviedb.org/3/tv/top_rated
Future<Map<String, String>> getTopShows() async {
  const String url = '$_baseUrl/tv/top_rated?api_key=$_apiKey&language=en-US&page=1';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch top-rated shows');
    }

    final data = jsonDecode(response.body);
    final List results = data['results'];

    final Map<String, String> showsList = {};

    for (final show in results.take(10)) {
      final name = show['name'] ?? 'Unknown';
      final thumbnail = show['poster_path'] != null
          ? '$_imageBaseUrl${show['poster_path']}'
          : '';

      showsList[name] = thumbnail;
    }

    return showsList;
  } catch (e) {
    throw Exception('Error in getTopShows: $e');
  }
}
