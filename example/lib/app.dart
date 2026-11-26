import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:example/main.dart';
import 'package:firebase_auth_well/firebase_auth_well.dart';
import 'package:flutter/material.dart';

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
    const fawSettings = FAWWidgetSettings(
      mustHaveEmailVerified: true,
      uiCopy: UICopy(
        // cSpell: disable
        debugLoginEmail: 'testerfaw+faw@gmail.com',
        debugLoginPassword: 'Fawe8147f708b1d!',
        // cSpell: enable
      ),
    );

    return MaterialApp(
      title: 'FAW Example',
      theme: ThemeData(
        brightness: DevicePreview.controller.simulation?.platformBrightness,
      ),
      routes: {
        '/home': (context) => const _HomePage(),
        '/register': (context) => const _RegisterPage(),
        '/reset-password': (context) => FAWResetPasswordScreen(
          email: FAWService.user.email,
        ),
        '/faw-custom-style': (context) => _FlowWithBackButton(
          child: FAWWidget(
            routeLoginSuccess: () => isRegistered ? '/home' : '/register',
            routeSignUpSuccess: () => '/register',
            settings: fawSettings,
            style: customStyle(context),
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
      home: const _StartPage(),
    );
  }
}

class const _StartPage() extends StatefulWidget {
  @override
  State<_StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<_StartPage> {
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

class const _HomePage() extends StatelessWidget {
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

class const _RegisterPage() extends StatelessWidget {
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
              child: IconButton(
                tooltip: 'Back to start',
                onLongPress: () {
                  final currentDevice =
                      DevicePreview.controller.simulation!.presetId;
                  final devices = [
                    DevicePresets.iPhoneSe3,
                    DevicePresets.iPhone17,
                    DevicePresets.iPadAir13M2,
                  ];
                  var nextDevice = devices.first;
                  for (var i = 0; i < devices.length; i++) {
                    if (devices[i].id == currentDevice &&
                        i < devices.length - 1) {
                      nextDevice = devices[i + 1];
                      break;
                    }
                  }
                  DevicePreview.controller.applyPreset(nextDevice);
                },
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (_) => false),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _logoutToLogin(BuildContext context) async {
  final nav = Navigator.of(context);
  await FAWService.logout();
  nav.pushNamedAndRemoveUntil('/', (_) => false);
}
