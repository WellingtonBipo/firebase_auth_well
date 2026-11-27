import 'dart:math' as math;

import 'package:firebase_auth_well/src/faw_widget.dart';
import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

class const FAWScaffold({
  final String? title,
  final Widget? body,
  final bool resizeToAvoidBottomInset = true,
  super.key,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _themeData(context),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: body,
        ),
        appBar: title == null && Navigator.canPop(context).not
            ? null
            : AppBar(
                backgroundColor: context.backgroundColor,
                title: title?.let(Text.new),
              ),
      ),
    );
  }

  ThemeData _themeData(BuildContext context) {
    return Theme.of(context).copyWith(
      brightness: context.fawStyle.brightness,
      textTheme: context.textTheme,
      visualDensity: .compact,
      colorScheme: ColorScheme.fromSeed(
        brightness: context.fawStyle.brightness!,
        seedColor: context.fawStyle.primaryColor!,
      ),
      outlinedButtonTheme: _outlinedButtonTheme(context),
      elevatedButtonTheme: _elevatedButtonTheme(context),
      textButtonTheme: _textButtonTheme(context),
      inputDecorationTheme: InputDecorationTheme(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        contentPadding: context._padding(.input)?.min(left: 12, right: 12),
        border:
            context.fawStyle.buttonStyle?.shapeBorder?[.input] as InputBorder?,
      ),
    );
  }

  OutlinedButtonThemeData _outlinedButtonTheme(BuildContext context) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: context._padding(.outlined),
        shape: context._shape(.outlined),
        textStyle: context._textStyle(.outlined),
        foregroundColor: context._foregroundColor(.outlined),
        backgroundColor: context._backgroundColor(.outlined),
      ),
    );
  }

  ElevatedButtonThemeData _elevatedButtonTheme(BuildContext context) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: context._padding(.elevated),
        shape: context._shape(.elevated),
        textStyle: context._textStyle(.elevated),
        foregroundColor: context._foregroundColor(.elevated),
        backgroundColor: context._backgroundColor(.elevated),
      ),
    );
  }

  TextButtonThemeData _textButtonTheme(BuildContext context) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: context._padding(.text),
        shape: context._shape(.text),
        textStyle: context._textStyle(.text),
        foregroundColor: context._foregroundColor(.text),
        backgroundColor: context._backgroundColor(.text),
      ),
    );
  }
}

extension on EdgeInsets {
  EdgeInsets? min({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left?.let((e) => math.max(e, this.left)) ?? this.left,
      top: top?.let((e) => math.max(e, this.top)) ?? this.top,
      right: right?.let((e) => math.max(e, this.right)) ?? this.right,
      bottom: bottom?.let((e) => math.max(e, this.bottom)) ?? this.bottom,
    );
  }
}

extension on BuildContext {
  Color? _foregroundColor(ButtonType t) {
    return fawStyle.buttonStyle?.foregroundColor?[t];
  }

  Color? _backgroundColor(ButtonType t) {
    return fawStyle.buttonStyle?.backgroundColor?[t];
  }

  ThemeData get _theme => Theme.of(this);

  EdgeInsets? _padding(ButtonType t) => fawStyle.buttonStyle?.padding?[t];

  OutlinedBorder? _shape(ButtonType t) {
    final shapeBoarder = fawStyle.buttonStyle?.shapeBorder?[t];
    if (shapeBoarder is OutlinedBorder) return shapeBoarder;
    final borderRadius = fawStyle.buttonStyle?.borderRadius?[t];
    if (borderRadius == null) return null;
    return RoundedRectangleBorder(borderRadius: borderRadius);
  }

  TextStyle? _textStyle(ButtonType t) {
    final style = fawStyle.buttonStyle?.textStyle?[t];
    if (style != null) return style;
    final theme = switch (t) {
      .text => _theme.textButtonTheme.style?.textStyle?.resolve({}),
      .outlined => _theme.outlinedButtonTheme.style?.textStyle?.resolve({}),
      .elevated => _theme.elevatedButtonTheme.style?.textStyle?.resolve({}),
      .input => _theme.inputDecorationTheme.labelStyle,
    };
    return theme?.copyWith(
      color: switch (t) {
        .text => fawStyle.primaryColor,
        .outlined => fawStyle.textTheme?.bodyMedium?.color,
        .elevated => fawStyle.textTheme?.bodyMedium?.color,
        .input => null,
      },
    );
  }
}

enum ButtonType { text, outlined, elevated, input }

class ButtonProperties<T>(
  final Map<ButtonType, T> _values,
) {
  static ButtonProperties<T> all<T>(T value) => _ButtonPropertiesAll(value);

  T? resolve(ButtonType type) => _values[type];

  T? operator [](ButtonType type) => resolve(type);
}

class _ButtonPropertiesAll<T>(final T value) extends ButtonProperties<T> {
  this : super({});

  @override
  T resolve(ButtonType type) => value;
}
