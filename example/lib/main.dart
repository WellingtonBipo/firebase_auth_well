import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:firebase_auth_well/firebase_auth_well.dart';
import 'package:firebase_auth_well/src/u_i_copy.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:flutter/material.dart';

const fawSettings = FAWWidgetSettings(
  mustHaveEmailVerified: true,
  uiCopy: UICopy(
    debugLoginEmail: 'testerfaw+faw@gmail.com',
    debugLoginPassword: 'Fawe8147f708b1d!',
  ),
);

void main() async {
  DevicePreview.enable(padding: const EdgeInsets.all(16));
  DevicePreview.controller.applyPreset(DevicePresets.iPhoneSe3);
  DevicePreview.controller.update((d) => d.copyWith(keyboardInset: 0));
  DevicePreview.controller.update(
    (d) => d.copyWith(platformBrightness: Brightness.dark),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp>
    with SingleTickerProviderStateMixin {
  late final _keyboardController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  var isRegistered = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_listener);
    final height = DevicePresets.iPhoneSe3.portraitKeyboardHeight ?? 200;
    final partsCount = 20;
    final part = height / partsCount;
    _keyboardController.addListener(() {
      final seqTick = _keyboardController.value * partsCount;
      DevicePreview.controller.update(
        (d) => d.copyWith(keyboardInset: part * seqTick),
      );
    });
  }

  @override
  void dispose() {
    _keyboardController.dispose();
    FocusManager.instance.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    final primaryFocus = FocusManager.instance.primaryFocus?.context;
    final hasFocus =
        primaryFocus?.findAncestorStateOfType<EditableTextState>() != null;
    hasFocus ? _keyboardController.forward() : _keyboardController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAW Example',
      darkTheme: ThemeData.dark(),
      routes: {
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
        '/reset-password': (context) => FAWResetPasswordScreen(
          email: FAWService.user.email,
        ),
      },
      home: FAWWidget(
        routeLoginSuccess: () => isRegistered ? '/home' : '/register',
        routeSignUpSuccess: () => '/register',
        settings: fawSettings,
        style: FAWWidgetStyle(
          logo: FAWLogo(
            brandMarkConstraints: BoxConstraints(minHeight: 50, maxHeight: 100),
            brandMark: Container(
              color: Colors.red,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // print(['brandMark', constraints]);
                  // return Icon(Icons.ac_unit, size: 100);
                  // return Icon(Icons.ac_unit, size: constraints.maxHeight);
                  return Icon(
                    Icons.ac_unit,
                    size: clampDouble(constraints.maxHeight, 50, 100),
                  );
                },
              ),
            ),
            slogan: LayoutBuilder(
              builder: (context, constraints) {
                // child: Builder(
                //   builder: (context) {
                // print(['slogan', constraints]);
                return Text('slogan');
              },
            ),
            logotype: LayoutBuilder(
              builder: (context, constraints) {
                // child: Builder(
                //   builder: (context) {
                // print(['logotype', constraints]);
                return Text('logotype');
              },
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _logoutToLogin(BuildContext context) async {
  final nav = Navigator.of(context);
  await FAWService.logout();
  nav.pushNamedAndRemoveUntil('/', (_) => false);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FAWService.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: BackButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/register'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('User authenticated successfully.'),
            const SizedBox(height: 8),
            Text(user.email ?? user.uid),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/reset-password'),
              child: const Text('Reset password'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _logoutToLogin(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: BackButton(onPressed: () => _logoutToLogin(context)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Page'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
              child: const Text('Go to home'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _logoutToLogin(context),
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
