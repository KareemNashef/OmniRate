// ==================== TMDB API - Shows And Movies ==================== //

// Flutter imports
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Local imports
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Helper Consts ==========

const String _apiKey = 'b0660f1133aa5458af9be7244a2988ee';
const String _apiBaseUrl = 'https://api.themoviedb.org/3';
const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

// A cache for genre IDs to genre names.
final Map<int, String> _tvGenreMap = {
  for (var genre in genresShows) genre['id'] as int: genre['name'] as String,
};
final Map<int, String> _movieGenreMap = {
  for (var genre in genresMovies) genre['id'] as int: genre['name'] as String,
};

// ========== Private Helper Functions ==========

// Generic function to make a GET request to the TMDB API.
Future<Map<String, dynamic>> _get(
  String path, {
  Map<String, String>? params,
}) async {
  final queryParameters = {'api_key': _apiKey, if (params != null) ...params};

  final uri = Uri.parse(
    '$_apiBaseUrl$path',
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

// Maps a list of genre IDs to a list of genre names using the pre-populated maps.
List<String> _mapGenreIdsToNames(List<dynamic> genreIds, String type) {
  final map = type == 'tv' ? _tvGenreMap : _movieGenreMap;
  return genreIds.map((id) => map[id] ?? 'Unknown').toList();
}

// Creates a Show object from a JSON map.
Show _showFromJson(Map<String, dynamic> json) {
final filteredSeasons = (json['seasons'] as List?)
    ?.where((s) => s['season_number'] != 0)
    .toList() ?? [];

return Show(
  name: json['name'] ?? 'N/A',
  thumbnailUrl: json['poster_path'] != null
      ? '$_imageBaseUrl${json['poster_path']}'
      : '',
  artworkUrl: json['backdrop_path'] != null
      ? '$_imageBaseUrl${json['backdrop_path']}'
      : '',
  rating: (json['vote_average'] ?? 0.0).toDouble(),
  overview: json['overview'] ?? 'No overview available.',
  genres: json['genres'] != null
      ? List<String>.from(json['genres'].map((g) => g['name']))
      : _mapGenreIdsToNames(json['genre_ids'] ?? [], 'tv'),
  releaseStatus: json['status'] ?? 'N/A',
  firstAir: json['first_air_date'] ?? 'N/A',
  lastAir: json['last_air_date'] ?? 'N/A',
  episodesNum: json['number_of_episodes'] ?? 0,
  seasonsNum: json['number_of_seasons'] ?? 0,
  seasonsNames:
      filteredSeasons.map<String>((s) => s['name'].toString()).toList(),
  seasonsThumbnailsUrls: filteredSeasons
      .map<String>((s) => s['poster_path'] != null
          ? '$_imageBaseUrl${s['poster_path']}'
          : '')
      .toList(),
  seasonsAirDates: filteredSeasons
      .map<String>((s) => s['air_date']?.toString() ?? 'N/A')
      .toList(),
  seasonsEpisodeCounts: filteredSeasons
      .map<int>((s) => s['episode_count'] as int)
      .toList(),
  seasonsOverviews: filteredSeasons
      .map<String>((s) => s['overview']?.toString() ?? 'N/A')
      .toList(),
  seasonsRatings: filteredSeasons
      .map<String>((s) => (s['vote_average'].toString()))
      .toList(),
);
}

// Creates a Movie object from a JSON map (from TMDB API).
Movie _movieFromJson(Map<String, dynamic> json) {
  return Movie(
    name: json['title'] ?? 'N/A',
    thumbnailUrl:
        json['poster_path'] != null
            ? '$_imageBaseUrl${json['poster_path']}'
            : 'https://burst.shopifycdn.com/photos/a-sliver-of-film-reel-curls-around-a-camera-sprocket.jpg?width=373&format=pjpg&exif=0&iptc=0',
    artworkUrl:
        json['backdrop_path'] != null
            ? '$_imageBaseUrl${json['backdrop_path']}'
            : 'https://burst.shopifycdn.com/photos/spilled-popcorn-on-a-red-background.jpg?width=373&format=pjpg&exif=0&iptc=0',
    rating: (json['vote_average'] ?? 0.0).toDouble(),
    overview: json['overview'] ?? 'No overview available.',
    genres:
        json['genres'] != null
            ? List<String>.from(json['genres'].map((g) => g['name']))
            : _mapGenreIdsToNames(json['genre_ids'] ?? [], 'movie'),
    releaseStatus: json['release_date'] ?? 'N/A',
    budget: (json['budget'] ?? 0).toString(),
    revenue: (json['revenue'] ?? 0).toString(),
  );
}

// ========== Main Functions - Shows ==========

Future<Show?> getShowEntry(String inName) async {
  try {
    final searchData = await _get('/search/tv', params: {'query': inName});
    if ((searchData['results'] as List).isEmpty) return null;

    final showId = searchData['results'][0]['id'];
    final detailsData = await _get(
      '/tv/$showId',
      params: {'append_to_response': 'seasons'},
    );

    return _showFromJson(detailsData);
  } catch (e) {
    print('Error in getShowEntry: $e');
    return null;
  }
}

Future<List<Show>> searchShowsByName(
  String query,
) async {
  try {
    final searchData = await _get('/search/tv', params: {'query': query});
    final results = searchData['results'] as List;

    return results
        .where((json) => json['poster_path'] != null)
        .take(10)
        .map((json) => _showFromJson(json))
        .toList();
  } catch (e) {
    print('Error in searchShows: $e');
    return [];
  }
}

Future<List<Show>> getFilteredShows(
  List<String> inGenres,
  String inCategory,
  String inMinRating,
) async {
  try {
    final genreIds =
        _tvGenreMap.entries
            .where((entry) => inGenres.contains(entry.value))
            .map((entry) => entry.key.toString())
            .toList();

    final params = {
      'sort_by': inCategory,
      'vote_average.gte': inMinRating,
      'with_genres': genreIds.join(','),
      'vote_count.gte': '100',
    };

    final data = await _get('/discover/tv', params: params);
    final results = data['results'] as List;
    return results.take(20).map((json) => _showFromJson(json)).toList();
  } catch (e) {
    print('Error in getFilteredShows: $e');
    return [];
  }
}

Future<List<Show>> _getShowList(String endpoint) async {
  try {
    // === CHANGED: No need to await genre initialization ===
    final data = await _get(endpoint);
    final results = data['results'] as List;
    return results.take(10).map((json) => _showFromJson(json)).toList();
  } catch (e) {
    print('Error fetching show list from $endpoint: $e');
    return [];
  }
}

Future<List<Show>> getPopularShows() => _getShowList('/tv/popular');
Future<List<Show>> getAiringTodayShows() => _getShowList('/tv/airing_today');
Future<List<Show>> getOnTheAirShows() => _getShowList('/tv/on_the_air');
Future<List<Show>> getTopRatedShows() => _getShowList('/tv/top_rated');

// ========== Main Functions - Movies ==========

Future<Movie?> getMovieEntry(String inName) async {
  try {
    final searchData = await _get('/search/movie', params: {'query': inName});
    if ((searchData['results'] as List).isEmpty) return null;

    final movieId = searchData['results'][0]['id'];
    final detailsData = await _get('/movie/$movieId');

    return _movieFromJson(detailsData);
  } catch (e) {
    print('Error in getMovieEntry: $e');
    return null;
  }
}

Future<List<Movie>> searchMoviesByName(
  String query,
) async {
  try {
    final searchData = await _get('/search/movie', params: {'query': query});
    final results = searchData['results'] as List;

    return results
        .where((json) => json['poster_path'] != null)
        .take(10)
        .map((json) => _movieFromJson(json))
        .toList();
  } catch (e) {
    print('Error in searchMovies: $e');
    return [];
  }
}

Future<List<Movie>> getFilteredMovies(
  List<String> inGenres,
  String inCategory,
  String inMinRating,
) async {
  try {
    final genreIds =
        _movieGenreMap.entries
            .where((entry) => inGenres.contains(entry.value))
            .map((entry) => entry.key.toString())
            .toList();

    final params = {
      'sort_by': inCategory,
      'vote_average.gte': inMinRating,
      'with_genres': genreIds.join(','),
      'vote_count.gte': '100',
    };

    final data = await _get('/discover/movie', params: params);
    final results = data['results'] as List;
    return results.take(20).map((json) => _movieFromJson(json)).toList();
  } catch (e) {
    print('Error in getFilteredMovies: $e');
    return [];
  }
}

Future<List<Movie>> _getMovieList(String endpoint) async {
  try {
    final data = await _get(endpoint);
    final results = data['results'] as List;
    return results.take(10).map((json) => _movieFromJson(json)).toList();
  } catch (e) {
    print('Error fetching movie list from $endpoint: $e');
    return [];
  }
}

Future<List<Movie>> getPopularMovies() => _getMovieList('/movie/popular');
Future<List<Movie>> getTopRatedMovies() => _getMovieList('/movie/top_rated');

Future<List<Movie>> getUpcomingMovies() async {
  final today = DateTime.now().toIso8601String().split('T').first;

  try {
    final data = await _get(
      '/discover/movie',
      params: {'primary_release_date.gte': today},
    );

    final results = data['results'] as List;
    return results.take(10).map((json) => _movieFromJson(json)).toList();
  } catch (e) {
    print('Error fetching upcoming movies: $e');
    return [];
  }
}

Future<List<Movie>> getNowPlayingMovies() async {
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1, 1);
  final today = now.toIso8601String().split('T').first;
  final from = lastMonth.toIso8601String().split('T').first;

  try {
    final data = await _get(
      '/discover/movie',
      params: {
        'primary_release_date.gte': from,
        'primary_release_date.lte': today,
      },
    );

    final results = data['results'] as List;
    return results.take(10).map((json) => _movieFromJson(json)).toList();
  } catch (e) {
    print('Error fetching now playing movies: $e');
    return [];
  }
}
