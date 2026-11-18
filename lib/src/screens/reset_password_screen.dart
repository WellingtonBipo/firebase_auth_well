import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:firebase_auth_well/src/faw_widget.dart';
import 'package:firebase_auth_well/src/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({this.email, super.key});

  final String? email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final _emailController = TextEditingController(
    text: widget.email,
  );
  final _send = Command(FAWServiceInternal.sendPasswordResetEmail);

  @override
  void dispose() {
    _send.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final msg = context.validateEmail(email);
    if (msg != null) return context.showFawMessage(msg);

    await _send(email);
    if (!mounted) return;

    final copy = context.uiCopy;
    _send.result.foldAnyOrNull(
      onSuccess: (_) {
        context.showFawMessage(copy.resetPasswordSent, error: false);
        Navigator.of(context).pop();
      },
      onFailure: (f) => switch (f.failure) {
        FAWServiceResetPasswordExceptionInvalidEmail() =>
          context.showFawMessage(copy.emailInvalid),
        FAWServiceUnknownError e => context.showFawUnknownError(e),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = context.uiCopy;
    return FAWScaffold(
      title: copy.resetPasswordTitle,
      body: SafeArea(
        child: Align(
          alignment: .topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: .all(30),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Text(copy.resetPasswordInstructions),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: copy.emailLabel,
                      hintText: copy.emailHint,
                    ),
                    onSubmitted: (_) => _onConfirm(),
                  ),
                  SizedBox(height: 30),
                  ListenableBuilder(
                    listenable: _send,
                    builder: (context, _) => ElevatedButton(
                      onPressed: _send.isLoading ? null : _onConfirm,
                      child: _send.isLoading
                          ? SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(copy.resetPasswordButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
