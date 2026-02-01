import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:ludyo/apis/igdb_service.dart';
import 'package:ludyo/models/game_model.dart';

class GameInfoPage extends StatefulWidget {
  final int gameId;

  const GameInfoPage({
    super.key,
    required this.gameId,
  });

  @override
  State<GameInfoPage> createState() => _GameInfoPageState();
}

class _GameInfoPageState extends State<GameInfoPage> {
  final IgdbService igdb = IgdbService();
  late Future<Game> game;

  // Map<int, String> pegiRatings = {
  //   81042: '3+',
  //   228241: '7+',
  //   3: '12+',
  //   4: '16+',
  //   5: '18+',
  // };

  @override
  void initState() {
    super.initState();
    game = igdb.fetchGameInfo(widget.gameId);
  }

  // String getPegiRating(List<int> ids) {
  //   if (ids.isNotEmpty) {
  //     for (var id in ids) {
  //       if (pegiRatings.containsKey(id)) {
  //         return pegiRatings[id]!;
  //       }
  //     }
  //   }
  //   return 'N/A';
  // }

  String ratingToString(double r) {
    final String stringRating = (r / 10).toStringAsFixed(1);
    return stringRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        surfaceTintColor: Theme.of(context).colorScheme.onPrimary,
        leading: const BackButton(),
      ),
      body: FutureBuilder(
        future: game,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final game = snapshot.data!;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: CachedNetworkImage(
                          imageUrl: game.coverUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error),
                              SizedBox(height: 8),
                              Text(
                                'Error: Game cover not found',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 1.375,
                alignment: Alignment.topCenter,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SizedBox(
                          width: 100,
                          height: 30,
                          child: Center(
                            child: Text(
                              '${ratingToString(game.rating ?? 0)} / 10 ⭐',
                            ),
                          ),
                        ),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SizedBox(
                          width: 100,
                          height: 30,
                          child: Center(
                            child: Text(
                              game.ageRatings.isNotEmpty ? game.ageRatings.first.toString() : 'N/A',
                            ),
                          ),
                        ),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SizedBox(
                          width: 100,
                          height: 30,
                          child: Center(
                            child: Text(
                              '${ratingToString(game.rating ?? 0)} / 10 ⭐',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.28,
                  minChildSize: 0.28,
                  maxChildSize: 0.7,
                  snap: true,
                  builder: (context, scrollController) {
                    return Card(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Center(
                            child: Card(
                              color: Theme.of(context).colorScheme.outline,
                              child: const SizedBox(width: 56, height: 8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        game.name ?? '',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Genres:',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Description:',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            game.summary ?? 'Error: Description not found',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
