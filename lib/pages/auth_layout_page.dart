import 'package:flutter/material.dart';

import 'package:ludyo/auth/firebase_auth.dart';
import 'package:ludyo/pages/profile_page.dart';
import 'package:ludyo/pages/toggle_auth_page.dart';

class AuthLayoutPage extends StatelessWidget {
  const AuthLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              widget = const ProfilePage();
            } else {
              widget = const Auth();
            }
            return widget;
          },
        );
      },
    );
  }
}

class Auth extends StatelessWidget {
  const Auth({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ToggleAuthPage(
                  initialMode: AuthMode.register,
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Register',
              style: TextStyle(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('or'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ToggleAuthPage(),
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Login',
              style: TextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}
