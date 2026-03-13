import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:ludyo/auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onSwitch;

  const RegisterPage({super.key, required this.onSwitch});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void register() async {
    try {
      await authService.value.createAccount(email: emailController.text, password: passwordController.text);
      await authService.value.updateUsername(username: usernameController.text);
      popPage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message!;
      });
      log(e.message!);
    }
  }

  void registerWithGoogle() async {
    try {
      await authService.value.signInWithGoogle();
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
              spacing: 20,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  height: 1,
                  width: 256,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'username'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'password'),
                ),
                errorMessage == ''
                    ? const SizedBox(height: 2)
                    : Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: register,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsetsGeometry.symmetric(horizontal: 32),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                  child: Text(
                    'or',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: registerWithGoogle,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsetsGeometry.symmetric(horizontal: 32),
                    ),
                    child: Row(
                      spacing: 24,
                      children: [
                        Image.asset(
                          'assets/icons/google_icon.png',
                          width: 30,
                        ),
                        const Text(
                          'Sign up with Google',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?  ',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    InkWell(
                      onTap: widget.onSwitch,
                      child: const Text(
                        'Login now',
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
