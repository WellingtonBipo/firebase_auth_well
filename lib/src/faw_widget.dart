import 'dart:async';

import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/verify_email_screen.dart';

class FAWWidget extends StatelessWidget {
  const FAWWidget({
    required this.routeLoginSuccess,
    this.routeAutoLoginSuccess,
    this.routeSignUpSuccess,
    required this.settings,
    this.style,
    super.key,
  });

  final FAWWidgetSettings settings;
  final FAWWidgetStyle? style;

  final FutureOr<String> Function() routeLoginSuccess;
  final FutureOr<String?> Function()? routeAutoLoginSuccess;
  final FutureOr<String> Function()? routeSignUpSuccess;

  @override
  Widget build(BuildContext context) {
    FAWServiceInternal.whenLogout = settings.whenLogout;
    FAWServiceInternal.loadAfterAuthenticate = settings.loadAfterAuthenticate;
    FAWServiceInternal.convertUnknownError = settings.convertUnknownError;
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

class FAWResetPasswordScreen extends StatelessWidget {
  const FAWResetPasswordScreen({
    this.settings = const FAWWidgetSettings(),
    this.email,
    super.key,
  });

  final FAWWidgetSettings settings;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return _FAWSettingsScope(
      settings: settings,
      child: ResetPasswordScreen(initialEmail: email),
    );
  }
}

class _FAWSettingsScope extends StatelessWidget {
  const _FAWSettingsScope({required this.settings, required this.child});

  final FAWWidgetSettings settings;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

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

class UICopy {
  const UICopy({
    this.debugLoginEmail = '',
    this.debugLoginPassword = '',
    this.emailInvalid = 'Email inválido.',
    this.emailExist = 'Este email já está em uso.',
    this.weakPassword = 'A senha é muito fraca.',
    this.emailOrPasswordWrong =
        'Email ou senha incorretos.\nVerifique se digitou corretamente.',
    this.accountProblem =
        'Há um problema com sua conta.\nEntre em contato com o suporte.',
    this.tooManyRequests =
        'Solicitações bloqueadas devido a atividades incomuns.'
        '\nTente novamente mais tarde.',
    this.userDisabled =
        'Há um problema com sua conta.'
        '\nEntre em contato com o suporte.',
    this.unknownError = 'Erro desconhecido.',
    this.emailLabel = 'Email',
    this.emailHint = 'your.email@example.com',
    this.passwordLabel = 'Senha',
    this.passwordHint = '••••••••',
    this.passwordConfirmLabel = 'Repetir senha',
    this.emailEmpty = 'Por favor, insira seu email.',
    this.passwordEmpty = 'Por favor, insira sua senha.',
    this.passwordTooShort = _passwordTooShort,
    this.passwordsDontMatch = 'As senhas não coincidem.',
    this.forgotPassword = 'Esqueci minha senha',
    this.signInButton = 'Entrar',
    this.orContinueWith = 'ou continue com',
    this.createAccount = 'Criar conta',
    this.signUpTitle = 'Criar conta',
    this.signUpButton = 'Criar conta',
    this.verifyEmailTitle = 'Verificar email',
    this.verifyEmailSent = _verifyEmailSent,
    this.verifyEmailInstructions =
        'Por favor, verifique sua caixa de entrada e siga as instruções'
        ' para completar o processo de verificação.',
    this.resendEmail = 'Reenviar email',
    this.resendEmailIn = _resendEmailIn,
    this.resendEmailError = 'Erro ao reenviar email de verificação.',
    this.resetPasswordTitle = 'Redefinir senha',
    this.resetPasswordInstructions =
        'Informe seu email para receber o link de redefinição de senha.',
    this.resetPasswordButton = 'Enviar link',
    this.resetPasswordSent =
        'Se houver uma conta com este email,'
        ' você receberá um link para redefinir sua senha.',
    this.handleUnknownError,
  });

  static String _passwordTooShort(int min) =>
      'A senha deve ter pelo menos $min caracteres.';

  static String _verifyEmailSent(String? email) => email == null
      ? 'Um email de verificação foi enviado para seu email.'
      : 'Um email de verificação foi enviado para $email.';

  static String _resendEmailIn(int seconds) => 'Reenviar email em $seconds s';

  final String debugLoginEmail;
  final String debugLoginPassword;
  final String emailOrPasswordWrong;
  final String accountProblem;
  final String tooManyRequests;
  final String userDisabled;
  final String unknownError;
  final String? Function(FAWServiceUnknownError)? handleUnknownError;
  final String emailLabel;
  final String emailHint;
  final String passwordLabel;
  final String passwordHint;
  final String passwordConfirmLabel;
  final String emailInvalid;
  final String emailExist;
  final String weakPassword;
  final String emailEmpty;
  final String passwordEmpty;
  final String Function(int min) passwordTooShort;
  final String passwordsDontMatch;
  final String forgotPassword;
  final String signInButton;
  final String orContinueWith;
  final String createAccount;
  final String signUpTitle;
  final String signUpButton;
  final String verifyEmailTitle;
  final String Function(String? email) verifyEmailSent;
  final String verifyEmailInstructions;
  final String resendEmail;
  final String Function(int seconds) resendEmailIn;
  final String resendEmailError;
  final String resetPasswordTitle;
  final String resetPasswordInstructions;
  final String resetPasswordButton;
  final String resetPasswordSent;
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

  FAWWidget get fawWidget => findAncestorWidgetOfExactType<FAWWidget>()!;
  FAWWidgetSettings get fawSettings =>
      findAncestorWidgetOfExactType<_FAWSettingsScope>()?.settings ??
      fawWidget.settings;
  UICopy get uiCopy => fawSettings.uiCopy;

  FAWWidgetStyle get fawStyle {
    final style = fawWidget.style;
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
    final faw = fawWidget;
    final nav = Navigator.of(this);
    if (faw.settings.mustHaveEmailVerified && !user.emailVerified) {
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
    final faw = fawWidget;
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
