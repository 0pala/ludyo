import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ludyo/auth/twitch_auth_service.dart';
import 'package:ludyo/models/game_model.dart';

class IgdbService {
  static const String _clientId = String.fromEnvironment('IGDB_CLIENT_ID');
  static const String _baseUrl = 'https://api.igdb.com/v4';
  final _authService = TwitchAuthService();

  Future<List<Game>> fetchPopularGames({int limit = 80}) async {
    final token = await _authService.getAccessToken();

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

    if (popularityList.isEmpty) {
      return [];
    }

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
        fields id, cover.url;
        where id = (${gameIds.join(',')});
        limit $limit;
      ''',
    );

    if (gameResponse.statusCode != 200) {
      throw Exception('Errore IGDB: ${gameResponse.statusCode}');
    }

    final List gamesJson = jsonDecode(gameResponse.body);
    final gamesMap = {for (final g in gamesJson) g['id']: Game.fromJson(g)};

    return gameIds.where(gamesMap.containsKey).map((e) => gamesMap[e]!).toList();
  }

  Future<List<Game>> fetchNewReleases({int days = 60, int limit = 80}) async {
    final token = await _authService.getAccessToken();

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final since = DateTime.now().subtract(Duration(days: days)).toUtc().millisecondsSinceEpoch ~/ 1000;

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
      where date >= $since & date <= $now;
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
      fields id, cover.url, first_release_date;
      where id = (${gameIds.join(',')});
      limit ${gameIds.length};
    ''',
    );

    if (gamesResponse.statusCode != 200) {
      throw Exception('Errore IGDB: ${gamesResponse.statusCode}');
    }

    final List gamesJson = jsonDecode(gamesResponse.body);
    final gamesMap = {for (final g in gamesJson) g['id']: Game.fromJson(g)};

    return gameIds.where(gamesMap.containsKey).map((e) => gamesMap[e]!).toList();
  }

  Future<List<Game>> fetchUpcomingGames({int daysAhead = 90, int limit = 80}) async {
    final token = await _authService.getAccessToken();

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final future = DateTime.now().add(Duration(days: daysAhead)).toUtc().millisecondsSinceEpoch ~/ 1000;

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
      fields id, cover.url, rating, first_release_date;
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

    return gameIds.where(gamesMap.containsKey).map((e) => gamesMap[e]!).toList();
  }

  Future<Game> fetchGameInfo(int id) async {
    final token = await _authService.getAccessToken();

    final gameResponse = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': _clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body:
          '''
        fields id, name, cover.url, age_ratings, dlcs, first_release_date, franchise, platforms, genres, remakes, remasters, similar_games, themes, total_rating, game_type, storyline, summary;
        where id = ($id);
      ''',
    );

    if (gameResponse.statusCode != 200) {
      throw Exception('Error: ${gameResponse.statusCode}');
    }

    final gameJson = jsonDecode(gameResponse.body);

    if (gameJson.isEmpty) {
      throw Exception('Error: Game not found');
    }

    final Map<String, dynamic> gameMap = gameJson is List ? gameJson.first : gameJson;
    final Game game = Game.fromJson(gameMap);

    return game;
  }
}
