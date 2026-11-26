import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_auth_well/src/faw_service.dart';
import 'package:firebase_auth_well/src/faw_widget.dart';
import 'package:firebase_auth_well/src/widgets/scaffold.dart';
import 'package:firebase_auth_well/src/widgets/text_field_suffix.dart';
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

  late final _listenables = [_autoLogin, _loginEmail, _loginProvider];

  var _obscureText = true;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  @override
  void dispose() {
    _autoLogin.dispose();
    _loginEmail.dispose();
    _loginProvider.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _tryAutoLogin() async {
    await _autoLogin(null);
    _autoLogin.result.foldAnyOrNull(
      onSuccess: (s) {
        final userInfo = s.data;
        if (userInfo == null) return;
        if (context.fawSettings.mustHaveEmailVerified &&
            !userInfo.emailVerified) {
          return;
        }

        context.navigateAutoLoginSuccess();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(_listenables),
      builder: (context, _) {
        final r = _autoLogin.result;
        if (r._isLoading) return ColoredBox(color: context.backgroundColor);
        return IgnorePointer(
          ignoring: _loginEmail.isLoading || _loginProvider.isLoading,
          child: FAWScaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                Builder(
                  builder: (context) => SizedBox(
                    height: MediaQuery.paddingOf(context).top,
                  ),
                ),
                Expanded(
                  child: _CustomLayout(
                    children: [
                      ?context.fawStyle.logo?.let(
                        (l) {
                          if (l.brandMark == null &&
                              l.logotype == null &&
                              l.slogan == null) {
                            return null;
                          }
                          return LayoutId(id: 'logo', child: _Logo(l));
                        },
                      ),
                      LayoutId(
                        id: 'signin',
                        child: _signin(),
                      ),
                      LayoutId(
                        id: 'signup',
                        child: _signup(),
                      ),
                    ],
                    handleChildren: (children) {
                      final logo = children['logo'];
                      final signin = children['signin']!;
                      final signup = children['signup']!;

                      final maxHeight = signin.constraints.maxHeight;

                      final space =
                          maxHeight -
                          signin.size.height -
                          (signup.size.height +
                              MediaQuery.viewPaddingOf(context).bottom);

                      final hasLogo = logo != null;
                      final flex = hasLogo ? (space > 700 ? 6 : 8) : 3;
                      final between = space / (flex + (hasLogo ? 2 : 0));

                      signup._align(
                        maxHeight -
                            signup.size.height -
                            between -
                            MediaQuery.viewPaddingOf(context).bottom,
                      );

                      final signinY2 = signup.position.dy - between;
                      var signinY1 = signinY2 - signin.size.height;

                      MediaQuery.viewInsetsOf(context).bottom.let((bottom) {
                        final signinY2bottomSpace = maxHeight - signinY2;
                        if (bottom < signinY2bottomSpace) return;
                        signinY1 -= bottom - signinY2bottomSpace;
                      });

                      signin._align(signinY1);

                      logo?.let((l) {
                        final logoHeight =
                            signin.position.dy - (2 * _logoPadding(context));
                        l.layout(
                          constraints: (c) => c.enforce(
                            BoxConstraints(
                              maxHeight: logoHeight,
                              maxWidth: c.maxWidth - 2 * _horizontalPadding,
                            ),
                          ),
                        );
                        l._align(
                          _logoPadding(context) +
                              logoHeight / 2 -
                              logo.size.height / 2,
                        );
                      });

                      return;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _signin() {
    return Container(
      padding: .symmetric(horizontal: _horizontalPadding),
      constraints: BoxConstraints(maxWidth: 450),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        children: [
          AutofillGroup(
            child: Column(
              children: [
                TextField(
                  focusNode: _emailFocusNode,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: context.uiCopy.emailLabel,
                    hintText: context.uiCopy.emailHint,
                    suffixIcon: TextFieldSuffix(),
                  ),
                  autofillHints: [AutofillHints.username, AutofillHints.email],
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
                SizedBox(height: 15),
                StatefulBuilder(
                  builder: (context, setState) {
                    return TextField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      obscureText: _obscureText,
                      autofillHints: [AutofillHints.password],
                      onSubmitted: (_) => _onConfirm(),
                      decoration: InputDecoration(
                        labelText: context.uiCopy.passwordLabel,
                        hintText: context.uiCopy.passwordHint,
                        suffixIcon: TextFieldSuffix(
                          obscureText: () => _obscureText,
                          onTapObscure: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/reset-password'),
            child: Text(context.uiCopy.forgotPassword),
          ),
          SizedBox(height: 10),
          ListenableBuilder(
            listenable: Listenable.merge(_listenables),
            builder: (context, _) {
              return ElevatedButton(
                onPressed: _onConfirm,
                child: _listenables.any((l) => l.isLoading).not
                    ? Text(context.uiCopy.signInButton)
                    : (Theme.of(context).elevatedButtonTheme.style?.textStyle
                                  ?.resolve({}) ??
                              Theme.of(context).textTheme.bodyMedium!)
                          .textWidgetSize(context)
                          .let(
                            (s) => SizedBox.square(
                              dimension: s.height - 1,
                              child: CircularProgressIndicator(
                                strokeWidth: s.height * 0.15,
                              ),
                            ),
                          ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _signup() {
    return Container(
      padding: .symmetric(horizontal: _horizontalPadding),
      constraints: BoxConstraints(maxWidth: 450),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        children: [
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

class const _Logo(final FAWLogo logo) extends StatefulWidget {
  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 240),
  );

  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  double? __value;
  double get _value => __value ?? _animation.value;

  var _padding = 0.0;

  @override
  void dispose() {
    _animationController.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController.addListener(() => setState(() {}));
  }

  Widget? _makeChild(
    Widget? Function(BuildContext, double)? w,
    String name,
  ) => w?.call(context, _value)?.let((e) => LayoutId(id: name, child: e));

  @override
  Widget build(BuildContext context) {
    return _CustomLayout(
      children: [
        ?_makeChild(widget.logo.brandMark, 'brandMark'),
        ?_makeChild(widget.logo.logotype, 'logotype'),
        ?_makeChild(widget.logo.slogan, 'slogan'),
      ],
      handleChildren: (children) {
        final brandMark = children['brandMark'];
        final logotype = children['logotype'];
        final slogan = children['slogan'];

        final BoxConstraints(:maxHeight, :maxWidth) =
            (brandMark ?? logotype ?? slogan)!.constraints;

        final logoTypeSloganHeight =
            (logotype?.size.height ?? 0) + (slogan?.size.height ?? 0);

        final brandConstr = brandMark?.let(
          (_) => widget.logo.brandMarkConstraints,
        );
        final minBrandHeight = brandConstr?.minHeight ?? 0;
        final maxBrandHeight = brandConstr?.maxHeight ?? double.infinity;

        final minVertHeight = logoTypeSloganHeight + minBrandHeight;

        final shouldBeHorizontal = minVertHeight > maxHeight;

        _maybeAnimate(context, shouldBeHorizontal);

        final brandHeight = math.min(
          maxBrandHeight,
          maxHeight - logoTypeSloganHeight,
        );

        brandMark?.layout(
          constraints: (c) => c.enforce(
            BoxConstraints(
              maxHeight: shouldBeHorizontal.not
                  ? brandHeight
                  : math.min(
                      maxHeight,
                      lerpDouble(brandHeight, maxHeight, _value)!,
                    ),
            ),
          ),
        );

        var emptySpaceVert =
            (maxHeight - logoTypeSloganHeight - (brandMark?.size.height ?? 0));
        emptySpaceVert = emptySpaceVert.clamp(0, .infinity);

        if (shouldBeHorizontal.not) {
          brandMark?._align(emptySpaceVert / 2);
          logotype?._align(
            brandMark?.rect.bottom ?? (emptySpaceVert / 2),
          );
          slogan?._align(
            (logotype ?? brandMark)?.rect.bottom ?? (emptySpaceVert / 2),
          );
          return;
        }

        final emptySpaceHor =
            maxWidth -
            (brandMark?.rect.width ?? 0) -
            math.max(logotype?.size.width ?? 0, slogan?.size.width ?? 0);

        final brandY = (emptySpaceVert / 2) + (brandMark?.size._centerX ?? 0);

        final centerVertX = maxWidth / 2;

        brandMark?.setPosition(
          centerY: lerpDouble(brandY, maxHeight / 2, _value),
          centerX: lerpDouble(
            centerVertX,
            (emptySpaceHor / 2) + brandMark.size._centerX,
            _value,
          ),
        );

        final centerHorLogoTypeSloganX = lerpDouble(
          centerVertX,
          (maxWidth - (emptySpaceHor / 2)) -
              ((logotype ?? slogan)?.rect.width ?? 0) / 2,
          _value,
        )!;

        final logotypeY = lerpDouble(
          brandY + ((brandMark?.size.width ?? 0) / 2),
          (maxHeight - logoTypeSloganHeight) / 2,
          _value,
        )!;

        logotype?.setPosition(
          y: logotypeY,
          centerX: centerHorLogoTypeSloganX,
        );

        slogan?.setPosition(
          y: logotypeY + (logotype?.size.height ?? 0),
          centerX: centerHorLogoTypeSloganX,
        );

        return;
      },
    );
  }

  void _maybeAnimate(BuildContext context, bool shouldBeHorizontal) {
    final currentPadding = MediaQuery.viewInsetsOf(context).bottom;
    if (currentPadding == 0 && shouldBeHorizontal) {
      __value = 1;
      addPostFrameCallback(
        () => _animation.value == 1 ? null : _animationController.value = 1,
      );
      return;
    }
    __value == null;
    if (currentPadding != _padding) {
      shouldBeHorizontal && currentPadding > _padding
          ? _animationController.forward()
          : _animationController.reverse();
      _padding = currentPadding;
    }
  }
}

class const _CustomLayout({
  required super.children,
  required super.handleChildren,
}) extends CustomLayout {
  @override
  RenderCustomLayout createRenderObject(BuildContext context) {
    return _RenderCustomLayout(handleChildren);
  }
}

class _RenderCustomLayout(
  super.handleChildren,
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
    if (!_isLaidOut || !_box.hasSize) layout();
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

  void setPosition({
    double? x,
    double? y,
    double? centerX,
    double? centerY,
  }) => position = Offset(
    centerX?.let((v) => v - size.width / 2) ?? x ?? 0,
    centerY?.let((v) => v - size.height / 2) ?? y ?? 0,
  );

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

final _horizontalPadding = 30.0;

double _logoPadding(BuildContext context) =>
    MediaQuery.sizeOf(context).longestSide * .02;

extension on Size {
  double get _centerX => center(.zero).dx;
}

extension on SetableChild {
  void _align(double v) => align(.topCenter, top: v);
}

extension on CommandResult<AuthUser?, FAWServiceErrorAutoLogin> {
  bool get _isLoading => isLoading || isInitial;
}
