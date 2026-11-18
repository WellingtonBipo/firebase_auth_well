import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:utils_well/utils_well.dart';

typedef LoadAfterAuthenticateCallback<
  R extends AuthUser?,
  E extends FAWServiceUnknownError
> = FutureOr<LoginResult<R, E>> Function(LoginType type, AuthUser? info);

typedef LoginResult<R extends AuthUser?, E> = Result<R, E>;

typedef WhenLogoutCallback = FutureOr<void> Function();

typedef ConvertUnknownErrorCallback = FAWServiceUnknownError Function(
  FAWServiceUnknownError e,
);

enum LoginType { signUpEmail, autoLogin, signInEmail, loginProvider }

enum LoginProviderType { google, apple }

sealed class FAWService {
  //
  static Future<String?> get firebaseJwt async =>
      _auth.currentUser?.getIdToken();

  static AuthUser get user => _getUserLogged(_user, null);

  static Future<void> logout() async {
    await _auth.signOut();
    await _whenLogout?.call();
  }

  static Future<void> deleteAccount() async {
    await _user.reload();
    await _user.delete();
    await FAWService.logout();
  }
}

WhenLogoutCallback? _whenLogout;
LoadAfterAuthenticateCallback? _loadAfterAuthenticate;
ConvertUnknownErrorCallback? _convertUnknownError;

auth.FirebaseAuth get _auth => auth.FirebaseAuth.instance;

auth.User get _user =>
    _auth.currentUser ?? (throw FAWServiceExceptionUserNotLogged());

AuthUser _getUserLogged(auth.User? u, auth.UserCredential? cred) {
  final user = u ?? cred!.user!;
  return AuthUser(
    uid: user.uid,
    email: user.email,
    phone: user.phoneNumber,
    emailVerified: user.emailVerified,
    isNewUser: cred?.additionalUserInfo?.isNewUser ?? false,
    name:
        user.displayName ??
        cred?.additionalUserInfo?.username ??
        cred?.additionalUserInfo?.profile?['name'] as String?,
  );
}

extension FAWServiceInternal on FAWService {
  static set whenLogout(WhenLogoutCallback? callback) => _whenLogout = callback;

  static set loadAfterAuthenticate(LoadAfterAuthenticateCallback? callback) =>
      _loadAfterAuthenticate = callback;

  static set convertUnknownError(ConvertUnknownErrorCallback? callback) =>
      _convertUnknownError = callback;

  static Future<Result<void, FAWServiceUnknownError>>
  sendVerificationEmail() async {
    try {
      await _user.sendEmailVerification();
      return Success(null);
    } catch (e, stk) {
      return Failure(FAWServiceUnknownError(e, stk));
    }
  }

