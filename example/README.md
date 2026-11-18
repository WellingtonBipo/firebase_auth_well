# FAW Example

Runnable Flutter app showing the complete `firebase_auth_well` flow: login, sign up, email verification, Google login, password reset, a post-auth "register" step, home and logout.

## What it demonstrates

| Feature | Where |
| --- | --- |
| `FAWWidget` as the app's `home` | `ExampleApp.build` |
| Route callbacks (`routeLoginSuccess`, `routeSignUpSuccess`) | `ExampleApp.build` |
| Forced email verification (`mustHaveEmailVerified: true`) | `fawSettings` |
| Debug prefill of the login fields (`debugLoginEmail` / `debugLoginPassword`) | `fawSettings` |
| Custom logo with responsive brand mark (`FAWLogo` + `brandMarkConstraints`) | `ExampleApp.build` |
| `FAWResetPasswordScreen` used outside `FAWWidget` | `/reset-password` route |
| `FAWService.user` and `FAWService.logout()` | `HomePage`, `_logoutToLogin` |

## Flow

```text
Login ──► (email not verified) ──► Verify email ──┐
  │                                               │
  ├─ Sign up ──► Verify email ───────────────────►├──► /register ──► /home
  │                                               │
  └─ Google ──────────────────────────────────────┘
```

- After any successful authentication the app goes to `/register` (`routeSignUpSuccess`, and `routeLoginSuccess` while `isRegistered` is `false`). In a real app this is where you would complete the user's profile in your backend.
- `isRegistered` is never set to `true` in this example, so every login passes through `/register`. Use **Go to home** to continue.
- `/home` shows the logged user, opens the in-app password reset and logs out back to the FAW login.
- Reopening the app with a valid session triggers auto login.

## Running

The example is configured for **web only** (see `lib/firebase_options.dart`).

```bash
cd example
flutter pub get
flutter run -d chrome
```

The app is wrapped in [`device_preview`](https://pub.dev/packages/device_preview) with an iPhone SE (3rd gen) frame in dark mode. `main.dart` also simulates the on-screen keyboard: it animates the `keyboardInset` whenever a text field gets focus, so you can see how the login layout shrinks the logo.

To run without the device frame, remove the `DevicePreview` lines from `main()`.

## Firebase project

By default the example points to the Firebase project `faw-pkg-example`. To use your own project:

1. Create a Firebase project and enable **Authentication** with the **Email/Password** and **Google** providers.
2. Make sure `localhost` is listed in **Authentication › Settings › Authorized domains** (it is by default) so Google login works with `flutter run`.
3. Regenerate the options:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<your-project-id> --platforms=web
   ```

   This rewrites `lib/firebase_options.dart`, `firebase.json` and `.firebaserc`.

To add Android, iOS or macOS, create the platform folders with `flutter create --platforms=android,ios .` and run `flutterfire configure` again with those platforms. Google login on Android also needs the app's SHA-1 registered in Firebase; Apple login (shown on iOS only) needs the Apple provider enabled and the *Sign in with Apple* capability in Xcode.

## Debug credentials

`fawSettings.uiCopy.debugLoginEmail` and `debugLoginPassword` prefill the login form in debug builds only (`kDebugMode`). Point them to a test account of **your** Firebase project, or leave them empty. Avoid committing real credentials: read them from `--dart-define` instead, for example:

```dart
uiCopy: UICopy(
  debugLoginEmail: String.fromEnvironment('FAW_DEBUG_EMAIL'),
  debugLoginPassword: String.fromEnvironment('FAW_DEBUG_PASSWORD'),
),
```

```bash
flutter run -d chrome --dart-define=FAW_DEBUG_EMAIL=me@example.com --dart-define=FAW_DEBUG_PASSWORD=secret
```

## Testing email verification

Sign up with an email inbox you can access. The verify email screen sends the link automatically, checks every 2 seconds and continues on its own once you click the link. A Gmail alias (`you+faw1@gmail.com`, `you+faw2@gmail.com`, …) is a quick way to create several test accounts.
