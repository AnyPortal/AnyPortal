import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../extensions/localization.dart';
import '../../../utils/asset_remote/app.dart';
import '../../../utils/global.dart';
import '../../../utils/logger.dart';
import '../../../utils/platform_file_mananger.dart';
import '../../../utils/prefs.dart';
import '../../../utils/runtime_platform.dart';
import '../../../utils/show_snack_bar_now.dart';
import '../../../widgets/blockquote.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({
    super.key,
  });

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String version = "";
  String? downloadedTagName;
  int buildNumber = 0;
  int? downloadedBuildNumber;
  int lastChecked = prefs.getInt("app.autoUpdate.checkedAt")!;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    _updateDownloadedVersion();
  }

  Future<void> _loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      buildNumber = int.parse(packageInfo.buildNumber);
      version = "v${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  void _updateDownloadedVersion() {
    String downloadedMeta = prefs.getString("app.github.meta")!;
    Map<String, dynamic> downloadedMetaObj = {};
    try {
      downloadedMetaObj = jsonDecode(downloadedMeta) as Map<String, dynamic>;
    } catch (e) {
      logger.w("jsonDecode(downloadedMeta): $e");
    }

    if (downloadedMetaObj.containsKey("tag_name")) {
      setState(() {
        downloadedTagName = downloadedMetaObj["tag_name"];
        downloadedBuildNumber = int.parse(downloadedTagName!.split("+").last);
      });
    }
  }

  void _updateLastChecked() {
    setState(() {
      lastChecked = prefs.getInt("app.autoUpdate.checkedAt")!;
    });
  }

  void copyTextThenNotify(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (mounted) showSnackBarNow(context, Text(context.loc.copied));
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 96, 0, 64),
        child: SizedBox(
          width: 128,
          height: 128,
          child: Image.asset('assets/icon/icon.png'),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Blockquote(
          """You take the blue pill, the story ends, you wake up in your bed and believe whatever you want to believe. You take the red pill, you stay in Wonderland and I show you how deep the rabbit hole goes."  

— Morpheus, The Matrix (1999)

We hope you choose well between your home world and Wonderlands.""",
        ),
      ),
      ListTile(
        title: const Text("AnyPortal"),
        subtitle: Text(version),
      ),
      ListTile(
        title: Text(
          downloadedBuildNumber != null && downloadedBuildNumber! > buildNumber
              ? context.loc.install_now
              : context.loc.check_update,
        ),
        subtitle: Text(
          downloadedBuildNumber != null && downloadedBuildNumber! > buildNumber
              ? context.loc.pending_install_tag_name(
                  downloadedTagName != null ? downloadedTagName! : "",
                )
              : context.loc.last_checked_datetime(
                  DateTime.fromMillisecondsSinceEpoch(
                    lastChecked * 1000,
                  ).toLocal().toIso8601String(),
                ),
        ),
        onTap: () async {
          try {
            final assetRemoteProtocolApp = AssetRemoteProtocolApp();
            if (await assetRemoteProtocolApp.init()) {
              await assetRemoteProtocolApp.update(
                shouldInstall: true,
              );
            }
          } catch (e) {
            logger.w(e.toString());
          }
          _updateDownloadedVersion();
          _updateLastChecked();
        },
      ),
      ListTile(
        title: const Text("Github"),
        subtitle: const Text("https://github.com/anyportal/anyportal"),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          try {
            launchUrl(Uri.parse("https://github.com/anyportal/anyportal"));
          } catch (_) {}
        },
      ),
      if (!RuntimePlatform.isWeb) const Divider(),
      if (!RuntimePlatform.isWeb)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            context.loc.local_directory,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      if (!RuntimePlatform.isWeb)
        ListTile(
          title: Text(context.loc.app),
          subtitle: Text(
            RuntimePlatform.isAndroid
                ? "com.github.anyportal.anyportal"
                : Platform.resolvedExecutable,
          ),
          trailing: Icon(
            RuntimePlatform.isAndroid ? Icons.copy : Icons.folder_open,
          ),
          onTap: () {
            if (RuntimePlatform.isAndroid) {
              copyTextThenNotify("com.github.anyportal.anyportal");
            } else {
              PlatformFileMananger.highlightFileInFolder(
                Platform.resolvedExecutable,
              );
            }
          },
        ),
      if (!RuntimePlatform.isWeb)
        ListTile(
          title: Text(context.loc.user_data),
          subtitle: Text(
            p.join(global.applicationDocumentsDirectory.path, "AnyPortal"),
          ),
          trailing: Icon(
            RuntimePlatform.isAndroid ? Icons.copy : Icons.folder_open,
          ),
          onTap: () {
            final folderPath = p.join(
              global.applicationDocumentsDirectory.path,
              "AnyPortal",
            );
            if (RuntimePlatform.isAndroid) {
              copyTextThenNotify(folderPath);
            } else {
              PlatformFileMananger.openFolder(folderPath);
            }
          },
        ),
      if (!RuntimePlatform.isWeb)
        ListTile(
          title: Text(context.loc.generated_assets),
          subtitle: Text(global.applicationSupportDirectory.path),
          trailing: Icon(
            RuntimePlatform.isAndroid ? Icons.copy : Icons.folder_open,
          ),
          onTap: () {
            final folderPath = global.applicationSupportDirectory.path;
            if (RuntimePlatform.isAndroid) {
              copyTextThenNotify(folderPath);
            } else {
              PlatformFileMananger.openFolder(folderPath);
            }
          },
        ),
    ];
    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(context.loc.about),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) => fields[index],
      ),
    );
  }
}
