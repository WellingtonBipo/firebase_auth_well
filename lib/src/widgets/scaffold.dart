import 'package:firebase_auth_well/src/faw_widget.dart';
import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

class const FAWScaffold({
  final String? title,
  final Widget? body,
  super.key,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: context.fawStyle.brightness,
        textTheme: context.textTheme,
        colorScheme: ColorScheme.fromSeed(
          brightness: context.fawStyle.brightness!,
          seedColor: context.fawStyle.primaryColor!,
        ),
        outlinedButtonTheme: _outlinedButtonTheme(context),
        elevatedButtonTheme: _elevatedButtonTheme(context),
        textButtonTheme: _textButtonTheme(context),
        inputDecorationTheme: _inputDecorationTheme(context),
      ),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: body,
        appBar: title == null && Navigator.canPop(context).not
            ? null
            : AppBar(
                backgroundColor: context.backgroundColor,
                title: title?.let(Text.new),
              ),
      ),
    );
  }

  OutlinedButtonThemeData _outlinedButtonTheme(BuildContext context) {
    final t = Theme.of(context).outlinedButtonTheme;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: context._padding(),
        shape: context._shape(t.style),
        foregroundColor: context.textTheme.bodyMedium?.color,
      ),
    );
  }

  ElevatedButtonThemeData _elevatedButtonTheme(BuildContext context) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: context._padding(),
        shape: context._shape(Theme.of(context).elevatedButtonTheme.style),
        backgroundColor: context.fawStyle.primaryColor,
        foregroundColor: context.textTheme.bodyMedium?.color,
      ),
    );
  }

  TextButtonThemeData _textButtonTheme(BuildContext context) {
    final t = Theme.of(context).textButtonTheme;
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: context._padding(),
        shape: context._shape(t.style),
        foregroundColor: context.fawStyle.primaryColor?[200],
        textStyle: (t.style?.textStyle?.resolve({}) ?? const TextStyle())
            .copyWith(color: context.fawStyle.primaryColor),
      ),
    );
  }

  InputDecorationTheme _inputDecorationTheme(BuildContext context) {
    final borderRadius =
        (context._shape(null) ?? Theme.of(context).inputDecorationTheme.border)
            ?.letType<RoundedRectangleBorder>()
            ?.borderRadius
            .letType<BorderRadius>();
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

extension on BuildContext {
  OutlinedBorder? _shape(ButtonStyle? style) {
    BorderRadiusGeometry? borderRadius = fawStyle.buttonStyle?.borderRadius;
    borderRadius ??= style?.shape
        .letType<RoundedRectangleBorder>()
        ?.borderRadius;
    return borderRadius?.let(
      (it) => RoundedRectangleBorder(borderRadius: it),
    );
  }

  EdgeInsets? _padding() {
    return fawStyle.buttonStyle?.padding;
  }
}
