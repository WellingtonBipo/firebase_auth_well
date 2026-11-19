import 'package:flutter/material.dart';
import 'package:utils_well/utils_well.dart';

class const TextFieldSuffix({
  final bool Function()? obscureText,
  final VoidCallback? onTapObscure,
  final bool showCleanButton = true,
  super.key,
}) extends StatefulWidget {
  @override
  State<TextFieldSuffix> createState() => _TextFieldSuffixState();
}

class _TextFieldSuffixState extends State<TextFieldSuffix> {
  EditableTextState? _editableTextState;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _controller?.removeListener(_setState);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TextFieldSuffix oldWidget) {
    super.didUpdateWidget(oldWidget);
    _subscribe();
  }

  void _setState() => setState(() {});

  void _subscribe() {
    _editableTextState = context
        .findAncestorStateOfType<State<TextField>>()
        ?.letType<TextSelectionGestureDetectorBuilderDelegate>()
        ?.editableTextKey
        .currentState;
    _controller?.removeListener(_setState);
    _controller = _editableTextState?.widget.controller;
    _controller?.addListener(_setState);
  }

  @override
  Widget build(BuildContext context) {
    final obscureWidget = widget.obscureText?.let(
      (e) => IconButton(
        icon: Icon(e() ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          widget.onTapObscure?.call();
          _setState();
        },
      ),
    );

    final cleanWidget = _controller?.let(
      (c) => c.text.isEmpty
          ? null
          : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _controller?.clear(),
            ),
    );

    return Row(
      mainAxisSize: .min,
      children: [
        ?cleanWidget,
        ?obscureWidget,
      ],
    );
  }
}
