import 'package:flutter/widgets.dart';

import '../generated/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
