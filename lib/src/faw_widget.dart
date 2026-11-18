import 'dart:async';

import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:firebase_auth_well/src/u_i_copy.dart';
import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/verify_email_screen.dart';

export 'package:firebase_auth_well/src/u_i_copy.dart';

class const FAWWidget({
  required final FutureOr<String> Function() routeLoginSuccess,
  final FutureOr<String?> Function()? routeAutoLoginSuccess,
  final FutureOr<String> Function()? routeSignUpSuccess,
  required final FAWWidgetSettings settings,
  final FAWWidgetStyle? style,
  super.key,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    FAWServiceInternal.settings = settings;
    FAWServiceInternal.style = style;
    return Navigator(
      onGenerateRoute: (settings) {
        Route b(WidgetBuilder builder) =>
            MaterialPageRoute(settings: settings, builder: builder);
        return switch (settings.name) {
          '/login' => b((_) => LoginScreen()),
          '/sign-up' => b((_) => SignUpScreen()),
          '/verify-email' => b((_) => VerifyEmailScreen()),
          '/reset-password' => b((_) => ResetPasswordScreen()),
          _ => b((_) => LoginScreen()),
        };
      },
    );
  }
}

class const FAWResetPasswordScreen({
  super.email,
  super.key,
}) extends ResetPasswordScreen {}

class FAWWidgetSettings {
  const FAWWidgetSettings({
    this.mustHaveEmailVerified = false,
    this.minPasswordLength = 8,
    this.whenLogout,
    this.loadAfterAuthenticate,
    this.convertUnknownError,
    this.uiCopy = const UICopy(),
  });

  final UICopy uiCopy;
  final bool mustHaveEmailVerified;
  final int minPasswordLength;
  final WhenLogoutCallback? whenLogout;
  final LoadAfterAuthenticateCallback? loadAfterAuthenticate;
  final ConvertUnknownErrorCallback? convertUnknownError;
}

class const FAWWidgetStyle({
  final Brightness? brightness,
  final FAWAppBarStyle? appBar,
  final FAWLogo? logo,
  final FAWDialogsStyle? dialogsStyle,
  final MaterialColor? primaryColor,
  final MaterialColor? secondaryColor,
  final Color? backgroundLightColor,
  final Color? backgroundDarkColor,
  final TextTheme? textThemeLight,
  final TextTheme? textThemeDark,
  final FAWButtonStyle? buttonStyle,
});

class FAWAppBarStyle {
  const FAWAppBarStyle({this.height});

  final double? height;
}

class const FAWLogo({
  final Widget? logotype,
  final Widget? slogan,
  final Widget? brandMark,
  final BoxConstraints? brandMarkConstraints,
}) {}

class FAWDialogsStyle {
  const FAWDialogsStyle({this.buttonsStyle});

  final TextStyle? buttonsStyle;
}

class FAWButtonStyle({
  final BorderRadius? borderRadius,
  final EdgeInsets? padding,
}) {}

extension FAWWidgetInternal on BuildContext {
  ThemeData get theme => Theme.of(this);

  bool get isLight => fawStyle.brightness == Brightness.light;

  FAWWidgetSettings get fawSettings => FAWServiceInternal.settings;
  UICopy get uiCopy => fawSettings.uiCopy;

  FAWWidgetStyle get fawStyle {
    final style = FAWServiceInternal.style;
    return FAWWidgetStyle(
      brightness: style?.brightness ?? theme.brightness,
      primaryColor:
          style?.primaryColor ??
          theme.primaryColor.letType<MaterialColor>() ??
          MaterialColor(theme.primaryColor.toARGB32(), const {}),
      secondaryColor: style?.secondaryColor,
      backgroundLightColor:
          style?.backgroundLightColor ?? theme.scaffoldBackgroundColor,
      backgroundDarkColor:
          style?.backgroundDarkColor ?? theme.scaffoldBackgroundColor,
      textThemeLight: style?.textThemeLight ?? theme.textTheme,
      textThemeDark: style?.textThemeDark ?? theme.textTheme,
      logo: style?.logo ?? FAWLogo(),
      appBar: style?.appBar,
      dialogsStyle: style?.dialogsStyle,
      buttonStyle: style?.buttonStyle,
    );
  }

  TextTheme get textTheme =>
      (isLight ? fawStyle.textThemeLight : fawStyle.textThemeDark)!;

  Color get backgroundColor =>
      (isLight
          ? fawStyle.backgroundLightColor
          : fawStyle.backgroundDarkColor) ??
      theme.scaffoldBackgroundColor;

  String? validateEmail(String email) =>
      email.isEmpty ? uiCopy.emailEmpty : null;

  String? validatePassword(String password) {
    if (password.isEmpty) return uiCopy.passwordEmpty;
    final min = fawSettings.minPasswordLength;
    if (password.length < min) return uiCopy.passwordTooShort(min);
    return null;
  }

  void showFawMessage(String message, {bool error = true}) {
    final scaffoldMsgr = ScaffoldMessenger.maybeOf(this);

    scaffoldMsgr
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? theme.colorScheme.error : null,
        ),
      );

    if (scaffoldMsgr == null) {
      showSnackBar(
        context: this,
        message: message,
        backgroundColor: fawStyle.secondaryColor,
        textStyle: TextStyle(color: textTheme.bodyMedium?.color),
        borderRadius: fawStyle.buttonStyle?.borderRadius,
      );
    }
  }

  void showFawUnknownError(FAWServiceUnknownError error, [String? message]) {
    showFawMessage(
      uiCopy.handleUnknownError?.call(error) ?? message ?? uiCopy.unknownError,
    );
  }

  Future<void> navigateAuthSuccess(AuthUser user) async {
    final faw = findAncestorWidgetOfExactType<FAWWidget>()!;
    final nav = Navigator.of(this);
    if (FAWServiceInternal.settings.mustHaveEmailVerified &&
        !user.emailVerified) {
      await nav.pushNamed('/verify-email', arguments: user);
      return;
    }
    final replace = _rootReplacer();
    final signUpRoute = user.isNewUser
        ? await faw.routeSignUpSuccess?.call()
        : null;
    replace(signUpRoute ?? await faw.routeLoginSuccess());
  }

  Future<void> navigateAutoLoginSuccess() async {
    final faw = findAncestorWidgetOfExactType<FAWWidget>()!;
    final replace = _rootReplacer();
    var route = await faw.routeLoginSuccess();
    if (faw.routeAutoLoginSuccess != null) {
      final r = await faw.routeAutoLoginSuccess!();
      if (r == null) return;
      route = r;
    }
    replace(route);
  }

  void Function(String route) _rootReplacer() {
    final matApp = findAncestorWidgetOfExactType<MaterialApp>();
    final navigator = Navigator.of(this, rootNavigator: true);
    return (route) {
      RoutePageBuilder? routeBuilder = matApp?.routes?[route]?.let(
        (r) =>
            (context, _, _) => r(context),
      );
      routeBuilder ??= matApp?.onGenerateRoute
          ?.call(RouteSettings(name: route))
          .letType<ModalRoute>()
          ?.let((r) => r.buildPage);

      if (routeBuilder == null) {
        navigator.pushReplacementNamed(route);
        return;
      }
      navigator.pushReplacement(
        PageRouteBuilder(
          settings: RouteSettings(name: route),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: routeBuilder,
        ),
      );
    };
  }
}
