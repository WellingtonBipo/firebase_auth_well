import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:example/app.dart';
import 'package:firebase_auth_well/firebase_auth_well.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:flutter/material.dart';

void main() async {
  DevicePreview.enable(padding: const EdgeInsets.all(16));
  DevicePreview.controller.applyPreset(DevicePresets.iPhoneSe3);
  DevicePreview.controller.update(
    (d) => d.copyWith(
      platformBrightness: PlatformDispatcher.instance.platformBrightness,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ExampleApp());
}

FAWWidgetStyle customStyle(BuildContext context) {
  final theme = Theme.of(context);
  final isLight = theme.brightness == .light;
  return FAWWidgetStyle(
    logo: FAWLogo(
      slogan: (_, animation) => Container(
        height: lerpDouble(25, 0, animation),
        padding: .only(top: lerpDouble(5, 0, animation)!),
        child: const Text('slogan'),
      ),
      logotype: (_, animation) => Container(
        padding: .only(right: 40 * animation, bottom: 5),
        child: const Text('logotype'),
      ),
      brandMarkConstraints: const BoxConstraints(
        minHeight: 120,
        maxHeight: 170,
      ),
      brandMark: (_, animation) => LayoutBuilder(
        builder: (context, constraints) => Container(
          padding: .only(right: 10 * animation),
          child: Icon(
            Icons.ac_unit,
            size: constraints.maxHeight.clamp(80, 200),
          ),
        ),
      ),
    ),
    primaryColor: Colors.yellow,
    buttonStyle: FAWButtonStyle(
      borderRadius: .all(BorderRadius.circular(8)),
      padding: ButtonProperties({
        for (var type in ButtonType.values.toList()..remove(ButtonType.input))
          type: EdgeInsets.symmetric(vertical: 20),
      }),
      foregroundColor: ButtonProperties({
        if (!isLight) .outlined: Colors.white,
      }),
      textStyle: ButtonProperties({
        .text: const TextStyle(fontSize: 17, color: Colors.red),
      }),
      shapeBorder: ButtonProperties({
        .input: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      }),
    ),
  );
}
