import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  _loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
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
        title: const Text("fv2ray"),
        subtitle: Text("v$version+$buildNumber"),
      ),
      ListTile(
        title: const Text("Github"),
        subtitle: const Text("https://github.com/fv2ray/fv2ray"),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          try {
            launchUrl(Uri.parse("https://github.com/fv2ray/fv2ray"));
          } catch (_) {}
        },
      ),
    ];
    return Scaffold(
        appBar: AppBar(
          // Use the selected tab's label for the AppBar title
          title: const Text("About"),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        body: ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) => fields[index],
        ));
  }
}
