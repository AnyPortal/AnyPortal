import 'package:flutter/material.dart';

import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import '../../../extensions/localization.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../utils/locale_manager.dart';
import '../../../utils/prefs.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({
    super.key,
  });

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  List<Locale> supportedLocales = [];
  Locale? selectedLocale;

  @override
  void initState() {
    super.initState();
    supportedLocales = AppLocalizations.supportedLocales.toList();
    supportedLocales.remove(Locale('zh'));
    setState(() {
      selectedLocale = LocaleManager().fromString(
        prefs.getString('app.locale')!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(context.loc.language),
      ),
      body: ListView.builder(
        itemCount: supportedLocales.length,
        itemBuilder: (context, index) {
          final locale = supportedLocales[index];
          return ListTile(
            title: Text(
              LocaleNamesLocalizationsDelegate.nativeLocaleNames[locale
                      .toString()] ??
                  locale.toString(),
            ),
            subtitle: Text(
              LocaleNames.of(context)!.nameOf(locale.toString()) ?? "",
            ),
            trailing: locale == selectedLocale ? Icon(Icons.check) : null,
            onTap: () {
              prefs.setString('app.locale', locale.toString());
              localeManager.update(notify: true);
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
