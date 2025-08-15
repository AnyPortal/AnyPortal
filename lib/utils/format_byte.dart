import 'dart:math';

const unitPrefixes = ["", "K", "M", "G", "T", "P", "E", "Z", "Y", "R", "Q"];

String formatBytes(int bytes, {int fractionDigits = 2, int base = 1024}) {
  if (bytes <= 0) return "0B";
  int i = (log(bytes) / log(base)).floor();
  String bi = base == 1024 ? "i" : "";
  return '${(bytes / pow(base, i)).toStringAsFixed(fractionDigits)}${unitPrefixes[i]}${bi}B';
}
