import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'logger.dart';
import 'prefs.dart';

class LocaleManager with ChangeNotifier {
  static final LocaleManager _instance = LocaleManager._internal();
  final Completer<void> _completer = Completer<void>();
  late Locale locale;

  // Private constructor
  LocaleManager._internal();

  // Singleton accessor
  factory LocaleManager() {
    return _instance;
  }

  Future<void> init() async {
    logger.d("starting: LocaleManager.init");
    update();
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: LocaleManager.init");
  }

  void update({notify = false}) {
    if (prefs.getBool('app.locale.followSystem')!) {
      var dispatcher = SchedulerBinding.instance.platformDispatcher;
      locale = dispatcher.locale;
    } else {
      final localeString = prefs.getString('app.locale')!;
      final localeParts = localeString.split("_");
      if (localeParts.length == 1) {
        locale = Locale(localeParts[0]); // e.g., "zh"
      } else if (localeParts.length == 2) {
        locale =  Locale(localeParts[0], localeParts[1]); // e.g., "zh_CN"
      } else if (localeParts.length == 3) {
        locale = Locale.fromSubtags(languageCode: localeParts[0], scriptCode: localeParts[1], countryCode: localeParts[2]); // e.g., "zh_Hans_CN"
      } else {
        logger.w("failed to parse locale $localeString");
        return;
      }
    }

    if (notify) {
      notifyListeners();
    }
  }
}

final localeManager = LocaleManager();