  static Future<Result<void, FAWServiceResetPasswordException>>
  sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Success(null);
    } catch (e, stk) {
      if (e is auth.FirebaseAuthException && e.code == 'invalid-email') {
        return Failure(FAWServiceResetPasswordExceptionInvalidEmail());
      }
      return Failure(FAWServiceUnknownError(e, stk));
    }
  }

  static Future<Result<bool, FAWServiceUnknownError>> emailVerified() async {
    try {
      await _user.reload();
      return Success(_user.emailVerified);
    } catch (e, stk) {
      return Failure(FAWServiceUnknownError(e, stk));
    }
  }

  static Future<Result<AuthUser, FAWServiceSignUpEmailException>> signUpEmail({
    required String email,
    required String password,
  }) async => _loadAfterLogin(.signUpEmail, () async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(_getUserLogged(null, cred));
    } catch (e, stk) {
      if (e is auth.FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            return Failure(FAWServiceSignUpEmailExceptionEmailExist());
          case 'invalid-email':
            return Failure(FAWServiceSignUpEmailExceptionInvalidEmail());
          case 'weak-password':
            return Failure(FAWServiceSignUpEmailExceptionWeakPassword());
        }
      }
      return Failure(FAWServiceUnknownError(e, stk));
    }
  });

  static Future<Result<AuthUser?, FAWServiceErrorAutoLogin>> autoLogin() =>
      _loadAfterLogin(.autoLogin, () {
        try {
          final currentUser = _auth.currentUser;
          if (currentUser == null) return Success(null);
          return Success(_getUserLogged(currentUser, null));
        } catch (e, stk) {
          return Failure(FAWServiceUnknownError(e, stk));
        }
      });

  static Future<Result<AuthUser, FAWServiceSignInEmailException>> signInEmail({
    required String email,
    required String password,
  }) => _loadAfterLogin(.signInEmail, () async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(_getUserLogged(null, cred));
    } catch (e, stk) {
      if (e is auth.FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email' || 'invalid-credential' || 'wrong-password':
            return Failure(
              FAWServiceSignInEmailExceptionEmailOrPasswordWrong(),
            );
          case 'user-disabled' || 'user-not-found':
            return Failure(FAWServiceSignInEmailErrorUserProblem());
          case 'too-many-requests':
            return Failure(FAWServiceSignInEmailErrorTooManyRequests());
        }
      }
      return Failure(FAWServiceUnknownError(e, stk));
    }
  });

  static Future<Result<AuthUser, FAWServiceLoginProviderException>>
  loginProvider(LoginProviderType loginProvider) =>
      _loadAfterLogin(.loginProvider, () async {
        try {
          final cred = await switch (loginProvider) {
            .google => _google(),
            .apple => _apple(),
          };
          return Success(_getUserLogged(null, cred));
        } catch (e, stk) {
          if (e is FAWServiceLoginProviderException) return Failure(e);
          if (e is auth.FirebaseAuthException) {
            final error = switch (e.code) {
              'web-context-cancelled' ||
              'popup-closed-by-user' ||
              'cancelled-popup-request' ||
              'canceled' => FAWServiceLoginProviderExceptionCancel(),
              'sign-in-failed' => FAWServiceLoginProviderExceptionCancel(),
              'user-disabled' => FAWServiceLoginProviderExceptionUserDisable(),
              _ => null,
            };
            if (error != null) return Failure(error);
          }

          return Failure(FAWServiceUnknownError(e, stk));
        }
      });

  static Future<auth.UserCredential> _google() async {
    final provider = auth.GoogleAuthProvider();
    provider.setCustomParameters({'prompt': 'select_account'});
    provider.addScope('https://www.googleapis.com/auth/user.phonenumbers.read');
    if (!kIsWeb) return _auth.signInWithProvider(provider);
    return _auth.signInWithPopup(provider);
  }

  static Future<auth.UserCredential> _apple() async {
    final provider = auth.AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    return _auth.signInWithProvider(provider);
  }

  static Future<Result<R, E>> _loadAfterLogin<
    R extends AuthUser?,
    E extends FAWServiceLoginError
  >(LoginType loginType, FutureOr<Result<R, E>> Function() login) async {
    try {
      final result = await login();
      if (result.isFailure) return await _maybeConvertError<R, E>(result);
      var info = result.successOrThrowFailure();

      if (_loadAfterAuthenticate != null) {
        final r = await _loadAfterAuthenticate!(loginType, info);
        if (r.isFailure) {
          return await _maybeConvertError<R, E>(Failure(r.value));
        }
        info = r.successOrThrowFailure() as R;
      }

      return Success(info);
    } catch (e, stk) {
      FAWServiceLoginError error = FAWServiceUnknownError(e, stk);
      if (e is FAWServiceLoginError) error = e;
      return _maybeConvertError<R, E>(Failure(error as E));
    }
  }

  static Future<Result<R, E>> _maybeConvertError<
    R extends AuthUser?,
    E extends FAWServiceLoginError
  >(Result<R, E> result) async {
    await FAWService.logout();
    if (_convertUnknownError == null) return result;
    final error = result.getFailure();
    if (error is! FAWServiceUnknownError) return result;
    return Failure(_convertUnknownError!(error) as E);
  }
}

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.isNewUser,
  });

  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final bool emailVerified;
  final bool isNewUser;
}

// UserNotLogged
//
class FAWServiceExceptionUserNotLogged implements Exception {}

// FAWServiceLoginError
//
sealed class FAWServiceLoginError implements Exception {
  const FAWServiceLoginError();
}

// SignUpEmailException
//
sealed class FAWServiceSignUpEmailException extends FAWServiceLoginError {}

final class FAWServiceSignUpEmailExceptionEmailExist
    implements FAWServiceSignUpEmailException {}

final class FAWServiceSignUpEmailExceptionInvalidEmail
    implements FAWServiceSignUpEmailException {}

final class FAWServiceSignUpEmailExceptionWeakPassword
    implements FAWServiceSignUpEmailException {}

// FAWServiceErrorAutoLogin
//
sealed class FAWServiceErrorAutoLogin extends FAWServiceLoginError {
  const FAWServiceErrorAutoLogin();
}

// SignInEmailException
//
sealed class FAWServiceSignInEmailException extends FAWServiceLoginError {}

final class FAWServiceSignInEmailExceptionEmailOrPasswordWrong
    implements FAWServiceSignInEmailException {}

final class FAWServiceSignInEmailErrorUserProblem
    implements FAWServiceSignInEmailException {}

final class FAWServiceSignInEmailErrorTooManyRequests
    implements FAWServiceSignInEmailException {}

// LoginProviderException
//
sealed class FAWServiceLoginProviderException extends FAWServiceLoginError {}

final class FAWServiceLoginProviderExceptionCancel
    implements FAWServiceLoginProviderException {}

final class FAWServiceLoginProviderExceptionUserDisable
    implements FAWServiceLoginProviderException {}

// ResetPasswordException
//
sealed class FAWServiceResetPasswordException implements Exception {}

final class FAWServiceResetPasswordExceptionInvalidEmail
    implements FAWServiceResetPasswordException {}

// FAWServiceUnknownError
//
class FAWServiceUnknownError extends Error
    implements
        FAWServiceResetPasswordException,
        FAWServiceSignInEmailException,
        FAWServiceSignUpEmailException,
        FAWServiceLoginProviderException,
        FAWServiceErrorAutoLogin {
  FAWServiceUnknownError(this.error, this._stackTrace);
  final Object error;
  final StackTrace? _stackTrace;
  @override
  StackTrace get stackTrace =>
      _stackTrace ?? super.stackTrace ?? StackTrace.current;
}
