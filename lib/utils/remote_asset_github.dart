import 'dart:core';

class ParsedUrl {
  final String protocol;
  final String owner;
  final String repo;
  final String assetName;
  final String? assetExtension;
  final String? subPath;

  ParsedUrl({
    required this.protocol,
    required this.owner,
    required this.repo,
    required this.assetName,
    this.assetExtension,
    this.subPath,
  });

  @override
  String toString() {
    return 'Protocol: $protocol\n'
        'Owner: $owner\n'
        'Repo: $repo\n'
        'AssetName: $assetName\n'
        'AssetExtension: ${assetExtension ?? "None"}\n'
        'SubPath: ${subPath ?? "None"}';
  }
}

ParsedUrl? parseUrl(String url) {
  final regex = RegExp(
    r'^(\w+):\/\/([^\/]+)\/([^\/]+)\/([^\/\?\.\n]+)(?:\.(\w+))?(?:\/(.+))?$',
  );

  final match = regex.firstMatch(url);
  if (match != null) {
    return ParsedUrl(
      protocol: match.group(1)!,
      owner: match.group(2)!,
      repo: match.group(3)!,
      assetName: match.group(4)!,
      assetExtension: match.group(5), // Nullable
      subPath: match.group(6), // Nullable
    );
  }
  return null;
}

void main() {
  final url1 = "github://owner/repo/asset";
  final url2 = "github://owner/repo/asset.apk";
  final url3 = "github://owner/repo/asset.zip/with/sub/path";

  final parsed1 = parseUrl(url1);
  final parsed2 = parseUrl(url2);
  final parsed3 = parseUrl(url3);

  print(parsed1);
  print(parsed2);
  print(parsed3);
}