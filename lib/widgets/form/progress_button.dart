import 'package:flutter/material.dart';

class ProgressButton extends StatelessWidget {
  final bool isInProgress;
  final VoidCallback onPressed;
  final Widget child;

  const ProgressButton({
    super.key,
    required this.isInProgress,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
          onPressed: isInProgress ? null : onPressed,
          child: isInProgress
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
              : child),
    );
  }
}
