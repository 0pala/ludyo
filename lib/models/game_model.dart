class Game {
  final int id;
  final String coverUrl;
  final String? coverOriginalUrl;
  final String? name;
  final String? summary;
  final String? storyline;

  final double? rating;

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
