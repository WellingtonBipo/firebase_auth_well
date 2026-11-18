import 'dart:async';

import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:firebase_auth_well/src/faw_widget.dart';
import 'package:firebase_auth_well/src/widgets/scaffold.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _resendCooldown = 60;

  final _secondsRemaining = ValueNotifier(0);
  Timer? _timerChecking;
  Timer? _timerResend;
  var _checking = false;

  late final AuthUser? _user =
      ModalRoute.of(context)?.settings.arguments as AuthUser?;

  @override
  void initState() {
    super.initState();
    _timerChecking = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _check(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendEmail());
  }

  @override
  void dispose() {
    _timerChecking?.cancel();
    _timerResend?.cancel();
    _secondsRemaining.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    final result = await FAWServiceInternal.emailVerified();
    _checking = false;
    if (!mounted || !result.isSuccess) return;
    if (!result.successOrThrowFailure()) return;
    _timerChecking?.cancel();
    final user = _user;
    if (user == null) {
      await context.navigateAutoLoginSuccess();
      return;
    }
    await context.navigateAuthSuccess(
      AuthUser(
        uid: user.uid,
        name: user.name,
        email: user.email,
        phone: user.phone,
        emailVerified: true,
        isNewUser: user.isNewUser,
      ),
    );
  }

  Future<void> _sendEmail() async {
    _startCountdown();
    final result = await FAWServiceInternal.sendVerificationEmail();
    if (!mounted || !result.isFailure) return;
    _timerResend?.cancel();
    _secondsRemaining.value = 0;
    context.showFawUnknownError(
      result.getFailure()!,
      context.uiCopy.resendEmailError,
    );
  }

  void _startCountdown() {
    _timerResend?.cancel();
    _secondsRemaining.value = _resendCooldown;
    _timerResend = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsRemaining.value--;
      if (_secondsRemaining.value <= 0) _timerResend?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = context.uiCopy;
    final textTheme = Theme.of(context).textTheme;
    return FAWScaffold(
      title: copy.verifyEmailTitle,
      body: SafeArea(
        child: Align(
          alignment: .topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 450),
            padding: .all(30),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(
                  copy.verifyEmailSent(_user?.email),
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: 20),
                Text(copy.verifyEmailInstructions, style: textTheme.bodyMedium),
                Spacer(),
                ValueListenableBuilder(
                  valueListenable: _secondsRemaining,
                  builder: (context, seconds, _) {
                    final canResend = seconds <= 0;
                    return ElevatedButton(
                      onPressed: canResend ? _sendEmail : null,
                      child: Text(
                        canResend
                            ? copy.resendEmail
                            : copy.resendEmailIn(seconds),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
