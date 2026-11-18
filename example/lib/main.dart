import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:firebase_auth_well/firebase_auth_well.dart';
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
  DevicePreview.controller.update(
    (d) => d.copyWith(
      keyboardInset: 0,
      platformBrightness: PlatformDispatcher.instance.platformBrightness,
    ),
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
      theme: ThemeData(
        brightness: DevicePreview.controller.simulation?.platformBrightness,
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
        '/reset-password': (context) => FAWResetPasswordScreen(
          email: FAWService.user.email,
        ),
        '/faw-custom-style': (context) => _FlowWithBackButton(
          child: FAWWidget(
            routeLoginSuccess: () => isRegistered ? '/home' : '/register',
            routeSignUpSuccess: () => '/register',
            settings: fawSettings,
            style: _customStyle(context),
          ),
        ),
        '/faw-default-style': (context) => _FlowWithBackButton(
          child: FAWWidget(
            routeLoginSuccess: () => isRegistered ? '/home' : '/register',
            routeSignUpSuccess: () => '/register',
            settings: fawSettings,
          ),
        ),
      },
      home: const StartPage(),
    );
  }
}

FAWWidgetStyle _customStyle(BuildContext context) => FAWWidgetStyle(
  primaryColor: Colors.red,
  logo: FAWLogo(
    brandMarkConstraints: const BoxConstraints(minHeight: 50, maxHeight: 100),
    slogan: Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(8.0),
      child: const Text('slogan'),
    ),
    logotype: const Text('logotype'),
    brandMark: Container(
      color: Colors.red,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Icon(
            Icons.ac_unit,
            size: clampDouble(constraints.maxHeight, 50, 100),
          );
        },
      ),
    ),
  ),
  buttonStyle: FAWButtonStyle(
    borderRadius: .all(BorderRadius.circular(8)),
    padding: ButtonProperties({
      for (var type in ButtonType.values.toList()..remove(ButtonType.input))
        type: EdgeInsets.symmetric(vertical: 20),
    }),
    backgroundColor: ButtonProperties({.elevated: Colors.red}),
    foregroundColor: ButtonProperties({
      .elevated: Colors.white,
      .outlined: Colors.white,
      .text: Colors.red,
    }),
    textStyle: ButtonProperties({
      .text: const TextStyle(fontSize: 16, color: Colors.amber),
    }),
    shapeBorder: ButtonProperties({
      .input: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    }),
  ),
);

class _FlowWithBackButton extends StatelessWidget {
  const _FlowWithBackButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Back to start',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (_) => false),
                child: const Icon(Icons.close),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAW Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose a flow to start',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/faw-default-style'),
                child: const Text('Flow without FAWWidgetStyle'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/faw-custom-style'),
                child: const Text('Flow with custom FAWWidgetStyle'),
              ),
              const SizedBox(height: 60),
              OutlinedButton(
                child: Text('Brightness: ${Theme.of(context).brightness.name}'),
                onPressed: () async {
                  await DevicePreview.controller.update(
                    (current) => current.copyWith(
                      platformBrightness:
                          Theme.of(context).brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                    ),
                  );
                  // ignore: use_build_context_synchronously
                  context
                      .findAncestorStateOfType<_ExampleAppState>()! //
                      .setState(() {});
                },
              ),
            ],
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
