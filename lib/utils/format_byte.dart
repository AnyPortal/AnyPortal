import 'dart:math';

String formatBytes(int bytes, {int fractionDigits = 2}) {
  if (bytes <= 0) return "0B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(fractionDigits)}${suffixes[i]}';
}
