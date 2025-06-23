import 'dart:async';

import 'package:flutter/services.dart';

import 'logger.dart';

// import 'logger.dart';

class MethodChannelManager {
  late MethodChannel methodChannel;
  Map<String, Set<Function(MethodCall)>> handlers = {};

  Future<void> init() async {
    logger.d("starting: MethodChannelManager.init");
    methodChannel = const MethodChannel('com.github.anyportal.anyportal');
    methodChannel.setMethodCallHandler(methodCallHandler);
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: MethodChannelManager.init");
  }

  static final MethodChannelManager _instance = MethodChannelManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  MethodChannelManager._internal();

  // Singleton accessor
  factory MethodChannelManager() {
    return _instance;
  }

  void addHandler(String method, Function(MethodCall) callback){
    if (!handlers.containsKey(method)){
      handlers[method] = {};
    }
    handlers[method]!.add(callback);
  }

  void removeHandler(String method, Function(MethodCall) callback){
    if (!handlers.containsKey(method)) return;
    handlers[method]!.remove(callback);
    if (handlers[method]!.isEmpty){
      handlers.remove(method);
    }
  }

  Future<dynamic> methodCallHandler(MethodCall call) async {
    // logger.d("methodCallHandler: ${call.method}");
    if (handlers.containsKey(call.method)){
      for (final callback in handlers[call.method]!){
        callback(call);
      }
    }
    return null;
  }
}

final mCMan = MethodChannelManager();
