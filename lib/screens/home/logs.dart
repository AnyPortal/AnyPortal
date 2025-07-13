import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../extensions/localization.dart';
import '../../models/deque_list.dart';
// import '../../utils/logger.dart';
import '../../utils/method_channel.dart';
import '../../utils/runtime_platform.dart';
import '../../widgets/log_highlighter.dart';

class LogViewer extends StatefulWidget {
  final String filePath;
  const LogViewer({super.key, required this.filePath});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  final ScrollController _scrollController = ScrollController();

  // Store real measured line heights
  final _measuredHeights = DequeList<double>();

  static const double _defaultLineHeight = 24.0; // fallback if not measured yet
  static const int _bufferLines = 20;

  double _viewportHeight = 0;

  final _lines = DequeList<String>();
  late File _logFile;
  int _lastFileSize = 0;

  double progressReadingBackward = 0;

  Future<void> _readBackward({int chunkSize = 16384}) async {
    if (RuntimePlatform.isWeb) {
      return;
    }

    if (!await _logFile.exists()) {
      return;
    }
    int length = await _logFile.length();
    _lastFileSize = length;

    RandomAccessFile file = await _logFile.open();
    // cull last '\n'
    int endPosition = length - 1;

    // Read file backward until N lines are reached
    while (endPosition > 0) {
      int startPosition =
          (endPosition > chunkSize) ? endPosition - chunkSize : 0;
      await file.setPosition(startPosition);
      String chunk = utf8.decode(await file.read(endPosition - startPosition));
      final newLines = chunk.split('\n');
      if (mounted) {
        setState(() {
          if (_lines.isNotEmpty) {
            /// concatenate boundries
            if (newLines.isNotEmpty) {
              _lines[0] = newLines[newLines.length - 1] + _lines[0];
              newLines.removeLast();
            }
          }

          _lines.addAllFirst(newLines);
          _measuredHeights
              .addAllFirst(List.filled(newLines.length, _defaultLineHeight));

          progressReadingBackward = 1 - startPosition / length;
        });
        _autoSnap();
      }

      endPosition = startPosition;
      // await Future.delayed(const Duration(milliseconds: 1));
    }
    if (mounted) {
      // setState(() {
      //   _lines.addAllLast(lines);
      //   _measuredHeights
      //       .addAllLast(List.filled(lines.length, _defaultLineHeight));
      // });
      _autoSnap();
    }
    await file.close();

    return;
  }

  Timer? _timer;

  Future<void> onFileChange() async {
    if (RuntimePlatform.isWeb) {
      return;
    }

    if (!await _logFile.exists()) {
      return;
    }
    int newSize = await _logFile.length();
    if (newSize > _lastFileSize) {
      final rederedSize = _lastFileSize;
      _lastFileSize = newSize;

      RandomAccessFile file = await _logFile.open();
      await file.setPosition(rederedSize);
      String appendedText = utf8.decode(await file.read(newSize - rederedSize));
      await file.close();

      List<String> newLines = appendedText.split('\n');
      if (newLines[newLines.length - 1] == "") {
        newLines = newLines.sublist(0, newLines.length - 1);
      }
      if (mounted) {
        setState(() {
          _lines.addAllLast(newLines);
          _measuredHeights
              .addAllLast(List.filled(newLines.length, _defaultLineHeight));
        });

        _autoSnap();
      }
    }
  }

  void handleFileChange(MethodCall _) {
    onFileChange();
  }

  void _startFileMonitor() async {
    if (RuntimePlatform.isAndroid) {
      mCMan.methodChannel.invokeListMethod(
          'log.core.startWatching', {"filePath": widget.filePath});
      mCMan.addHandler('onFileChange', handleFileChange);
    } else if (RuntimePlatform.isLinux) {
      _logFile.watch().listen((e) {
        onFileChange();
      });
    } else {
      // if os does not support file monitoring, e.g. windows and mac do not monitor appending
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        onFileChange();
      });
    }
  }

  double _getBottomTarget() {
    /// fill the view with just enough lines
    double accumulated = 0;
    var i = _lines.length - 1;
    while (accumulated < _viewportHeight && i >= 0) {
      accumulated += _measuredHeights[i];
      --i;
    }

    double target = (i + 2) * _defaultLineHeight;
    return target;
  }

  bool shouldSnap = true;

  void _autoSnap() {
    double target = _getBottomTarget();

    if (shouldSnap) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (_scrollController.offset < target) {
            _scrollController.jumpTo(target);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.loc.logs)),
      body: Stack(children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              _viewportHeight = constraints.maxHeight;

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  setState(() {
                    shouldSnap = scrollNotification.metrics.pixels >=
                        _getBottomTarget() - _defaultLineHeight;
                  });
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: _lines.isEmpty
                        ? 0
                        : _lines.length * _defaultLineHeight + _viewportHeight,
                    child: Stack(
                      children: _buildPreciseVisibleItems(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 4,
          child: progressReadingBackward != 1
              ? LinearProgressIndicator(value: progressReadingBackward)
              : null,
        ),
      ]),
    );
  }

  List<Widget> _buildPreciseVisibleItems() {
    final List<Widget> visible = [];
    if (_lines.isEmpty) {
      return visible;
    }
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    int firstIndex = ((scrollOffset) / _defaultLineHeight)
        .floor()
        .clamp(0, _lines.length - 1);
    int lastIndex = firstIndex;
    // Walk forward to cover viewport + buffer
    double visibleHeight = 0.0;
    while (lastIndex < _lines.length && visibleHeight < _viewportHeight) {
      visibleHeight += _measuredHeights[lastIndex];
      lastIndex++;
    }

    // firstIndex = (firstIndex - _bufferLines).clamp(0, _lines.length - 1);
    lastIndex = (lastIndex + _bufferLines).clamp(0, _lines.length - 1);

    // double topOffset = _heightUpTo(firstIndex);
    double topOffset = firstIndex * _defaultLineHeight;

    for (int i = firstIndex; i <= lastIndex; i++) {
      visible.add(
        Positioned(
          top: topOffset,
          left: 0,
          right: 0,
          child: _MeasuredLine(
            index: i,
            text: _lines[i],
            onHeight: (height) {
              if (_measuredHeights[i] != height) {
                setState(() {
                  _measuredHeights[i] = height;
                  // logger.d("onHeight");
                });
                _autoSnap();
              }
            },
          ),
        ),
      );

      topOffset += _measuredHeights[i];
    }

    return visible;
  }

  @override
  void initState() {
    super.initState();
    _logFile = File(widget.filePath);
    _readBackward().then((_) {
      _startFileMonitor();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    mCMan.removeHandler('onFileChange', handleFileChange);
  }
}

class _MeasuredLine extends StatefulWidget {
  final int index;
  final String text;
  final ValueChanged<double> onHeight;

  const _MeasuredLine({
    required this.index,
    required this.text,
    required this.onHeight,
  });

  @override
  State<_MeasuredLine> createState() => _MeasuredLineState();
}

class _MeasuredLineState extends State<_MeasuredLine> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  @override
  void didUpdateWidget(covariant _MeasuredLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  void _reportSize() {
    final context = _key.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final height = box.size.height;
      widget.onHeight(height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        key: _key,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: LogHighlighter(logLine: widget.text));
  }
}
