import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ludyo/auth/firebase_auth.dart';
import 'package:ludyo/pages/main_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    void toMainPage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    }

    void logOut() async {
      try {
        await authService.value.signOut();
        toMainPage();
      } on FirebaseAuthException catch (e) {
        log(e.message!);
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('email: ${authService.value.currentUser!.email!}'),
          Text('verified: ${authService.value.currentUser!.emailVerified.toString()}'),
          Text('displayName: ${authService.value.currentUser!.displayName.toString()}'),
          Text('photoURL: ${authService.value.currentUser!.photoURL.toString()}'),
          CachedNetworkImage(
            imageUrl: authService.value.currentUser!.photoURL ?? '',
            errorWidget: (_, _, _) => const Icon(Icons.error),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: logOut,
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
