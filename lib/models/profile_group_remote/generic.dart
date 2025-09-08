import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'base.dart';

class ProfileGroupRemoteGeneric extends ProfileGroupRemoteBase {
  ProfileGroupRemoteGeneric(
    super.profiles, {
    super.name,
    super.autoUpdateInterval,
    super.subscriptionUserInfo,
    super.supportUrl,
    super.profileWebPageUrl,
  });
  static final logger = GetIt.I<Logger>();

  factory ProfileGroupRemoteGeneric.fromString(String s) {
    final List<Profile> profiles = [];

    String decoded = "";
    try {
      decoded = utf8.decode(base64.decode(s));
    } catch (_) {
      decoded = s;
    }

    List<String> lines = LineSplitter().convert(decoded);
    final meta = <String, String>{};
    for (final line in lines) {
      if (line.startsWith("#")) {
        try {
          final splitted = line.substring(1).split(": ");
          if (splitted.length >= 2) {
            final key = splitted[0];
            String value = splitted.sublist(1).join();
            if (value.startsWith("base64:")) {
              value = utf8.decode(base64.decode(value.substring(7)));
            }
            meta[key] = value;
          }
        } catch (_) {}
        continue;
      }

      try {
        final profile = ProfileRemoteGeneric.fromString(line);
        if (profile != null) {
          profiles.add(profile);
        } else {
          logger.w("failed to decode profile: $line");
        }
      } catch (e) {
        logger.w(e);
      }
      continue;
    }

    Map<String, dynamic> parseKeyValueString(String? input) {
      if (input == null) return {};
      final Map<String, dynamic> result = {};

      /// Split by semicolon
      final parts = input.split(';');
      for (var part in parts) {
        part = part.trim();
        if (part.isEmpty) continue;

        /// Split each "key=value"
        final kv = part.split('=');
        if (kv.length == 2) {
          final key = kv[0].trim();
          final value = kv[1].trim();

          /// Try parsing as int if possible, otherwise leave as string
          final intValue = int.tryParse(value);
          result[key] = intValue ?? value;
        }
      }

      return result;
    }

    return ProfileGroupRemoteGeneric(
      profiles,
      name: meta["profile-title"],
      autoUpdateInterval: int.tryParse(meta["profile-update-interval"] ?? ""),
      subscriptionUserInfo: SubscriptionUserInfo.fromJson(
        parseKeyValueString(meta["subscription-userinfo"]),
      ),
      supportUrl: meta["support-url"],
      profileWebPageUrl: meta["profile-web-page-url"],
    );
  }
}

class ProfileRemoteGeneric extends Profile {
  ProfileRemoteGeneric(
    super.name,
    super.key,
    super.coreType,
    super.format,
    super.coreConfig,
  );

  static final logger = GetIt.I<Logger>();

  static Profile? fromString(String s) {
    Uri uri;
    try {
      uri = Uri.parse(s);
    } catch (_) {
      logger.w("failed to parse uri: $s");
      return null;
    }

    final proxyProtocolSchemeString = uri.scheme;
    final proxyProtocol = ProxyProtocolX.fromSchemeString(
      proxyProtocolSchemeString,
    );
    if (proxyProtocol == null) return null;

    Map<String, String> queryParameters;
    String host;
    int port;
    String fragment;

    try {
      /// as base64 encoded json string
      String decoded = utf8.decode(
        base64.decode(s.split("://").sublist(1).join()),
      );
      queryParameters = (json.decode(decoded) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
      host = queryParameters["add"]!;
      port = int.parse(queryParameters["port"]!);
      fragment = queryParameters["ps"]!;
    } catch (_) {
      /// as uri
      queryParameters = uri.queryParameters;
      host = uri.host;
      port = uri.port;
      fragment = Uri.decodeComponent(uri.fragment);
    }

    final key = uri.removeFragment().toString();
    final name = fragment.isNotEmpty ? fragment : "$host:$port";

    return Profile(
      name,
      key,
      null,
      "GENERIC_SUBSCRIPTION_URI",
      s,
    );
  }
}

enum ProxyProtocolScheme {
  trojan,
  ss,
  vmess,
  vless,
}

enum ProxyProtocol {
  trojan,
  shadowsocks,
  vmess,
  vless,
}

extension ProxyProtocolX on ProxyProtocol {
  static ProxyProtocol? fromSchemeString(String s) {
    switch (s) {
      case "ss":
        return ProxyProtocol.shadowsocks;
      case _:
        return ProxyProtocol.values.asNameMap()[s];
    }
  }
}
