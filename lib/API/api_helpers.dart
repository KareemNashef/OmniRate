// ==================== Helper data for API calls ==================== //

// Flutter imports
import 'dart:async';

// ========== IGDB Constants ========== //

// API Keys
final igdbHeaders = {
  'Client-ID': 'uy1ewiwcafvxgao5jq3bxhme0z20tx',
  'Authorization': 'Bearer 2bf4mjgv69yeh7buax0ijizt6bsg5u',
  'Accept': 'application/json',
};

// API URLs
const String gamesAPIUrl = 'https://api.igdb.com/v4/games';
const String gamesReleaseDateUrl = 'https://api.igdb.com/v4/release_dates';
const String gamesCoverArtUrl = 'https://api.igdb.com/v4/covers';
const String gamesTimeUrl = 'https://api.igdb.com/v4/game_time_to_beats';
const String gamesInvolvedCompaniesUrl =
    'https://api.igdb.com/v4/involved_companies';
const String gamesCompanyNamesUrl = 'https://api.igdb.com/v4/companies';
const String gamesArtworksUrl = 'https://api.igdb.com/v4/artworks';
const String gamesPopscoreUrl = 'https://api.igdb.com/v4/popularity_primitives';

// Common fields for list queries
const String gamesCommonListFields =
    'id, name, cover, rating, first_release_date, genres.name, summary, involved_companies, artworks, similar_games, dlcs, expansions';

// Missing media URLs
const String gamesMissingCoverUrl =
    'https://www.igdb.com/assets/no_cover_show-ef1e36c00e101c2fb23d15bb80edd9667bbf604a12fc0267a66033afea320c65.png';
const String gamesMissingArtworkUrl =
    'https://img.freepik.com/free-vector/futuristic-video-game-controller-background-with-text-space_1017-54730.jpg';

// ========== TMDB Constants ========== //

// API Base URLs
const String tmdbAPIKey = 'b0660f1133aa5458af9be7244a2988ee';
const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

// Missing images
const String tmdbMissingThumbnail =
    'https://assets.lummi.ai/assets/QmRBMLRX4YkvnCCrjMee3eSE8z9ZUEh3DWtakKxT7S3hxi?auto=format&w=1500';
const String tmdbMissingPoster =
    'https://assets.lummi.ai/assets/QmXezP9Asjqf3qZzgUibFNz1ysgKeDZ5G1yDGkbYGt9feR?auto=format&w=1500';

// ========== EagerFuture Class ========== //

class EagerFuture<T> implements Future<T> {
  final Future<T> _future;

  late T _result;
  Object? _error;

  bool _isCompleted = false;
  bool _hasError = false;

  EagerFuture(Future<T> future) : _future = future {
    // Eagerly start listening and store result or error
    _future
        .then((value) {
          _result = value;
          _isCompleted = true;
        })
        .catchError((error, stackTrace) {
          _error = error;
          _hasError = true;
          _isCompleted = true;
        });
  }

  @override
  Stream<T> asStream() => _future.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    if (_isCompleted) {
      if (!_hasError) {
        // Already completed successfully
        try {
          return Future.value(onValue(_result));
        } catch (e, s) {
          if (onError != null) {
            try {
              return Future.value(onError(e, s));
            } catch (ne, ns) {
              return Future.error(ne, ns);
            }
          }
          return Future.error(e, s);
        }
      } else {
        // Already completed with error
        if (onError != null) {
          try {
            return Future.value(onError(_error!, StackTrace.current));
          } catch (e, s) {
            return Future.error(e, s);
          }
        }
        return Future.error(_error!);
      }
    }

    // Not completed yet, delegate to original future
    return _future.then(onValue, onError: onError);
  }

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);
}

// ========== Rate Limiting Class ========== //

class RateLimiter {
  static const int maxRequestsPerSecond = 4;
  static final List<DateTime> _requestTimes = [];

  // Ensures no more than [maxRequestsPerSecond] occur per second.
  static Future<void> waitForRateLimit() async {
    final now = DateTime.now();

    // Remove timestamps older than 1 second
    _requestTimes.removeWhere(
      (time) => now.difference(time).inMilliseconds > 1000,
    );

    // If limit reached, delay until safe to proceed
    if (_requestTimes.length >= maxRequestsPerSecond) {
      final waitTime =
          1000 - now.difference(_requestTimes.first).inMilliseconds;
      if (waitTime > 0) {
        await Future.delayed(Duration(milliseconds: waitTime));
      }
    }

    _requestTimes.add(DateTime.now());
  }
}
