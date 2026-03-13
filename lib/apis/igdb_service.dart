import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:ludyo/auth/twitch_auth_service.dart';
import 'package:ludyo/models/game_model.dart';
import 'package:ludyo/utils/api_cache_manager.dart';

class IgdbService {
  static const String _clientId = String.fromEnvironment('IGDB_CLIENT_ID');
  static const String _baseUrl = 'https://api.igdb.com/v4';
  final _authService = TwitchAuthService();
  final cache = ApiCacheManager();

  Future<List<Game>> fetchPopularGames({int limit = 80}) async {
    final token = await _authService.getAccessToken();

    final cacheKey = 'PopularGames_$limit';
    final cached = cache.get(cacheKey);

    if (cached != null) {
      return (cached as List).map((e) => Game.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    final popularityResponse = await http.post(
      Uri.parse('$_baseUrl/popularity_primitives'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
        fields game_id, value;
        sort value desc;
        limit $limit;
      ''',
    );

    if (popularityResponse.statusCode != 200) {
      throw Exception('Errore IGDB: ${popularityResponse.statusCode}');
    }

    final List popularityList = jsonDecode(popularityResponse.body);
    if (popularityList.isEmpty) return [];

    final gameIds = popularityList.map((e) => e['game_id']).whereType<int>().toSet().toList();

    final gameResponse = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
        fields id, name, cover.url;
        where id = (${gameIds.join(',')});
        limit $limit;
      ''',
    );

    if (gameResponse.statusCode != 200) {
      throw Exception('Errore IGDB: ${gameResponse.statusCode}');
    }

    final List gamesJson = jsonDecode(gameResponse.body);
    final gamesMap = {for (final g in gamesJson) g['id']: Game.fromJson(g)};

    await cache.save(
      cacheKey,
      gameIds.where(gamesMap.containsKey).map((e) => gamesMap[e]!.toJson()).toList(),
      const Duration(days: 7),
    );

    return gameIds.where(gamesMap.containsKey).map((e) => gamesMap[e]!).toList();
  }

  Future<List<Game>> fetchNewReleases({int days = 60, int limit = 80}) async {
    final token = await _authService.getAccessToken();

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final since = DateTime.now().subtract(Duration(days: days)).toUtc().millisecondsSinceEpoch ~/ 1000;

    final cacheKey = 'NewReleases_${days}_$limit';
    final cached = cache.get(cacheKey);

    if (cached != null) {
      return (cached as List).map((e) => Game.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
      fields id, name, cover.url, first_release_date;
      where first_release_date >= $since & first_release_date <= $now;
      sort first_release_date desc;
      limit $limit;
    ''',
    );

    if (response.statusCode != 200) {
      throw Exception('Errore IGDB: ${response.statusCode}');
    }

    final List gamesJson = jsonDecode(response.body);

    final games = gamesJson.map<Game>((e) => Game.fromJson(Map<String, dynamic>.from(e))).toList();

    await cache.save(
      cacheKey,
      games.map((g) => g.toJson()).toList(),
      const Duration(hours: 24),
    );

    return games;
  }

  Future<List<Game>> fetchUpcomingGames({int daysAhead = 90, int limit = 80}) async {
    final token = await _authService.getAccessToken();

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final future = DateTime.now().add(Duration(days: daysAhead)).toUtc().millisecondsSinceEpoch ~/ 1000;

    final cacheKey = 'UpcomingGames_${daysAhead}_$limit';
    final cached = cache.get(cacheKey);

    if (cached != null) {
      return (cached as List).map((e) => Game.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    final releaseResponse = await http.post(
      Uri.parse('$_baseUrl/release_dates'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
      fields game;
      where date > $now & date <= $future;
      limit $limit;
    ''',
    );

    if (releaseResponse.statusCode != 200) {
      throw Exception('Errore IGDB: ${releaseResponse.statusCode}');
    }

    final List releaseList = jsonDecode(releaseResponse.body);

    final gameIds = releaseList.map((e) => e['game']).whereType<int>().toSet().toList();

    if (gameIds.isEmpty) return [];

    final gamesResponse = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
      fields id, name, cover.url, rating, first_release_date;
      where id = (${gameIds.join(',')});
      sort rating desc;
      limit ${gameIds.length};
    ''',
    );

    if (gamesResponse.statusCode != 200) {
      throw Exception('Errore IGDB: ${gamesResponse.statusCode}');
    }

    final List gamesJson = jsonDecode(gamesResponse.body);
    final gamesMap = {for (final g in gamesJson) g['id']: Game.fromJson(g)};

    await cache.save(
      cacheKey,
      gameIds.where(gamesMap.containsKey).map((e) => gamesMap[e]!.toJson()).toList(),
      const Duration(hours: 24),
    );

    return gameIds.where(gamesMap.containsKey).map((e) => gamesMap[e]!).toList();
  }

  Future<Game> fetchGameInfo(int id) async {
    final token = await _authService.getAccessToken();

    final cacheKey = 'Game: $id';
    final cached = cache.get(cacheKey);

    if (cached != null) return Game.fromJson(Map<String, dynamic>.from(cached));

    final gameResponse = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
        fields id, name, cover.url, age_ratings.rating, age_ratings.category, first_release_date, total_rating, summary;
        where id = ($id);
      ''',
      // body:
      //     '''
      //   fields id, name, cover.url, age_ratings.rating, age_ratings.category, dlcs, first_release_date, franchise, platforms, genres, remakes, remasters, similar_games, themes, total_rating, game_type, storyline, summary;
      //   where id = ($id);
      // ''',
    );

    if (gameResponse.statusCode != 200) {
      throw Exception('Error: ${gameResponse.statusCode}');
    }

    final List gameJson = jsonDecode(gameResponse.body);

    if (gameJson.isEmpty) {
      throw Exception('Error: Game not found');
    }

    final Map<String, dynamic> gameMap = gameJson.first;

    final rawAgeRatings = gameMap['age_ratings'];
    // Debug: stampa raw age_ratings dalla risposta /games
    log(
      '[IGDB] game ${gameMap['id']} ${gameMap['name']} — age_ratings raw: $rawAgeRatings',
    );

    final List<String> allLabels = [];
    if (rawAgeRatings != null && rawAgeRatings is List && rawAgeRatings.isNotEmpty) {
      final first = rawAgeRatings.first;
      if (first is Map && first.containsKey('category')) {
        // già espansi (oggetti con category/rating)
        for (var rating in rawAgeRatings) {
          if (rating is Map && rating['category'] != null && rating['rating'] != null) {
            final cat = (rating['category'] as num).toInt();
            final r = (rating['rating'] as num).toInt();
            if (cat == 2) {
              allLabels.add(Game.ageRatingLabel(2, r));
              gameMap['pegi'] = r;
            }
          }
        }
        log(
          '[IGDB] age_ratings espansi → labels: $allLabels, pegi: ${gameMap['pegi']}',
        );
      } else {
        // lista di ID (int) oppure oggetti {id: ...} come da /games
        final ids = <int>[];
        for (var e in rawAgeRatings) {
          if (e is int) {
            ids.add(e);
          } else if (e is Map && e['id'] != null) {
            ids.add((e['id'] as num).toInt());
          }
        }
        log('[IGDB] age_ratings come ID → fetch /age_ratings per id = $ids');
        if (ids.isNotEmpty) {
          // API attuale: category/rating sono deprecati; usare organization + rating_category
          final arResponse = await http.post(
            Uri.parse('$_baseUrl/age_ratings'),
            headers: {
              'Client-ID': _clientId,
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: 'fields id, organization, rating_category; where id = (${ids.join(',')});',
          );
          log(
            '[IGDB] /age_ratings status: ${arResponse.statusCode}, body: ${arResponse.body}',
          );
          if (arResponse.statusCode == 200) {
            final List arList = jsonDecode(arResponse.body);
            int? refToId(dynamic ref) {
              if (ref == null) return null;
              if (ref is num) return ref.toInt();
              if (ref is Map && ref['id'] != null) {
                return (ref['id'] as num).toInt();
              }
              return null;
            }

            final categoryIds = arList
                .where(
                  (ar) => ar is Map && refToId(ar['rating_category']) != null,
                )
                .map<int>((ar) => refToId(ar['rating_category'])!)
                .toSet()
                .toList();
            final Map<int, String> categoryIdToRating = {};
            if (categoryIds.isNotEmpty) {
              final catResponse = await http.post(
                Uri.parse('$_baseUrl/age_rating_categories'),
                headers: {
                  'Client-ID': _clientId,
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
                body: 'fields id, organization, rating; where id = (${categoryIds.join(',')});',
              );
              if (catResponse.statusCode == 200) {
                final List catList = jsonDecode(catResponse.body);
                for (var c in catList) {
                  if (c is Map && c['id'] != null && c['rating'] != null) {
                    categoryIdToRating[(c['id'] as num).toInt()] = (c['rating'] as String).trim();
                  }
                }
              }
            }
            final pegiRatingToValue = {
              '3': 1,
              '7': 2,
              '12': 3,
              '16': 4,
              '18': 5,
              'RP': 6,
            };
            for (var ar in arList) {
              if (ar is Map && ar['organization'] != null) {
                final org = (ar['organization'] is num)
                    ? (ar['organization'] as num).toInt()
                    : (ar['organization'] is Map && ar['organization']['id'] != null)
                    ? (ar['organization']['id'] as num).toInt()
                    : null;
                if (org == null) continue;
                final catId = refToId(ar['rating_category']);
                final ratingStr = catId != null ? categoryIdToRating[catId] : null;
                if (org != 2) continue; // solo PEGI
                final label = ratingStr != null && ratingStr.isNotEmpty ? 'PEGI $ratingStr' : 'PEGI';
                allLabels.add(label);
                if (ratingStr != null) {
                  gameMap['pegi'] = pegiRatingToValue[ratingStr] ?? pegiRatingToValue[ratingStr.toUpperCase()];
                }
              }
            }
            log(
              '[IGDB] /age_ratings parsed → labels: $allLabels, pegi: ${gameMap['pegi']}',
            );
          }
        }
      }
    }
    gameMap['age_rating_labels'] = allLabels;

    final Game game = Game.fromJson(gameMap);

    await cache.save(
      cacheKey,
      game.toJson(),
      const Duration(days: 7),
    );

    return game;
  }

  Future<List<Game>> fetchSearchedGames(String searchText, {int limit = 80}) async {
    final token = await _authService.getAccessToken();

    final cacheKey = 'Search: $searchText';
    final cached = cache.get(cacheKey);

    if (cached != null) {
      return (cached as List).map((e) => Game.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    final searchResponse = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
      search "$searchText";
      fields id, name, cover.url, first_release_date;
      limit $limit;
    ''',
    );

    if (searchResponse.statusCode != 200) {
      throw Exception('Errore IGDB: ${searchResponse.statusCode}');
    }

    final List gamesJson = jsonDecode(searchResponse.body);
    if (gamesJson.isEmpty) return [];

    final games = gamesJson.map((e) => Game.fromJson(e)).toList();

    await cache.save(
      cacheKey,
      games.map((g) => g.toJson()).toList(),
      const Duration(hours: 6),
    );

    return games;
  }
}
