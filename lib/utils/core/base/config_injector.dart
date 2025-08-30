class ConfigInjectorBase {
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    return cfgStr;
  }

  /// config for ping
  /// should not listen on any port other than the given socks port
  Future<String> getInjectedConfigPing(
    String cfgStr,
    String coreCfgFmt,
    int socksPort,
  ) async {
    return cfgStr;
  }
}
