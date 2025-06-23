// ==================== TMDB API - Shows And Movies ==================== //

// Flutter imports
import 'dart:convert';
import 'package:http/http.dart' as http;

// Local imports
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/API/api_helpers.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Helper Functions ========== //

Future<Map<String, dynamic>> get(
  String path, {
  Map<String, String>? params,
}) async {
  final queryParameters = {
    'api_key': tmdbAPIKey,
    if (params != null) ...params,
  };

  final uri = Uri.parse(
    '$tmdbBaseUrl$path',
  ).replace(queryParameters: queryParameters);

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to load data from API. Status code: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Failed to make API request: $e');
  }
}

Show showFromJson(Map<String, dynamic> json) {
  final genreMap = {for (var genre in genresShows) genre['id']: genre['name']};
  final genreIds = List<int>.from(json['genre_ids'] ?? []);
  final filteredSeasons =
      (json['seasons'] as List?)
          ?.where((s) => s['season_number'] != 0)
          .toList() ??
      [];

  return Show(
    id: json['id'].toString(),
    name: json['name'] ?? 'N/A',
    thumbnailUrl:
        json['poster_path'] != null
            ? '$tmdbImageBaseUrl${json['poster_path']}'
            : tmdbMissingThumbnail,
    artworkUrl:
        json['backdrop_path'] != null
            ? '$tmdbImageBaseUrl${json['backdrop_path']}'
            : tmdbMissingPoster,
    rating: json['vote_average'].toString(),
    overview: json['overview'] ?? 'No overview available.',
    genres:
        json['genres'] != null
            ? List<String>.from(json['genres'].map((g) => g['name'].toString()))
            : genreIds
                .map((id) => genreMap[id] ?? 'Unknown')
                .cast<String>()
                .toList(),
    releaseStatus: json['status'] ?? 'N/A',
    firstAir: json['first_air_date'] ?? 'N/A',
    lastAir: json['last_air_date'] ?? 'N/A',
    episodesNum: json['number_of_episodes'] ?? 0,
    seasonsNum: json['number_of_seasons'] ?? 0,
    seasonsNames:
        filteredSeasons.map<String>((s) => s['name'].toString()).toList(),
    seasonsThumbnailsUrls:
        filteredSeasons
            .map<String>(
              (s) =>
                  s['poster_path'] != null
                      ? '$tmdbImageBaseUrl${s['poster_path']}'
                      : tmdbMissingThumbnail,
            )
            .toList(),
    seasonsAirDates:
        filteredSeasons
            .map<String>((s) => s['air_date']?.toString() ?? 'N/A')
            .toList(),
    seasonsEpisodeCounts:
        filteredSeasons.map<int>((s) => s['episode_count'] as int).toList(),
    seasonsOverviews:
        filteredSeasons
            .map<String>((s) => s['overview']?.toString() ?? 'N/A')
            .toList(),
    seasonsRatings:
        filteredSeasons
            .map<String>((s) => s['vote_average'].toString())
            .toList(),
  );
}

Movie movieFromJson(Map<String, dynamic> json) {
  final genreMap = {for (var genre in genresMovies) genre['id']: genre['name']};

  final genreNames =
      (json['genres'] as List?)
          ?.map((g) => genreMap[g['id']] ?? 'Unknown')
          .toList() ??
      [];

  return Movie(
    id: json['id'].toString(),
    name: json['title'] ?? 'N/A',
    thumbnailUrl:
        json['poster_path'] != null
            ? '$tmdbImageBaseUrl${json['poster_path']}'
            : tmdbMissingThumbnail,
    artworkUrl:
        json['backdrop_path'] != null
            ? '$tmdbImageBaseUrl${json['backdrop_path']}'
            : tmdbMissingPoster,
    rating: json['vote_average'].toString(),
    overview: json['overview'] ?? 'No overview available.',
    genres: genreNames.cast<String>(),
    releaseStatus: json['release_date'] ?? 'N/A',
    budget: json['budget']?.toString() ?? 'N/A',
    revenue: json['revenue']?.toString() ?? 'N/A',
  );
}

// ========== Main Functions - Shows ==========

