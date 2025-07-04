import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../utils/method_channel.dart';
import '../../utils/runtime_platform.dart';
import '../../widgets/log_highlighter.dart';

class LogViewer extends StatefulWidget {
  final String filePath;
  final int maxLines;

  const LogViewer({super.key, required this.filePath, this.maxLines = 1000});

  @override
  LogViewerState createState() => LogViewerState();
}

class LogViewerState extends State<LogViewer> {
  static List<String> _logLines = [];
  final ScrollController _scrollController = ScrollController();
  late File _logFile;
  int _lastFileSize = 0;

  @override
  void initState() {
    super.initState();
    _logFile = File(widget.filePath);
    _loadInitialLog();
    _startFileMonitor();
  }

  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    mCMan.removeHandler('onFileChange', handleFileChange);
  }

  void _loadInitialLog() {
    // Load the last N lines from the file
    _readLastNLines(widget.maxLines).then((lines) {
      if (mounted) {
        setState(() {
          _logLines = lines;
        });
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _scrollToBottom();
        // });
      }
    });
  }

  Future<List<String>> _readLastNLines(int n) async {
    if (RuntimePlatform.isWeb) {
      return [];
    }

    List<String> lines = [];
    if (!await _logFile.exists()) {
      return [];
    }
    int length = await _logFile.length();
    _lastFileSize = length;

    RandomAccessFile file = await _logFile.open();
    // cull last '\n'
    int endPosition = length - 1;

    // Read file backward until N lines are reached
    while (lines.length < n && endPosition > 0) {
      int startPosition = (endPosition > 1024) ? endPosition - 1024 : 0;
      file.setPositionSync(startPosition);
      String chunk = utf8.decode(await file.read(endPosition - startPosition));
      final newLines = chunk.split('\n');
      // concatenate boundries
      if (lines.isNotEmpty) {
        lines[0] = newLines[newLines.length - 1] + lines[0];
      }
      if (newLines.length > 1) {
        lines = newLines.sublist(0, newLines.length - 1) + lines;
      }

      endPosition = startPosition;
    }

    file.closeSync();

    return lines.sublist(max(0, lines.length - widget.maxLines));
  }

  Future<void> onFileChange() async {
    if (RuntimePlatform.isWeb) {
      return;
    }

    if (!_logFile.existsSync()) {
      return;
    }
    int newSize = await _logFile.length();
    if (newSize > _lastFileSize) {
      final rederedSize = _lastFileSize;
      _lastFileSize = newSize;

      RandomAccessFile file = await _logFile.open();
      file.setPositionSync(rederedSize);
      String appendedText = utf8.decode(await file.read(newSize - rederedSize));
      file.closeSync();

      List<String> newLines = appendedText.split('\n');
      if (newLines[newLines.length - 1] == "") {
        newLines = newLines.sublist(0, newLines.length - 1);
      }
      if (mounted) {
        setState(() {
          _logLines.addAll(newLines);
          if (_logLines.length > widget.maxLines) {
            _logLines = _logLines.sublist(_logLines.length - widget.maxLines);
          }
        });

        if (_scrollController.position.atEdge &&
            _scrollController.position.pixels == 0) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    }
  }

  void handleFileChange(MethodCall _){
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

  void _scrollToBottom() {
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   duration: const Duration(milliseconds: 200),
    //   curve: Curves.easeOut,
    // );
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.jumpTo(
      _scrollController.position.minScrollExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: Align(
            child: SelectionArea(
          child: ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemCount: _logLines.length,
            itemBuilder: (context, index) {
              return LogHighlighter(logLine:_logLines[_logLines.length - 1 - index]);
            },
            physics: const ClampingScrollPhysics(),
            cacheExtent: 99999,
          ),
        )));
  }
}
