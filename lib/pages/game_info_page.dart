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

  @override
  void initState() {
    super.initState();
    game = igdb.fetchGameInfo(widget.gameId);
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
                          imageUrl: game.coverOriginalUrl,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(),
                          fadeOutDuration: const Duration(),
                          errorWidget: (_, _, _) => Padding(
                            padding: const EdgeInsetsGeometry.all(8),
                            child: Center(
                              child: Text(
                                game.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
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
                              game.rating,
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
                              game.pegi,
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
                              game.firstReleaseDate,
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
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              children: [
                                const SizedBox(height: 8),
                                Center(
                                  child: Card(
                                    color: Theme.of(context).colorScheme.outline,
                                    child: const SizedBox(width: 56, height: 8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        game.name,
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
                                            game.summary,
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
