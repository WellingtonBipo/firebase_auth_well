import 'package:firebase_auth_well/src/faw_service.dart';

class const UICopy({
  final String debugLoginEmail = '',
  final String debugLoginPassword = '',
  final String emailInvalid = 'Invalid email.',
  final String emailExist = 'Email already exists.',
  final String weakPassword = 'Password is too weak.',
  final String emailOrPasswordWrong = 'Email or password is incorrect.\nPlease check if you typed it correctly.',
  final String accountProblem =
      'There is a problem with your account.\nPlease contact support.',
  final String tooManyRequests =
      'Requests blocked due to unusual activity.'
      '\nPlease try again later.',
  final String userDisabled =
      'There is a problem with your account.'
      '\nPlease contact support.',
  final String unknownError = 'Erro desconhecido.',
  final String emailLabel = 'Email',
  final String emailHint = 'your.email@example.com',
  final String passwordLabel = 'Password',
  final String passwordHint = '••••••••',
  final String passwordConfirmLabel = 'Confirm password',
  final String emailEmpty = 'Please enter your email.',
  final String passwordEmpty = 'Please enter your password.',
  final String Function(int min) passwordTooShort = _passwordTooShort,
  final String passwordsDontMatch = 'Passwords do not match.',
  final String forgotPassword = 'Forgot password',
  final String signInButton = 'Sign in',
  final String orContinueWith = 'or continue with',
  final String createAccount = 'Create account',
  final String signUpTitle = 'Create account',
  final String signUpButton = 'Create account',
  final String verifyEmailTitle = 'Verify email',
  final String Function(String? email) verifyEmailSent = _verifyEmailSent,
  final String verifyEmailInstructions =
      'Please check your inbox and follow the instructions'
      ' to complete the verification process.',
  final String resendEmail = 'Resend email',
  final String Function(int seconds) resendEmailIn = _resendEmailIn,
  final String resendEmailError = 'Error resending verification email.',
  final String resetPasswordTitle = 'Reset password',
  final String resetPasswordInstructions =
      'Enter your email to receive the password reset link.',
  final String resetPasswordButton = 'Send link',
  final String resetPasswordSent =
      'If there is an account with this email,'
      ' you will receive a link to reset your password.',
  final String? Function(FAWServiceUnknownError)? handleUnknownError,
}) {
  static String _passwordTooShort(int min) =>
      'Password must be at least $min characters.';

  static String _verifyEmailSent(String? email) => email == null
      ? 'A verification email has been sent to your email.'
      : 'A verification email has been sent to $email.';

  static String _resendEmailIn(int seconds) => 'Resend email in $seconds s';
}

class const UICopyPortuguese({
  super.debugLoginEmail = '',
  super.debugLoginPassword = '',
  super.emailInvalid = 'Email inválido.',
  super.emailExist = 'Este email já está em uso.',
  super.weakPassword = 'A senha é muito fraca.',
  super.emailOrPasswordWrong =
      'Email ou senha incorretos.\nVerifique se digitou corretamente.',
  super.accountProblem =
      'Há um problema com sua conta.\nEntre em contato com o suporte.',
  super.tooManyRequests =
      'Solicitações bloqueadas devido a atividades incomuns.'
      '\nTente novamente mais tarde.',
  super.userDisabled =
      'Há um problema com sua conta.'
      '\nEntre em contato com o suporte.',
  super.unknownError = 'Erro desconhecido.',
  super.emailLabel = 'Email',
  super.emailHint = 'your.email@example.com',
  super.passwordLabel = 'Senha',
  super.passwordHint = '••••••••',
  super.passwordConfirmLabel = 'Repetir senha',
  super.emailEmpty = 'Por favor, insira seu email.',
  super.passwordEmpty = 'Por favor, insira sua senha.',
  super.passwordTooShort = _passwordTooShort,
  super.passwordsDontMatch = 'As senhas não coincidem.',
  super.forgotPassword = 'Esqueci minha senha',
  super.signInButton = 'Entrar',
  super.orContinueWith = 'ou continue com',
  super.createAccount = 'Criar conta',
  super.signUpTitle = 'Criar conta',
  super.signUpButton = 'Criar conta',
  super.verifyEmailTitle = 'Verificar email',
  super.verifyEmailSent = _verifyEmailSent,
  super.verifyEmailInstructions =
      'Por favor, verifique sua caixa de entrada e siga as instruções'
      ' para completar o processo de verificação.',
  super.resendEmail = 'Reenviar email',
  super.resendEmailIn = _resendEmailIn,
  super.resendEmailError = 'Erro ao reenviar email de verificação.',
  super.resetPasswordTitle = 'Redefinir senha',
  super.resetPasswordInstructions =
      'Informe seu email para receber o link de redefinição de senha.',
  super.resetPasswordButton = 'Enviar link',
  super.resetPasswordSent =
      'Se houver uma conta com este email,'
      ' você receberá um link para redefinir sua senha.',
  super.handleUnknownError,
}) extends UICopy {
  //
  static String _passwordTooShort(int min) =>
      'A senha deve ter pelo menos $min caracteres.';

  static String _verifyEmailSent(String? email) => email == null
      ? 'Um email de verificação foi enviado para seu email.'
      : 'Um email de verificação foi enviado para $email.';

  static String _resendEmailIn(int seconds) => 'Reenviar email em $seconds s';
}

