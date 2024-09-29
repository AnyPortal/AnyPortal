import 'package:flutter/material.dart';

class Blockquote extends StatelessWidget {
  final String text;

  const Blockquote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}