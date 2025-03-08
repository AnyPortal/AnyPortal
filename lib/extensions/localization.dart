import 'package:flutter/widgets.dart';

import 'package:anyportal/generated/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
