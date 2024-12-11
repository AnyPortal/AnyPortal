
import 'dart:async';

import 'package:flutter/services.dart';

import 'logger.dart';

// import 'logger.dart';

class MethodChannelManager {
  late MethodChannel methodChannel;
  Map<String, Function(MethodCall)> handlers = {};

  Future<void> init() async {
    methodChannel = const MethodChannel('com.github.anyportal.anyportal');
    methodChannel.setMethodCallHandler(methodCallHandler);
    _completer.complete(); // Signal that initialization is complete
    logger.d("reached target: MethodChannelManager.init");
  }

  static final MethodChannelManager _instance = MethodChannelManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  MethodChannelManager._internal();

  // Singleton accessor
  factory MethodChannelManager() {
    return _instance;
  }

  void addHandler(String method, Function(MethodCall) callback, {force = false}){
    if (!force && handlers.containsKey(method)){
      throw Exception("method already exists");
    }
    handlers[method] = callback;
  }

  void removeHandler(String method){
    handlers.remove(method);
  }

  Future<dynamic> methodCallHandler(MethodCall call) async {
    // logger.d("methodCallHandler: ${call.method}");
    if (handlers.containsKey(call.method)){
      handlers[call.method]!(call);
    } else {
      throw Exception("${call.method} does not exist");
    }
    return null;
  }
}

final mCMan = MethodChannelManager();
