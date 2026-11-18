import 'package:flutter/material.dart';

class const FAWOutlinedButton({
  required final String label,
  final VoidCallback? onPressed,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
