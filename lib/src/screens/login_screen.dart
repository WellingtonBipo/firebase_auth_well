import 'dart:async';

import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:firebase_auth_well/src/faw_widget.dart';
import 'package:firebase_auth_well/src/widgets/scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:utils_well/utils_well.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  //
  late final _logoAnimation = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300),
  );

  late final _loginProvider = Command(FAWServiceInternal.loginProvider);
  late final _autoLogin = Command((_) => FAWServiceInternal.autoLogin());
  late final _loginEmail = Command(
    (({String password, String email}) i) =>
        FAWServiceInternal.signInEmail(password: i.password, email: i.email),
  );

  late final _emailController = TextEditingController(
    text: kDebugMode ? context.uiCopy.debugLoginEmail : null,
  );
  late final _passwordController = TextEditingController(
    text: kDebugMode ? context.uiCopy.debugLoginPassword : null,
  );

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  late final listenables = [_autoLogin, _loginEmail, _loginProvider];

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    await _autoLogin(null);
    _autoLogin.result.foldAnyOrNull(
      onSuccess: (s) {
        final userInfo = s.data;
        if (userInfo == null) return;
        if (context.fawWidget.settings.mustHaveEmailVerified &&
            !userInfo.emailVerified) {
          return;
        }

        context.navigateAutoLoginSuccess();
      },
    );
  }

  @override
  void dispose() {
    _logoAnimation.dispose();
    _autoLogin.dispose();
    _loginEmail.dispose();
    _loginProvider.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        final r = _autoLogin.result;
        if (!r.isSuccess && !r.isFailure) {
          return ColoredBox(color: context.backgroundColor);
        }
        return IgnorePointer(
          ignoring: _loginEmail.isLoading || _loginProvider.isLoading,
          child: FAWScaffold(
            body: Column(
              children: [
                Builder(
                  builder: (context) =>
                      SizedBox(height: MediaQuery.paddingOf(context).top),
                ),
                Expanded(
                  child: _CustomLayout(
                    handleChildren: _handleLayout,
                    controller: _logoAnimation,
                    children: [
                      _body(),
                      ...?context.fawStyle.logo?.let(
                        (l) => [
                          ?l.brandMark?.let(
                            (e) => LayoutId(id: 'brandMark', child: e),
                          ),
                          ?l.logotype?.let(
                            (e) => LayoutId(id: 'logotype', child: e),
                          ),
                          ?l.slogan?.let(
                            (e) => LayoutId(id: 'slogan', child: e),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Size? _handleLayout(Map<Object?, SetableChild> children) {
    final body = children.values.first;
    var bodyHeight = body.minHeight();

    final bmC = context.fawStyle.logo?.brandMarkConstraints;
    final brandMark = children['brandMark'];
    final logotype = children['logotype'];
    final slogan = children['slogan'];

    var brandMarkHeight = brandMark == null
        ? 0.0
        : (bmC?.maxHeight ?? (brandMark.size.height));

    var logoHeight = 0.0;
    if (logotype != null) logoHeight += logotype.size.height;
    if (slogan != null) logoHeight += slogan.size.height;
    if (brandMark != null) logoHeight += brandMarkHeight;

    var freeSpace = body.constraints.maxHeight - bodyHeight;

    if (logoHeight > freeSpace) {
      // final b = logoHeight
      if (bmC != null && logoHeight - bmC._diff <= freeSpace) {
        brandMarkHeight -= logoHeight - freeSpace;
        if (brandMarkHeight < bmC.minHeight) {
          logoHeight -= bmC.minHeight - brandMarkHeight;
          brandMarkHeight = bmC.minHeight;
        }
      } else {}
    }

    // if (brandMark != null && logoHeight > freeSpace) {}

    freeSpace -= logoHeight;
    var startPoint = 0.0;

    if (freeSpace < 0) {
      bodyHeight += freeSpace;
      freeSpace = 0;
      if (bodyHeight < 50) {
        bodyHeight = 50;
        startPoint = -50;
      }
    }

    final hasLogo = logoHeight > 0;
    final space = freeSpace / (hasLogo ? 3 : 2);

    body.layout(
      constraints: (c) =>
          BoxConstraints(maxHeight: bodyHeight, maxWidth: c.maxWidth),
    );
    brandMark?.layout(
      constraints: (c) => BoxConstraints(maxHeight: brandMarkHeight),
    );

    var lastBottom = 0.0;
    double getBottom([SetableChild? child, double v = 0]) {
      lastBottom += v;
      child?.rect.height.let((b) => lastBottom += b);
      return lastBottom;
    }

    brandMark?._align(getBottom(null, space + startPoint));
    logotype?._align(getBottom(brandMark));
    slogan?._align(getBottom(logotype ?? brandMark));
    body._align(getBottom(logotype ?? brandMark ?? slogan, space));

    return null;
  }

  Widget _body() {
    var obscureText = true;
    final fields = Column(
      children: [
        TextField(
          focusNode: _emailFocusNode,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: context.uiCopy.emailLabel,
            hintText: context.uiCopy.emailHint,
          ),
          autofillHints: [AutofillHints.username],
          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        SizedBox(height: 15),
        StatefulBuilder(
          builder: (context, setState) {
            return TextField(
              focusNode: _passwordFocusNode,
              controller: _passwordController,
              obscureText: obscureText,
              autofillHints: [AutofillHints.password],
              onSubmitted: (_) => _onConfirm(),
              decoration: InputDecoration(
                labelText: context.uiCopy.passwordLabel,
                hintText: context.uiCopy.passwordHint,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => obscureText = !obscureText),
                ),
              ),
            );
          },
        ),
      ],
    );

    return Align(
      alignment: .center,
      child: Container(
        padding: .symmetric(horizontal: 30),
        constraints: BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisSize: .min,
            children: [
              AutofillGroup(child: fields),
              SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/reset-password'),
                child: Text(context.uiCopy.forgotPassword),
              ),
              SizedBox(height: 10),
              ListenableBuilder(
                listenable: Listenable.merge(listenables),
                builder: (context, _) {
                  return ElevatedButton(
                    onPressed: _onConfirm,
                    child: listenables.any((l) => l.isLoading).not
                        ? Text(context.uiCopy.signInButton)
                        : (Theme.of(context)
                                      .elevatedButtonTheme
                                      .style
                                      ?.textStyle
                                      ?.resolve({}) ??
                                  Theme.of(context).textTheme.bodyMedium!)
                              .textWidgetSize(context)
                              .let(
                                (s) => SizedBox.square(
                                  dimension: s.height - 4,
                                  child: CircularProgressIndicator(
                                    strokeWidth: s.height * 0.15,
                                  ),
                                ),
                              ),
                  );
                },
              ),
              SizedBox(height: 35),
              Align(
                child: Text(
                  context.uiCopy.orContinueWith,
                  style: context.textTheme.labelMedium,
                ),
              ),
              SizedBox(height: 15),
              Row(
                spacing: 10,
                children: [
                  _SocialButton(google: true, onTap: () => _onConfirm(.google)),
                  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                    _SocialButton(
                      google: false,
                      onTap: () => _onConfirm(.apple),
                    ),
                ],
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/sign-up'),
                child: Text(context.uiCopy.createAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm([LoginProviderType? type]) async {
    if (_emailFocusNode.hasFocus) _emailFocusNode.unfocus();
    if (_passwordFocusNode.hasFocus) _passwordFocusNode.unfocus();
    TextInput.finishAutofillContext();
    type == null ? await _doEmail() : await _doProvider(type);
  }

  Future<void> _doEmail() async {
    final msg = _fieldsValid();
    if (msg != null) return context.showFawMessage(msg);

    final infos = (
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    final loginCommand = _loginEmail;
    await loginCommand(infos);

    final error = loginCommand
        .result //
        .foldAnyOrNull<dynamic>(
          onSuccess: (r) => _onSuccess(r.data),
          onFailure: (f) => switch (f.failure) {
            FAWServiceSignInEmailExceptionEmailOrPasswordWrong() =>
              context.uiCopy.emailOrPasswordWrong,
            FAWServiceSignInEmailErrorUserProblem() =>
              context.uiCopy.accountProblem,
            FAWServiceSignInEmailErrorTooManyRequests() =>
              context.uiCopy.tooManyRequests,
            FAWServiceUnknownError() => f.failure,
          },
        );

    if (mounted) return _showError(error);
  }

  String? _fieldsValid() =>
      context.validateEmail(_emailController.text.trim()) ??
      context.validatePassword(_passwordController.text.trim());

  Future<void> _doProvider(LoginProviderType type) async {
    await _loginProvider(type);
    final error = _loginProvider.result.foldAnyOrNull<dynamic>(
      onSuccess: (r) => _onSuccess(r.data),
      onFailure: (f) => switch (f.failure) {
        FAWServiceLoginProviderExceptionCancel() => null,
        FAWServiceLoginProviderExceptionUserDisable() =>
          context.uiCopy.userDisabled,
        FAWServiceUnknownError() => f.failure,
      },
    );

    if (mounted) return _showError(error);
  }

  Future<void> _onSuccess(AuthUser userInfo) =>
      context.navigateAuthSuccess(userInfo);

  void _showError(dynamic error) {
    if (error is String) context.showFawMessage(error);
    if (error is FAWServiceUnknownError) context.showFawUnknownError(error);
  }
}

extension on BoxConstraints {
  double get _diff => maxHeight - minHeight;
}

extension on SetableChild {
  void _align(double v) => align(.topCenter, top: v);
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.google, required this.onTap});

  final bool google;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final fileName = google ? 'google_icon' : 'apple_icon';
    final style =
        Theme.of(context).outlinedButtonTheme.style?.textStyle?.resolve({}) ??
        Theme.of(context).textTheme.bodyMedium!;
    final height = style.textWidgetSize(context).height;
    return Expanded(
      child: OutlinedButton.icon(
        // style: context.outlinedButtonStyle,
        label: Text(google ? 'Google' : 'Apple'),
        icon: Image.asset(
          package: 'firebase_auth_well',
          'assets/$fileName.png',
          height: height * 0.75,
          color: google
              ? null
              : context.isLight
              ? Colors.black
              : Colors.white,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class const _CustomLayout({
  required super.children,
  required super.handleChildren,
  required final AnimationController controller,
}) extends CustomLayout {
  @override
  RenderCustomLayout createRenderObject(BuildContext context) {
    return _RenderCustomLayout(handleChildren, controller);
  }
}

class _RenderCustomLayout(
  super.handleChildren,
  final AnimationController controller,
) extends RenderCustomLayout {}

class const CustomLayout({
  required super.children,
  required this.handleChildren, //
  super.key,
}) extends MultiChildRenderObjectWidget {
  final Size? Function(Map<Object?, SetableChild> children) handleChildren;

  @override
  RenderCustomLayout createRenderObject(BuildContext context) {
    return RenderCustomLayout(handleChildren);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    renderObject as RenderCustomLayout;
    renderObject.handleChildren = handleChildren;
    super.updateRenderObject(context, renderObject);
  }
}

class RenderCustomLayout(
  var Size? Function(Map<Object?, SetableChild> children) handleChildren,
) extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    final children = <Object?, SetableChild>{};
    RenderBox? child = firstChild;
    while (child != null) {
      final setChild = SetableChild._(child, constraints);
      children[setChild.id] = setChild;
      child = setChild._childParentData.nextSibling;
    }

    final size = handleChildren(children);

    for (final entry in children.entries) {
      final child = entry.value;
      if (!child._isLaidOut) child.layout();
      child._childParentData.offset = child.position;
    }

    this.size = size ?? constraints.biggest;
  }
}

class SetableChild {
  SetableChild._(this._box, this.constraints);

  final BoxConstraints constraints;
  final RenderBox _box;
  late final _childParentData = _box.parentData as MultiChildLayoutParentData;

  var _isLaidOut = false;
  var position = Offset.zero;

  Rect get rect => position & size;

  Object? get id => _childParentData.id;

  Size get size {
    if (!_isLaidOut) layout();
    return _box.size;
  }

  void layout({
    bool parentUsesSize = true,
    BoxConstraints Function(BoxConstraints c)? constraints,
  }) {
    var constr = constraints?.call(this.constraints);
    _box.layout(
      parentUsesSize: parentUsesSize,
      constr ??
          BoxConstraints(
            maxWidth: this.constraints.maxWidth,
            maxHeight: this.constraints.maxHeight,
          ),
    );
    _isLaidOut = true;
  }

  double maxHeight() => _box.getMaxIntrinsicHeight(constraints.minWidth);

  double minHeight() => _box.getMinIntrinsicHeight(constraints.maxWidth);

  double maxWidth() => _box.getMaxIntrinsicWidth(constraints.minHeight);

  double minWidth() => _box.getMinIntrinsicWidth(constraints.maxHeight);

  void setPosition({double? x, double? y}) => position = Offset(x ?? 0, y ?? 0);

  void align(
    Alignment alignment, {
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) {
    double xSpace() => constraints.maxWidth - left - right;
    double ySpace() => constraints.maxHeight - top - bottom;

    double xCenter() => left + (xSpace() / 2) - (size.width / 2);
    double yCenter() => top + (ySpace() / 2) - (size.height / 2);
    double getRight() => left + xSpace() - size.width;
    double getBottom() => top + ySpace() - size.height;

    position = switch (alignment) {
      .topLeft => Offset(left, top),
      .topCenter => Offset(xCenter(), top),
      .topRight => Offset(getRight(), top),
      .centerLeft => Offset(left, yCenter()),
      .center => Offset(xCenter(), yCenter()),
      .centerRight => Offset(getRight(), yCenter()),
      .bottomLeft => Offset(left, getBottom()),
      .bottomCenter => Offset(xCenter(), getBottom()),
      .bottomRight => Offset(getRight(), getBottom()),
    };
  }
}

enum Alignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}
