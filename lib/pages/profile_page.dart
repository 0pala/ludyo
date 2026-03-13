import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ludyo/auth/firebase_auth.dart';
import 'package:ludyo/pages/main_page.dart';

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('email: ${authService.value.currentUser!.email!}'),
          Text('verified: ${authService.value.currentUser!.emailVerified}'),
          Text('displayName: ${authService.value.currentUser!.displayName}'),
          CachedNetworkImage(
            imageUrl: authService.value.currentUser!.photoURL ?? '',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorWidget: (_, _, _) => Image.asset(
              'assets/placeholders/user_picture_placeholder.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('email verified: ${authService.value.currentUser!.emailVerified}'),
              if (!authService.value.currentUser!.emailVerified)
                IconButton(
                  onPressed: () => sendEmailVerification(context),
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () async {
              try {
                await authService.value.signOut();

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainPage(),
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                log(e.message!);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
