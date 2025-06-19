import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, Widget content) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: content,
    ));
  }
}
