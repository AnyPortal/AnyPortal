import 'package:flutter/widgets.dart';

import 'global.dart';

void withContext(void Function(BuildContext context) cb) {
  final context = global.navigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  cb(context);
}
