# (FAW) Firebase Auth Well

Reusable Firebase authentication for Flutter apps: a service plus ready-made screens.

- Login and sign up with email and password
- Login with Google (all platforms) and Apple (iOS)
- Auto login
- Email verification
- Password reset
  
Requires Dart SDK `^3.13.0`, `firebase_core` and `firebase_auth`.

## Installation

```yaml
dependencies:
  firebase_auth_well:
    git:
      url: <repository url>
      path: firebase_auth_well
```

## Firebase setup

1. Create a Firebase project and enable **Authentication** in the console. Without it every call fails with `configuration-not-found`.
2. Enable the sign-in providers you need (Email/Password, Google, Apple).
3. Generate `firebase_options.dart` with `flutterfire configure` and initialize Firebase before `runApp`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```

## FAWWidget

`FAWWidget` is the app's starting point and must be used as the `home` of the `MaterialApp`. It hosts its own internal `Navigator` with the screens:

- **Login**: email/password, Google, Apple (iOS only), links to sign up and password reset
- **Sign up**: email, password and password confirmation
- **Verify email**: sends the verification email, checks every 2s and continues automatically once verified. Resend has a 60s cooldown
- **Reset password**: sends the password reset email

Navigation between these screens is handled by the package; they are not routes of your app.

On open, the login screen tries an auto login with the current Firebase session.

Since `FAWWidget` is the `home`, it lives at the `MaterialApp` default route `'/'`. To return to the FAW login from anywhere in the app (e.g. after logout), navigate to `'/'` (see [Logout](#logout)).

After a successful authentication FAW replaces the root route with the route returned by one of the callbacks. The routes must exist in the `MaterialApp` (`routes` or `onGenerateRoute`).

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
      },
      home: FAWWidget(
        routeLoginSuccess: () => MyApi.isRegistered ? '/home' : '/register',
        routeSignUpSuccess: () => '/register',
        routeAutoLoginSuccess: () => '/home',
        settings: FAWWidgetSettings(
          mustHaveEmailVerified: true,
          uiCopy: UICopy(signInButton: 'Sign in'),
        ),
        style: FAWWidgetStyle(
          logo: FAWLogo(
            brandMark: Image.asset('assets/logo.png'),
            logotype: Text('My App'),
            slogan: Text('My slogan'),
          ),
        ),
      ),
    );
  }
}
```

### Route callbacks

| Parameter | When | Notes |
| --- | --- | --- |
| `routeLoginSuccess` (required) | Login with email or provider | Also the fallback of the other two |
| `routeSignUpSuccess` | First authentication of a new user (email sign up or first provider login) | Falls back to `routeLoginSuccess` |
| `routeAutoLoginSuccess` | Auto login on app start | Falls back to `routeLoginSuccess`. Returning `null` keeps the user on the login screen |

All callbacks can be async (`FutureOr`).

### FAWWidgetSettings

| Field | Default | Description |
| --- | --- | --- |
| `mustHaveEmailVerified` | `false` | Sends unverified users to `/verify-email` before continuing. Auto login of an unverified user stays on the login screen |
| `minPasswordLength` | `8` | Minimum password length validated on login and sign up |
| `uiCopy` | `UICopy()` | All texts of the screens |
| `whenLogout` | `null` | Called after `FAWService.logout()` |
| `loadAfterAuthenticate` | `null` | Called after every successful authentication with the `LoginType` and the `AuthUser`. Return a `Success` to continue (optionally with a modified user) or a `Failure` to abort; on failure the user is logged out |
| `convertUnknownError` | `null` | Maps unknown errors before they reach the UI |

### UICopy

Every text shown by the screens. Defaults are in Brazilian Portuguese; override only what you need.

```dart
UICopy(
  signInButton: 'Sign in',
  passwordTooShort: (min) => 'Use at least $min characters.',
  verifyEmailSent: (email) => 'We sent a link to ${email ?? 'your email'}.',
  resendEmailIn: (seconds) => 'Resend in ${seconds}s',
  handleUnknownError: (error) => 'Something went wrong.',
)
```

`debugLoginEmail` and `debugLoginPassword` prefill the login fields in debug builds only (`kDebugMode`).

### FAWWidgetStyle

| Field | Description |
| --- | --- |
| `logo` | `FAWLogo(brandMark, logotype, slogan, brandMarkConstraints)` shown on the login screen |
| `appBar` | `FAWAppBarStyle(height)` |
| `dialogsStyle` | `FAWDialogsStyle(buttonsStyle)` |
| `primaryColor` | Defaults to `Theme.primaryColor` |
| `backgroundLightColor` / `backgroundDarkColor` | Default to `Theme.scaffoldBackgroundColor` |
| `textThemeLight` / `textThemeDark` | Default to `Theme.textTheme` |

## FAWService

Available anywhere after authentication.

| Member | Description |
| --- | --- |
| `FAWService.user` | The logged `AuthUser` (`uid`, `name`, `email`, `phone`, `emailVerified`, `isNewUser`). Throws `FAWServiceExceptionUserNotLogged` when there is no session |
| `FAWService.firebaseJwt` | Firebase ID token of the current user, or `null` |
| `FAWService.logout()` | Signs out and calls `whenLogout` |
| `FAWService.deleteAccount()` | Deletes the Firebase user and logs out |

## Password reset inside the app

`FAWResetPasswordScreen` is the same reset password screen, usable outside `FAWWidget` (e.g. in the logged area). Pass the same `FAWWidgetSettings` used by `FAWWidget` so the texts match, and optionally `email` to prefill the field. On success it shows a message and pops back.

```dart
const fawSettings = FAWWidgetSettings(mustHaveEmailVerified: true);

MaterialApp(
  routes: {
    '/home': (context) => const HomePage(),
    '/reset-password': (context) => FAWResetPasswordScreen(
      settings: fawSettings,
      email: FAWService.user.email,
    ),
  },
  home: FAWWidget(
    routeLoginSuccess: () => '/home',
    settings: fawSettings,
  ),
);
```

```dart
Navigator.of(context).pushNamed('/reset-password');
```

## Logout

Logout example, returning to the FAW login. `'/'` is the `home` route, where `FAWWidget` is; `pushNamedAndRemoveUntil` clears the stack so the user can't go back to the logged area:

```dart
Future<void> logout(BuildContext context) async {
  final nav = Navigator.of(context);
  await FAWService.logout();
  nav.pushNamedAndRemoveUntil('/', (_) => false);
}
```

## Example

`example/` contains a runnable app with the full flow (sign up, email verification, Google login, home, logout). It uses its own Firebase project configured in `example/lib/firebase_options.dart`.

```bash
cd example
flutter run
```
