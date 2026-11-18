import 'dart:async';

import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/verify_email_screen.dart';

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

class const UICopy({
  final String debugLoginEmail = '',
  final String debugLoginPassword = '',
  final String emailInvalid = 'Email inválido.',
  final String emailExist = 'Este email já está em uso.',
  final String weakPassword = 'A senha é muito fraca.',
  final String emailOrPasswordWrong =
      'Email ou senha incorretos.\nVerifique se digitou corretamente.',
  final String accountProblem =
      'Há um problema com sua conta.\nEntre em contato com o suporte.',
  final String tooManyRequests =
      'Solicitações bloqueadas devido a atividades incomuns.'
      '\nTente novamente mais tarde.',
  final String userDisabled =
      'Há um problema com sua conta.'
      '\nEntre em contato com o suporte.',
  final String unknownError = 'Erro desconhecido.',
  final String emailLabel = 'Email',
  final String emailHint = 'your.email@example.com',
  final String passwordLabel = 'Senha',
  final String passwordHint = '••••••••',
  final String passwordConfirmLabel = 'Repetir senha',
  final String emailEmpty = 'Por favor, insira seu email.',
  final String passwordEmpty = 'Por favor, insira sua senha.',
  final String Function(int min) passwordTooShort = _passwordTooShort,
  final String passwordsDontMatch = 'As senhas não coincidem.',
  final String forgotPassword = 'Esqueci minha senha',
  final String signInButton = 'Entrar',
  final String orContinueWith = 'ou continue com',
  final String createAccount = 'Criar conta',
  final String signUpTitle = 'Criar conta',
  final String signUpButton = 'Criar conta',
  final String verifyEmailTitle = 'Verificar email',
  final String Function(String? email) verifyEmailSent = _verifyEmailSent,
  final String verifyEmailInstructions =
      'Por favor, verifique sua caixa de entrada e siga as instruções'
      ' para completar o processo de verificação.',
  final String resendEmail = 'Reenviar email',
  final String Function(int seconds) resendEmailIn = _resendEmailIn,
  final String resendEmailError = 'Erro ao reenviar email de verificação.',
  final String resetPasswordTitle = 'Redefinir senha',
  final String resetPasswordInstructions =
      'Informe seu email para receber o link de redefinição de senha.',
  final String resetPasswordButton = 'Enviar link',
  final String resetPasswordSent =
      'Se houver uma conta com este email,'
      ' você receberá um link para redefinir sua senha.',
  final String? Function(FAWServiceUnknownError)? handleUnknownError,
}) {
  static String _passwordTooShort(int min) =>
      'A senha deve ter pelo menos $min caracteres.';

  static String _verifyEmailSent(String? email) => email == null
      ? 'Um email de verificação foi enviado para seu email.'
      : 'Um email de verificação foi enviado para $email.';

  static String _resendEmailIn(int seconds) => 'Reenviar email em $seconds s';
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
