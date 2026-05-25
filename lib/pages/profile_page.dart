import 'package:flutter/material.dart';

import 'package:ludyo/auth/firebase_auth.dart';
import 'package:ludyo/pages/profile_edit_page.dart';
import 'package:ludyo/pages/profile_view_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      await authService.value.currentUser?.sendEmailVerification();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email di verifica inviata',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Edit'),
            ],
          ),

          // Porco dio sto Expanded di merda mi ha rubato 10 minuti
          Expanded(
            child: TabBarView(
              children: [
                ProfileViewPage(),
                ProfileEditPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
