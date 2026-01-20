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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'email'),
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
                OutlinedButton(
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
                const SizedBox(height: 16),
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
