import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:ludyo/apis/igdb_service.dart';
import 'package:ludyo/models/game_model.dart';
import 'package:ludyo/pages/game_info_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final IgdbService igdb = IgdbService();

  late Future<List<Game>> searchedGames;

  bool isSearching = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        isSearching = _focusNode.hasFocus;
      });
    });

    // inizializza la search con lista vuota o risultati iniziali
    searchedGames = igdb.fetchSearchedGames('');
  }

  void _clearText() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isPressed = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _controller.clear();
      _isPressed = false;
    });

    searchedGames = igdb.fetchSearchedGames('');
  }

  void _exitSearch() {
    HapticFeedback.mediumImpact();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: (text) {
              setState(() {
                searchedGames = igdb.fetchSearchedGames(text);
              });
            },

            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(
                  isSearching ? Icons.arrow_back : Icons.search_outlined,
                ),
                onPressed: () {
                  if (isSearching) {
                    _exitSearch();
                  }
                },
              ),
              suffixIcon: isSearching
                  ? GestureDetector(
                      onTap: _clearText,
                      child: AnimatedScale(
                        scale: _isPressed ? 0.8 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: const Icon(Icons.clear),
                      ),
                    )
                  : null,
              hintText: 'Search a game...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Game>>(
            future: searchedGames,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final games = snapshot.data!;

              if (games.isEmpty && _controller.text != '') {
                return const Center(
                  child: Text('No games found'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                itemCount: games.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, index) {
                  final game = games[index];

                  return InkWell(
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: game.coverUrl,
                        fadeInDuration: const Duration(milliseconds: 180),
                        fadeOutDuration: const Duration(milliseconds: 120),
                        fadeInCurve: Curves.easeOut,
                        fadeOutCurve: Curves.easeIn,
                        errorWidget: (_, _, _) => Padding(
                          padding: const EdgeInsetsGeometry.all(8),
                          child: Center(
                            child: Text(
                              game.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
