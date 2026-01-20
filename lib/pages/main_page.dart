import 'package:flutter/material.dart';

import 'package:animations/animations.dart';

import 'package:ludyo/pages/auth_layout_page.dart';
import 'package:ludyo/pages/home_page.dart';
import 'package:ludyo/pages/list_page.dart';
import 'package:ludyo/pages/search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  int previousIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      previousIndex = selectedIndex;
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const SearchPage(),
      const ListPage(),
      const AuthLayoutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludyo'),
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        reverse: selectedIndex < previousIndex,
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(selectedIndex),
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: selectedIndex == 0 ? const Icon(Icons.home) : const Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 2 ? const Icon(Icons.bookmark) : const Icon(Icons.bookmark_outline_outlined),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 3 ? const Icon(Icons.person) : const Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
