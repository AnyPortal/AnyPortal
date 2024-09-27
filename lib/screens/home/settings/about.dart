import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({
    super.key,
  });

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Use the selected tab's label for the AppBar title
          title: const Text("About"),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        body: Center(
            child: Column(
          children: [
            SizedBox(
              width: 256,
              height: 256,
              child: Image.asset('assets/icon/icon.png'),
            ),
            const Text("fv2ray v0.0.0 alpha")
          ],
        )));
  }
}