// cSpell: disable
class const UICopySpanish({
  super.debugLoginEmail = '',
  super.debugLoginPassword = '',
  super.emailInvalid = 'Correo electrónico inválido.',
  super.emailExist = 'Este correo electrónico ya está en uso.',
  super.weakPassword = 'La contraseña es demasiado débil.',
  super.emailOrPasswordWrong = 'Correo electrónico o contraseña incorrectos.\nVerifique si lo escribió correctamente.',
  super.accountProblem =
      'Hay un problema con su cuenta.\nPóngase en contacto con el soporte.',
  super.tooManyRequests =
      'Solicitudes bloqueadas debido a actividades inusuales.'
      '\nInténtelo de nuevo más tarde.',
  super.userDisabled =
      'Hay un problema con su cuenta.'
      '\nPóngase en contacto con el soporte.',
  super.unknownError = 'Error desconocido.',
  super.emailLabel = 'Email',
  super.emailHint = 'your.email@example.com',
  super.passwordLabel = 'Contraseña',
  super.passwordHint = '••••••••',
  super.passwordConfirmLabel = 'Repetir contraseña',
  super.emailEmpty = 'Por favor, ingrese su correo electrónico.',
  super.passwordEmpty = 'Por favor, ingrese su contraseña.',
  super.passwordTooShort = _passwordTooShort,
  super.passwordsDontMatch = 'Las contraseñas no coinciden.',
  super.forgotPassword = 'Olvidé mi contraseña',
  super.signInButton = 'Iniciar sesión',
  super.orContinueWith = 'o continúe con',
  super.createAccount = 'Crear cuenta',
  super.signUpTitle = 'Crear cuenta',
  super.signUpButton = 'Crear cuenta',
  super.verifyEmailTitle = 'Verificar correo electrónico',
  super.verifyEmailSent = _verifyEmailSent,
  super.verifyEmailInstructions =
      'Por favor, verifique su bandeja de entrada y siga las instrucciones'
      ' para completar el proceso de verificación.',
  super.resendEmail = 'Reenviar correo electrónico',
  super.resendEmailIn = _resendEmailIn,
  super.resendEmailError =
      'Error al reenviar el correo electrónico de verificación.',
  super.resetPasswordTitle = 'Restablecer contraseña',
  super.resetPasswordInstructions = 'Ingrese su correo electrónico para recibir el enlace de restablecimiento de contraseña.',
  super.resetPasswordButton = 'Enviar enlace',
  super.resetPasswordSent =
      'Si hay una cuenta con este correo electrónico,'
      ' recibirá un enlace para restablecer su contraseña.',
  super.handleUnknownError,
}) extends UICopy {
  //
  static String _passwordTooShort(int min) =>
      'La contraseña debe tener al menos $min caracteres.';

  static String _verifyEmailSent(String? email) => email == null
      ? 'Se ha enviado un correo electrónico de verificación a su correo electrónico.'
      : 'Se ha enviado un correo electrónico de verificación a $email.';

  static String _resendEmailIn(int seconds) =>
      'Reenviar correo electrónico en $seconds s';
}
// cSpell: enable
