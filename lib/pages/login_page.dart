import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:ludyo/auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSwitch;

  const LoginPage({super.key, required this.onSwitch});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    try {
      await authService.value.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      popPage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message!;
      });
      log(e.message!);
    }
  }

  void popPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'email',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'password'),
                ),
                errorMessage == ''
                    ? const SizedBox(height: 24)
                    : Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                FilledButton(
                  onPressed: login,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 32),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?  ',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    InkWell(
                      onTap: widget.onSwitch,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
