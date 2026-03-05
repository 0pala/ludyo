import 'package:intl/intl.dart';

class Game {
  final int id;

  final String coverUrl;
  final String coverOriginalUrl;
  final String name;
  final String summary;
  final String rating;
  final String firstReleaseDate;

  final List<String> ageRatingLabels;
  final String pegi;

  final int? gameType;
  final int? franchise;

  final List<int> ageRatings;
  final List<int> dlcs;
  final List<int> remakes;
  final List<int> remasters;
  final List<int> similarGames;
  final List<int> platforms;
  final List<int> genres;
  final List<int> themes;

  Game({
    required this.id,
    required this.coverUrl,
    required this.coverOriginalUrl,
    required this.name,
    required this.summary,
    required this.rating,
    required this.firstReleaseDate,
    required this.ageRatingLabels,
    required this.pegi,
    this.gameType,
    this.franchise,
    this.ageRatings = const [],
    this.dlcs = const [],
    this.remakes = const [],
    this.remasters = const [],
    this.similarGames = const [],
    this.platforms = const [],
    this.genres = const [],
    this.themes = const [],
  });

  static String ageRatingLabel(int category, int ratingId) {
    switch (category) {
      case 1:
        switch (ratingId) {
          case 7:
            return 'ESRB EC';
          case 8:
            return 'ESRB E';
          case 9:
            return 'ESRB E10+';
          case 10:
            return 'ESRB T';
          case 11:
            return 'ESRB M';
          case 12:
            return 'ESRB AO';
          default:
            return 'ESRB $ratingId';
        }
      case 2:
        switch (ratingId) {
          case 1:
            return 'PEGI 3+';
          case 2:
            return 'PEGI 7+';
          case 3:
            return 'PEGI 12+';
          case 4:
            return 'PEGI 16+';
          case 5:
            return 'PEGI 18+';
          case 6:
            return 'PEGI RP';
          default:
            return 'PEGI $ratingId';
        }
      case 3:
        return 'CERO $ratingId';
      case 4:
        return 'USK $ratingId';
      case 5:
        return 'GRAC $ratingId';
      case 6:
        return 'CLASS_IND $ratingId';
      case 7:
        return 'ACB $ratingId';
      default:
        return 'Rating $category:$ratingId';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'cover': coverUrl.isNotEmpty
          ? {
              'url': coverUrl
                  .replaceFirst('https:', '')
                  .replaceFirst('t_cover_big', 't_thumb'),
            }
          : null,
      'coverOriginal': coverUrl.isNotEmpty
          ? {
              'url': coverUrl
                  .replaceFirst('https:', '')
                  .replaceFirst('t_original', 't_thumb'),
            }
          : null,
      'total_rating': rating,
      'age_rating_labels': ageRatingLabels,
      'pegi': pegi,
      'first_release_date': firstReleaseDate,
      'game_type': gameType,
      'franchise': franchise,
      'age_ratings': ageRatings,
      'dlcs': dlcs,
      'remakes': remakes,
      'remasters': remasters,
      'similar_games': similarGames,
      'platforms': platforms,
      'genres': genres,
      'themes': themes,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    String igdbImage(String url, {String size = 't_cover_big'}) {
      return 'https:$url'.replaceFirst('t_thumb', size);
    }

    String igdbOriginalImage(String url, {String size = 't_original'}) {
      return 'https:$url'.replaceFirst('t_thumb', size);
    }

    String ratingToString(double r) {
      final String stringRating = (r / 10).toStringAsFixed(1);
      return '$stringRating / 10 ⭐';
    }

    String firstReleaseDateToString(int d) {
      final date = DateTime.fromMillisecondsSinceEpoch(d * 1000);
      return DateFormat('dd/MM/yyyy').format(date);
    }

    String pegiLabel(int? ratingId) {
      if (ratingId == null) return '—';
      switch (ratingId) {
        case 1:
          return 'PEGI 3';
        case 2:
          return 'PEGI 7';
        case 3:
          return 'PEGI 12';
        case 4:
          return 'PEGI 16';
        case 5:
          return 'PEGI 18';
        case 6:
          return 'RP';
        default:
          return 'PEGI $ratingId';
      }
    }

    List<int> parseIdList(String key) {
      final data = json[key];
      if (data == null || data is! List) return [];

      if (key == 'age_ratings') {
        return data
            .map<int?>((e) {
              if (e is Map && e['rating'] != null) {
                final r = e['rating'];
                if (r is int) return r;
                if (r is String) return int.tryParse(r);
              }
              return null;
            })
            .whereType<int>()
            .toList();
      }

      return data
          .map<int?>((e) {
            if (e is int) return e;
            if (e is String) return int.tryParse(e);
            return null;
          })
          .whereType<int>()
          .toList();
    }

    return Game(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,

      name: json['name'] ?? 'No name found',
      summary: json['summary'] ?? 'No description found',
      coverUrl: json['cover'] != null ? igdbImage(json['cover']['url']) : '',

      coverOriginalUrl: json['cover'] != null
          ? igdbOriginalImage(json['cover']['url'])
          : '',

      rating: json['total_rating'] == null
          ? 'N/A'
          : json['total_rating'] is num
          ? ratingToString((json['total_rating'] as num).toDouble())
          : json['total_rating'].toString(),

      pegi: json['pegi'] is int
          ? pegiLabel(json['pegi'])
          : json['pegi']?.toString() ?? '—',

      ageRatingLabels: json['age_rating_labels'] != null
          ? List<String>.from(json['age_rating_labels'] as List)
          : const [],

      firstReleaseDate: json['first_release_date'] == null
          ? 'N/A'
          : json['first_release_date'] is int
          ? firstReleaseDateToString(json['first_release_date'])
          : json['first_release_date'].toString(),

      gameType: json['game_type'] is int
          ? json['game_type']
          : int.tryParse(json['game_type']?.toString() ?? '') ?? 0,

      franchise: json['franchise'] is int
          ? json['franchise']
          : int.tryParse(json['franchise']?.toString() ?? '') ?? 0,

      ageRatings: parseIdList('age_ratings'),
      dlcs: parseIdList('dlcs'),
      remakes: parseIdList('remakes'),
      remasters: parseIdList('remasters'),
      similarGames: parseIdList('similar_games'),
      platforms: parseIdList('platforms'),
      genres: parseIdList('genres'),
      themes: parseIdList('themes'),
    );
  }
}
