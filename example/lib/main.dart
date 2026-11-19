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
      keyboardInset: 0,
      platformBrightness: PlatformDispatcher.instance.platformBrightness,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ExampleApp());
}

FAWWidgetStyle customStyle(BuildContext context) => FAWWidgetStyle(
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
