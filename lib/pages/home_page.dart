import 'package:flutter/material.dart';

import 'package:ludyo/apis/igdb_service.dart';
import 'package:ludyo/models/game_model.dart';
import 'package:ludyo/pages/games_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final IgdbService igdb = IgdbService();
  late Future<List<Game>> newReleases;
  late Future<List<Game>> popularGames;
  late Future<List<Game>> upcomingGames;

  @override
  void initState() {
    super.initState();
    newReleases = igdb.fetchNewReleases();
    popularGames = igdb.fetchPopularGames();
    upcomingGames = igdb.fetchUpcomingGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 16),
              child: Text(
                'New Releases',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GamesCarousel(games: newReleases),
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 16),
              child: Text(
                'Popular Games',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GamesCarousel(games: popularGames),
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 16),
              child: Text(
                'Upcoming Games',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GamesCarousel(games: upcomingGames),
          ],
        ),
      ),
    );
  }
}
