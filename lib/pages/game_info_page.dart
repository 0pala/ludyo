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
                      child: CachedNetworkImage(
                        imageUrl: game.coverUrl,
                        errorWidget: (_, _, _) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(Icons.error),
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
              Align(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.34,
                  minChildSize: 0.34,
                  maxChildSize: 0.7,
                  builder: (context, scrollController) {
                    return ListView(
                      controller: scrollController,
                      children: [
                        Card(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.name ?? '',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
