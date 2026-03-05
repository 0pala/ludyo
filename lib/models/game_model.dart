class Game {
  final int id;
  final String coverUrl;
  final String? coverOriginalUrl;
  final String? name;
  final String? summary;
  final String? storyline;

  final double? rating;

  /// PEGI rating from IGDB (category 2). Values: 1=3+, 2=7+, 3=12+, 4=16+, 5=18+.
  final int? pegi;

  /// Tutte le classificazioni restituite da IGDB (es. ["PEGI 16", "ESRB M"]).
  final List<String> ageRatingLabels;

  final int? firstReleaseDate;
  final int? gameType;

  final List<int> ageRatings;
  final List<int> dlcs;
  final List<int> remakes;
  final List<int> remasters;
  final List<int> similarGames;

  final int? franchise;
  final List<int> platforms;
  final List<int> genres;
  final List<int> themes;

  Game({
    required this.id,
    required this.coverUrl,
    this.coverOriginalUrl,
    this.name,
    this.summary,
    this.storyline,
    this.rating,
    this.pegi,
    this.ageRatingLabels = const [],
    this.firstReleaseDate,
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

  /// Etichetta leggibile per (category, rating) IGDB. category: 1=ESRB, 2=PEGI, 3=CERO, 4=USK, ecc.
  static String ageRatingLabel(int category, int ratingId) {
    switch (category) {
      case 1: // ESRB
        switch (ratingId) {
          case 7: return 'ESRB EC';
          case 8: return 'ESRB E';
          case 9: return 'ESRB E10+';
          case 10: return 'ESRB T';
          case 11: return 'ESRB M';
          case 12: return 'ESRB AO';
          default: return 'ESRB $ratingId';
        }
      case 2: // PEGI
        switch (ratingId) {
          case 1: return 'PEGI 3';
          case 2: return 'PEGI 7';
          case 3: return 'PEGI 12';
          case 4: return 'PEGI 16';
          case 5: return 'PEGI 18';
          case 6: return 'PEGI RP';
          default: return 'PEGI $ratingId';
        }
      case 3: return 'CERO $ratingId';
      case 4: return 'USK $ratingId';
      case 5: return 'GRAC $ratingId';
      case 6: return 'CLASS_IND $ratingId';
      case 7: return 'ACB $ratingId';
      default: return 'Rating $category:$ratingId';
    }
  }

  /// Restituisce l'etichetta PEGI leggibile (es. "PEGI 16") dal valore IGDB.
  static String pegiLabel(int? ratingId) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'storyline': storyline,
      'cover': coverUrl.isNotEmpty
          ? {'url': coverUrl.replaceFirst('https:', '').replaceFirst('t_cover_big', 't_thumb')}
          : null,
      'coverOriginal': coverUrl.isNotEmpty
          ? {'url': coverUrl.replaceFirst('https:', '').replaceFirst('t_original', 't_thumb')}
          : null,
      'total_rating': rating,
      'pegi': pegi,
      'age_rating_labels': ageRatingLabels,
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

    List<int> parseIdList(String key) {
      if (json[key] == null) return [];

      if (key == 'age_ratings' && json[key] is List) {
        final List list = json[key];

        if (list.isNotEmpty && list.first is Map) {
          return list.where((e) => e['rating'] != null).map<int>((e) => e['rating'] as int).toList();
        }
      }

      return List<int>.from(json[key]);
    }

    return Game(
      id: json['id'],
      name: json['name'],
      summary: json['summary'],
      storyline: json['storyline'],
      coverUrl: json['cover'] != null ? igdbImage(json['cover']['url']) : '',
      coverOriginalUrl: json['cover'] != null ? igdbOriginalImage(json['cover']['url']) : '',
      rating: json['total_rating'] != null ? (json['total_rating'] as num).toDouble() : null,
      pegi: json['pegi'] != null ? (json['pegi'] as num).toInt() : null,
      ageRatingLabels: json['age_rating_labels'] != null
          ? List<String>.from(json['age_rating_labels'] as List)
          : const [],
      firstReleaseDate: json['first_release_date'],
      gameType: json['game_type'],
      franchise: json['franchise'],
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
