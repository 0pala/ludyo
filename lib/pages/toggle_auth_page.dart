import 'package:flutter/material.dart';

import 'package:ludyo/pages/login_page.dart';
import 'package:ludyo/pages/register_page.dart';

enum AuthMode { login, register }

class ToggleAuthPage extends StatefulWidget {
  final AuthMode initialMode;

  const ToggleAuthPage({super.key, this.initialMode = AuthMode.login});

  @override
  State<ToggleAuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<ToggleAuthPage> {
  late AuthMode mode;

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode;
  }

  void toggle() {
    setState(() {
      mode = mode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.shadow,
        leading: const BackButton(),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(),
        child: mode == AuthMode.login ? LoginPage(onSwitch: toggle) : RegisterPage(onSwitch: toggle),
      ),
    );
  }
}
