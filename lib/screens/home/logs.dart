import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart' as p;

import '../../extensions/localization.dart';
// import '../../utils/logger.dart';
import '../../models/block_queue.dart';
import '../../models/counted_circular_buffer.dart';
import '../../models/deque_list.dart';
import '../../utils/global.dart';
import '../../utils/method_channel.dart';
import '../../utils/prefs.dart';
import '../../utils/runtime_platform.dart';
import '../../widgets/log_highlighter.dart';

class LogViewer extends StatefulWidget {
  const LogViewer({super.key});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  late File _logFile;

  final ScrollController _scrollController = ScrollController();

  // Store real measured line heights
  final _measuredHeights = BlockDeque();

  static const double _defaultLineHeight = 24.0; // fallback if not measured yet
  static const int _bufferLines = 20;

  double _viewportHeight = 0;

  final _lines = DequeList<String>();
  int _lastFileSize = 0;

  double progressReadingBackward = 0;

  final _recentLinesHeight = CountedCircularBuffer<double>(16);
  double getEstimatedLineHeight() {
    return _recentLinesHeight.mostFrequent ?? _defaultLineHeight;
  }

  bool isReadingBackward = true;

  Future<void> _readBackward({int chunkSize = 16384}) async {
    isReadingBackward = true;
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
          _measuredHeights.addAllFirst(
              List.filled(newLines.length, getEstimatedLineHeight()));

          progressReadingBackward = 1 - startPosition / length;
        });

        _scrollController.jumpTo(_getBottomTarget());

        // _autoSnap(force: true);
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
      // _autoSnap();
    }
    await file.close();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      isReadingBackward = false;
    });

    return;
  }

  Future<void> onFileChange(String path) async {
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
          _measuredHeights.addAllLast(
              List.filled(newLines.length, getEstimatedLineHeight()));
        });

        _autoSnap();
      }
    }
  }

  void handleFileChange(MethodCall call) {
    final path = call.arguments as String;
    onFileChange(path);
  }

  Timer? _timer;
  StreamSubscription? _streamSubscription;

  void _startFileMonitor() {
    if (RuntimePlatform.isAndroid) {
      mCMan.methodChannel.invokeListMethod(
          'log.core.startWatching', {"filePath": _logFile.absolute.path});
      mCMan.addHandler('onFileChange', handleFileChange);
    } else if (RuntimePlatform.isLinux) {
      _streamSubscription = _logFile.watch().listen((e) {
        onFileChange(_logFile.absolute.path);
      });
    } else {
      // if os does not support file monitoring, e.g. windows and mac do not monitor appending
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        onFileChange(_logFile.absolute.path);
      });
    }
  }

  void _stopFileMonitor() {
    if (RuntimePlatform.isAndroid) {
      mCMan.methodChannel.invokeListMethod(
          'log.core.stopWatching', {"filePath": _logFile.absolute.path});
      mCMan.removeHandler('onFileChange', handleFileChange);
    } else if (RuntimePlatform.isLinux) {
      _streamSubscription?.cancel();
    } else {
      // if os does not support file monitoring, e.g. windows and mac do not monitor appending
      _timer?.cancel();
    }
  }

  double _getBottomTarget() {
    return _measuredHeights.prefixSum(_lines.length - 1) -
        _viewportHeight +
        _defaultLineHeight;
  }

  bool shouldSnap = true;

  void _autoSnap({bool force = false}) {
    double target = _getBottomTarget();

    if (force || shouldSnap) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (force || _scrollController.offset < target) {
            _scrollController.jumpTo(target);
          }
        }
      });
    }
  }

  void handleLogsAction(LogsAction action) {
    switch (action) {
      case LogsAction.viewCoreLog:
        setLogFile("core");
        break;
      case LogsAction.viewAppLog:
        setLogFile("app");
        break;
      case LogsAction.viewTun2SocksLog:
        final name = prefs.getBool("tun.useEmbedded")!
            ? "tun2socks.hev_socks5_tunnel"
            : "tun2socks.sing_box";
        setLogFile(name);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(children: [
          Text(context.loc.logs),
          Align(
              alignment: Alignment.centerRight,
              heightFactor: 0.7,
              child: PopupMenuButton(
                itemBuilder: (context) => LogsAction.values
                    .map((action) => PopupMenuItem(
                          value: action,
                          child: Text(action.localized(context)),
                        ))
                    .toList(),
                onSelected: (value) => handleLogsAction(value),
              ))
        ]),
      ),
      body: Stack(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              _viewportHeight = constraints.maxHeight;

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (isReadingBackward) return true;
                  shouldSnap = scrollNotification.metrics.pixels >=
                      _getBottomTarget() - _defaultLineHeight;
                  setState(() {});
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: _lines.isEmpty
                        ? 0
                        : _measuredHeights.prefixSum(_lines.length - 1) +
                            _viewportHeight -
                            _defaultLineHeight,
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

  int findNearestSmallerIndex(BlockDeque sortedList, num value) {
    int left = 0;
    int right = sortedList.length - 1;
    int result = -1;

    while (left <= right) {
      int mid = left + ((right - left) >> 1);

      if (sortedList.prefixSum(mid) < value) {
        result = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    return result;
  }

  List<Widget> _buildPreciseVisibleItems() {
    final List<Widget> visible = [];
    if (_lines.isEmpty) {
      return visible;
    }
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    int firstIndex = findNearestSmallerIndex(_measuredHeights, scrollOffset)
        .clamp(0, _lines.length - 1);
    int lastIndex = firstIndex;
    // Walk forward to cover viewport + buffer
    double visibleHeight = 0.0;
    while (lastIndex < _lines.length && visibleHeight < _viewportHeight) {
      visibleHeight += _measuredHeights[lastIndex];
      lastIndex++;
    }

    firstIndex = (firstIndex - _bufferLines).clamp(0, _lines.length - 1);
    lastIndex = (lastIndex + _bufferLines).clamp(0, _lines.length - 1);

    double topOffset = _measuredHeights.prefixSum(firstIndex - 1);

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
              _recentLinesHeight.add(height);
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

  Future _setLogFile(String name) async {
    if (!RuntimePlatform.isWeb) {
      _logFile = File(p.join(
        global.applicationSupportDirectory.path,
        'log',
        '$name.log',
      ));
      if (!await _logFile.exists()) {
        await _logFile.create(recursive: true);
      }
      setState(() {
        _logFile = _logFile;
      });
    }
  }

  Future setLogFile(String name) async {
    await _setLogFile(name).then((_) {
      _lines.clear();
      _measuredHeights.clear();
      _readBackward();
    }).then((_) {
      _autoSnap(force: true);
      _stopFileMonitor();
      _startFileMonitor();
    });
  }

  @override
  void initState() {
    super.initState();

    _setLogFile("core").then((_) {
      _readBackward();
    }).then((_) {
      _startFileMonitor();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _stopFileMonitor();
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

enum LogsAction {
  viewCoreLog,
  viewAppLog,
  viewTun2SocksLog,
}

extension LogsActionX on LogsAction {
  String localized(BuildContext context) {
    switch (this) {
      case LogsAction.viewCoreLog:
        return context.loc.view_core_log;
      case LogsAction.viewAppLog:
        return context.loc.view_app_log;
      case LogsAction.viewTun2SocksLog:
        return context.loc.view_tun2socks_log;
    }
  }
}
