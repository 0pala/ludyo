// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:ludyo/models/game_model.dart';
import 'package:ludyo/pages/game_info_page.dart';

class GamesCarousel extends StatelessWidget {
  GamesCarousel({super.key, required this.games});
  late Future<List<Game>> games;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Game>>(
      future: games,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final games = snapshot.data!;

        return SizedBox(
          height: 224,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: games.length,
            itemBuilder: (_, index) {
              final game = games[index];

              return SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      barrierColor: Theme.of(context).colorScheme.surface,
                      pageBuilder: (context, animation, secondaryAnimation) => GameInfoPage(gameId: game.id),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween =
                            Tween(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).chain(
                              CurveTween(
                                curve: Curves.easeOutCubic,
                              ),
                            );

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: game.coverUrl,
                      errorWidget: (_, _, _) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(Icons.error),
                          Text(
                            'Error: Game Cover not found',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      fit: BoxFit.fill,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
