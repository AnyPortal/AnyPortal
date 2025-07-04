import 'package:flutter/material.dart';

class LogHighlighter extends StatelessWidget {
  final String logLine;

  const LogHighlighter({super.key, required this.logLine});

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        children: _highlightLog(logLine),
      ),
    );
  }

  List<TextSpan> _highlightLog(String text) {
    final patterns = <RegExp, TextStyle>{
      // Date: 2025/07/04 or 2025-07-04
      RegExp(r'\b\d{4}[/-]\d{2}[/-]\d{2}\b'):
          TextStyle(color: Color(0xff90c4f9)),
      // Time: 15:56:20 or 15:56:47.240788
      RegExp(r'\b\d{2}:\d{2}:\d{2}(?:\.\d+)?\b'):
          TextStyle(color: Color(0xff90c4f9)),
      // Address: domain:port or IP:port
      RegExp(r'\b([\w\.-]+):\d+\b'): TextStyle(color: Color(0xfffb9d51)),
      RegExp(r'\b(tcp:|udp:)\b', caseSensitive: false):
          TextStyle(
        color: Color(0xfffb9d51),
      ),
      // Log level: ERROR, Warning, debug, info, etc.
      RegExp(r'\b(error|warning|info|debug)\b', caseSensitive: false):
          TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      // Square brackets quoted contents
      RegExp(r'\[.*?\]'): TextStyle(color: Colors.grey),
      // Arrow symbol ->
      RegExp(r'->'): TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      // High frequency keywords
      RegExp(r'\b(from|accepted|failed)\b', caseSensitive: false):
          TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    };

    final matches = <_Match>[];

    patterns.forEach((regex, style) {
      for (final match in regex.allMatches(text)) {
        matches.add(_Match(match.start, match.end, style));
      }
    });

    // Sort by start, then by longest first
    matches.sort((a, b) {
      if (a.start != b.start) return a.start.compareTo(b.start);
      return b.length.compareTo(a.length); // longer match first
    });

    // Keep only non-overlapping matches
    final nonOverlapping = <_Match>[];
    int lastEnd = 0;
    for (final m in matches) {
      if (m.start >= lastEnd) {
        nonOverlapping.add(m);
        lastEnd = m.end;
      }
    }

    // Build TextSpans
    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final m in nonOverlapping) {
      if (m.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, m.start),
          // style: TextStyle(color: Colors.black),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(m.start, m.end),
        style: m.style,
      ));
      currentIndex = m.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        // style: TextStyle(color: Colors.black),
      ));
    }

    return spans;
  }
}

class _Match {
  final int start;
  final int end;
  final TextStyle style;

  _Match(this.start, this.end, this.style);

  int get length => end - start;
}