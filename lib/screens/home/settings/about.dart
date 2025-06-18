import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/utils/global.dart';
import '../../../utils/platform_file_mananger.dart';
import '../../../utils/runtime_platform.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = "v${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  Future<void> copyTextThenNotify(String text) async {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      final snackBar = SnackBar(
        content: Text("Copied"),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          )),
      const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Blockquote(
              """You take the blue pill, the story ends, you wake up in your bed and believe whatever you want to believe. You take the red pill, you stay in Wonderland and I show you how deep the rabbit hole goes."  

— Morpheus, The Matrix (1999)

We hope you choose well between your home world and Wonderlands.""")),
      ListTile(
        title: const Text("AnyPortal"),
        subtitle: Text(version),
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
      if (!RuntimePlatform.isWeb) Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Local directory",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      if (!RuntimePlatform.isWeb) ListTile(
        title: Text(context.loc.app),
        subtitle: Text(File(Platform.resolvedExecutable).parent.path),
        trailing: const Icon(Icons.folder_open),
        onTap: () {
          PlatformFileMananger.highlightFileInFolder(
              Platform.resolvedExecutable);
          copyTextThenNotify(Platform.resolvedExecutable);
        },
      ),
      if (!RuntimePlatform.isWeb) ListTile(
        title: Text(context.loc.user_data),
        subtitle: Text(
            p.join(global.applicationDocumentsDirectory.path, "AnyPortal")),
        trailing: const Icon(Icons.folder_open),
        onTap: () {
          PlatformFileMananger.openFolder(
              p.join(global.applicationDocumentsDirectory.path, "AnyPortal"));
          copyTextThenNotify(
              p.join(global.applicationDocumentsDirectory.path, "AnyPortal"));
        },
      ),
      if (!RuntimePlatform.isWeb) ListTile(
        title: Text(context.loc.generated_assets),
        subtitle: Text(global.applicationSupportDirectory.path),
        trailing: const Icon(Icons.folder_open),
        onTap: () {
          PlatformFileMananger.openFolder(
              global.applicationSupportDirectory.path);
          copyTextThenNotify(global.applicationSupportDirectory.path);
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
        ));
  }
}
