import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:firebase_auth_well/src/faw_widget.dart';
import 'package:firebase_auth_well/src/widgets/scaffold.dart';
import 'package:firebase_auth_well/src/widgets/text_field_suffix.dart';
import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  final _signUp = Command(
    (({String email, String password}) i) =>
        FAWServiceInternal.signUpEmail(email: i.email, password: i.password),
    onError: (_, e, stk) =>
        CommandResultFailure(failure: FAWServiceUnknownError(e, stk)),
  );

  @override
  void dispose() {
    _signUp.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    super.dispose();
  }

  String? _fieldsValid() {
    final password = _passwordController.text.trim();
    final error =
        context.validateEmail(_emailController.text.trim()) ??
        context.validatePassword(password);
    if (error != null) return error;
    if (_passwordConfirmController.text.trim() != password) {
      return context.uiCopy.passwordsDontMatch;
    }
    return null;
  }

  Future<void> _onConfirm() async {
    FocusScope.of(context).unfocus();

    final msg = _fieldsValid();
    if (msg != null) return context.showFawMessage(msg);

    await _signUp((
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    ));
    if (!mounted) return;

    final copy = context.uiCopy;
    _signUp.result.foldAnyOrNull(
      onSuccess: (s) => context.navigateAuthSuccess(s.data),
      onFailure: (f) => switch (f.failure) {
        FAWServiceSignUpEmailExceptionEmailExist() => context.showFawMessage(
          copy.emailExist,
        ),
        FAWServiceSignUpEmailExceptionInvalidEmail() => context.showFawMessage(
          copy.emailInvalid,
        ),
        FAWServiceSignUpEmailExceptionWeakPassword() => context.showFawMessage(
          copy.weakPassword,
        ),
        FAWServiceUnknownError e => context.showFawUnknownError(e),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = context.uiCopy;
    return FAWScaffold(
      title: copy.signUpTitle,
      body: SafeArea(
        child: Align(
          alignment: .topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: .all(30),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    TextField(
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: copy.emailLabel,
                        hintText: copy.emailHint,
                        suffixIcon: TextFieldSuffix(),
                      ),
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    ),
                    SizedBox(height: 15),
                    _PasswordField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      label: copy.passwordLabel,
                      hint: copy.passwordHint,
                      onSubmitted: () =>
                          _passwordConfirmFocusNode.requestFocus(),
                    ),
                    SizedBox(height: 15),
                    _PasswordField(
                      focusNode: _passwordConfirmFocusNode,
                      controller: _passwordConfirmController,
                      label: copy.passwordConfirmLabel,
                      hint: copy.passwordHint,
                      onSubmitted: _onConfirm,
                    ),
                    SizedBox(height: 30),
                    ListenableBuilder(
                      listenable: _signUp,
                      builder: (context, _) => ElevatedButton(
                        onPressed: _signUp.isLoading ? null : _onConfirm,
                        child: _signUp.isLoading
                            ? SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(copy.signUpButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.focusNode,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onSubmitted,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: _obscureText,
      autofillHints: [AutofillHints.newPassword],
      onSubmitted: (_) => widget.onSubmitted(),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: TextFieldSuffix(
          obscureText: () => _obscureText,
          onTapObscure: () => _obscureText = !_obscureText,
        ),
      ),
    );
  }
}
