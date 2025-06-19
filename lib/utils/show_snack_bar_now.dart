import 'package:flutter/material.dart';

void showSnackBarNow(BuildContext context, Widget content) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: content,
    ));
  }
}
