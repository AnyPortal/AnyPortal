import 'dart:async';

import 'package:flutter/material.dart';

class CoreDataNotifierBase with ChangeNotifier {
  int index = 0;
  final limitCount = 60;
  bool on = false;

  void init({String? cfgStr}) {}

  Future<void> onStart() async {}

  Future<void> onStop() async {}

  Future<void> start() async {
    if (on) {
      return;
    } else {
      on = true;
    }
    await onStart();
  }

  Future<void> stop() async {
    await onStop();
    on = false;
  }
}