Future<Show?> getShowEntry(String inID) async {
  final detailsData = await get(
    '/tv/$inID',
    params: {'append_to_response': 'seasons'},
  );

  return showFromJson(detailsData);
}

Future<List<Show?>> getShowsByIDs(List<String> ids) async {
  final futures = ids.map((id) => getShowEntry(id)).toList();
  return await Future.wait(futures);
}

Future<List<Show>> searchShowsByName(String query) async {
  final searchData = await get('/search/tv', params: {'query': query});
  final results = searchData['results'] as List;

  return results
      .where((json) => json['poster_path'] != null)
      .take(10)
      .map((json) => showFromJson(json))
      .toList();
}

Future<List<Show>> getFilteredShows(
  List<String> inGenres,
  String inCategory,
  String inMinRating,
) async {
  final genreIds =
      genresShows
          .where((genre) => inGenres.contains(genre['name']))
          .map((genre) => genre['id'].toString())
          .toList();

  final params = {
    'sort_by': inCategory,
    'vote_average.gte': inMinRating,
    'with_genres': genreIds.join(','),
    'vote_count.gte': '100',
  };

  final data = await get('/discover/tv', params: params);
  final results = data['results'] as List;
  return results.take(30).map((json) => showFromJson(json)).toList();
}

Future<List<Show>> _getShowList(String endpoint) async {
  final data = await get(endpoint);
  final results = data['results'] as List;
  return results.take(21).map((json) => showFromJson(json)).toList();
}

Future<List<Show>> getPopularShows() => _getShowList('/tv/popular');
Future<List<Show>> getAiringTodayShows() => _getShowList('/tv/airing_today');
Future<List<Show>> getOnTheAirShows() => _getShowList('/tv/on_the_air');
Future<List<Show>> getTopRatedShows() => _getShowList('/tv/top_rated');

// ========== Main Functions - Movies ==========

Future<Movie?> getMovieEntry(String inID) async {
  final detailsData = await get('/movie/$inID');

  return movieFromJson(detailsData);
}

Future<List<Movie?>> getMoviesByIDs(List<String> ids) async {
  final futures = ids.map((id) => getMovieEntry(id)).toList();
  return await Future.wait(futures);
}

Future<List<Movie>> searchMoviesByName(String query) async {
  final searchData = await get('/search/movie', params: {'query': query});
  final results = searchData['results'] as List;

  return results
      .where((json) => json['poster_path'] != null)
      .take(10)
      .map((json) => movieFromJson(json))
      .toList();
}

Future<List<Movie>> getFilteredMovies(
  List<String> inGenres,
  String inCategory,
  String inMinRating,
) async {
  final genreIds =
      genresMovies
          .where((genre) => inGenres.contains(genre['name']))
          .map((genre) => genre['id'].toString())
          .toList();

  final params = {
    'sort_by': inCategory,
    'vote_average.gte': inMinRating,
    'with_genres': genreIds.join(','),
    'vote_count.gte': '100',
  };

  final data = await get('/discover/movie', params: params);
  final results = data['results'] as List;
  return results.take(30).map((json) => movieFromJson(json)).toList();
}

Future<List<Movie>> _getMovieList(String endpoint) async {
  final data = await get(endpoint);
  final results = data['results'] as List;
  return results.take(21).map((json) => movieFromJson(json)).toList();
}

Future<List<Movie>> getPopularMovies() => _getMovieList('/movie/popular');
Future<List<Movie>> getTopRatedMovies() => _getMovieList('/movie/top_rated');

Future<List<Movie>> getUpcomingMovies() async {
  final today = DateTime.now().toIso8601String().split('T').first;

  final data = await get(
    '/discover/movie',
    params: {'primary_release_date.gte': today},
  );

  final results = data['results'] as List;
  return results.take(21).map((json) => movieFromJson(json)).toList();
}

Future<List<Movie>> getNowPlayingMovies() async {
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1, 1);
  final today = now.toIso8601String().split('T').first;
  final from = lastMonth.toIso8601String().split('T').first;

  final data = await get(
    '/discover/movie',
    params: {
      'primary_release_date.gte': from,
      'primary_release_date.lte': today,
    },
  );

  final results = data['results'] as List;
  return results.take(21).map((json) => movieFromJson(json)).toList();
}
