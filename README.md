# AnyPortal

<img src="docs/image/windows.gif" width="624"/> <img src="docs/image/android.gif" height="351"/>

- v2ray, xray, sing-box, clash, mihomo... GUI for Windows, macOS, Linux, Android, (iOS currently blocked).
- Typically used in combination with a core (v2ray-core, xray-core, sing-box, etc)
- Multilingual support: العربية, Deutsch, English, Español, فارسی, Français, हिन्दी, Bahasa Indonesia, 日本語, 한국어, Português, Русский, ไทย, Türkçe, Tiếng Việt, 中文

## Download latest release

<div align=left>
<table>
  <thead align=left>
    <tr>
      <th>OS</th>
      <th>Download</th>
    </tr>
  </thead>
  <tbody align=left>
    <td>Android</td>
      <td>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-api28-armeabi-v7a.apk"><img src="https://img.shields.io/badge/APK-api28_armeabi_v7a-044d29.svg?logo=android&logoColor=ffffff"></a><br>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-api28-arm64-v8a.apk"><img src="https://img.shields.io/badge/APK-api28_arm64_v8a-044d29.svg?logo=android&logoColor=ffffff"></a><br>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-api28-x86_64.apk"><img src="https://img.shields.io/badge/APK-api28_x86_64-044d29.svg?logo=android&logoColor=ffffff"></a><br>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-apilatest-armeabi-v7a.apk"><img src="https://img.shields.io/badge/APK-apilatest_armeabi_v7a-168039.svg?logo=android&logoColor=ffffff"></a><br>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-apilatest-arm64-v8a.apk"><img src="https://img.shields.io/badge/APK-apilatest_arm64_v8a-168039.svg?logo=android&logoColor=ffffff"></a><br>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-apilatest-x86_64.apk"><img src="https://img.shields.io/badge/APK-apilatest_x86_64-168039.svg?logo=android&logoColor=ffffff"></a><br>
      </td>
    </tr>
    <tr>
      <td>Windows</td>
      <td>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-windows-setup.exe"><img src="https://img.shields.io/badge/Installer-x64-0078d7.svg?logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0ODc1IDQ4NzUiPjxwYXRoIGZpbGw9IiNGRkZGRkYiIGQ9Ik0wIDBoMjMxMXYyMzEwSDB6bTI1NjQgMGgyMzExdjIzMTBIMjU2NHpNMCAyNTY0aDIzMTF2MjMxMUgwem0yNTY0IDBoMjMxMXYyMzExSDI1NjQiLz48L3N2Zz4="></a><br>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-windows.zip"><img src="https://img.shields.io/badge/Portable-x64-0078d7.svg?logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0ODc1IDQ4NzUiPjxwYXRoIGZpbGw9IiNGRkZGRkYiIGQ9Ik0wIDBoMjMxMXYyMzEwSDB6bTI1NjQgMGgyMzExdjIzMTBIMjU2NHpNMCAyNTY0aDIzMTF2MjMxMUgwem0yNTY0IDBoMjMxMXYyMzExSDI1NjQiLz48L3N2Zz4="></a><br>
      </td>
    </tr>
    <tr>
      <td>macOS</td>
      <td>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-macos.dmg"><img src="https://img.shields.io/badge/DMG-Universal-ea005e.svg?logo=apple"></a><br>
      </td>
    </tr>
    <tr>
      <td>Linux</td>
      <td>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-linux.zip"><img src="https://img.shields.io/badge/Portable-x64-f84e29.svg?logo=linux&logoColor=ffffff"> </a><br>
      </td>
    </tr>
    <tr>
      <td>iOS</td>
      <td>
        currently blocked<br>
      </td>
    </tr>
  </tbody>
</table>
</div>

> [!WARNING]
> This project is currently in its early alpha stage and may exhibit instability during execution. User preferences may not be retained in the final release, and the API is subject to change without prior notice. Please use this software at your own risk. 
> 
> 2024-09-27

> [!IMPORTANT]
> iOS support for this project is paused indefinitely due to the financial and policy-related constraints associated with iOS development, including mandatory paid membership for access to essential tools such as Network Extensions. We are actively exploring alternative, financially sustainable models to continue supporting iOS in the future.
>
> 2025-02-27

## Dev roadmap

|              |                  | Windows | Linux | macOS | Android | iOS |
| ------------ | ---------------- | ------- | ----- | ----- | ------- | --- |
| AnyPortal    |                  | 🟢       | 🟢     | 🟢     | 🟢       | 🟡   |
| core         | of exec          | 🟢       | 🟢     | 🟢     | 🟢¹      | ⚫   |
|              | of lib           | ⚫       | ⚫     | ⚫     | 🟢²      | 🟡   |
| tun          | via root         | 🟢³      | 🟢⁴    | 🟢⁵    | 🟢¹      | ⚫   |
|              | via platform api | ⚫       | ⚫     | 🔴⁶    | 🟢       | 🔴⁶  |
| system proxy |                  | 🟢       | 🟢⁷    | 🟢     | 🟢⁸      | ⚫   |
<!-- ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ⸴ -->
1. Require `api28` variant, not available for play store `apilatest` version.
   - The core exec asset is copied to internal storage upon selection, so you MUST reselect the core if you want to update it.
   - The `working directory` can not be set to a location without execution permission, e.g. the sdcard which has a FAT file system.
   - You MUST manually specify the `envs` if the core needs it, e.g. `{"xray.location.asset" : "/storage/emulated/0/path/to/xray/assets"}`
2. Using xray-core v1.250608.0.
3. Require `Run as Administrator`, elevated user share configuration with original user
4. Require root, root DOES NOT share configuration with original user
5. Require root, root DOES NOT share configuration with original user. Move the app to Application folder and run `sudo /Applications/AnyPortal.app/Contents/MacOS/AnyPortal`.
6. Require an apple developer license to even debug an app that uses Network Extension. Dev progress currently blocked. The iOS app would serve little purpose right now without tun.
7. Tested on Ubuntu 24.04 with Gnome
8. Require root

- ⚫ Not Planned: impossible / no plans / discontinued
- 🟡 Planned: planned / under development
- 🔵 Experimental: experimental implementation / testing
- 🟢 Working: functioning as expected
- 🔴 Not Working: dev blocked / known issues / non-functional

See planning [here](https://github.com/users/anyportal/projects/1/views/1).

## Supported cores

|              | config injection | dashboard info |
| ------------ | ---------------- | -------------- |
| v2ray/xray   | 🟢                | 🟢              |
| sing-box     | 🟢                | 🟢²             |
| clash/mihomo | 🟢                | 🟢              |
| hysteria2    | 🔵                | ⚫              |
| ...¹         | ...              |                |

1. In theory one can run any cores, however it won't be a good experience without config injection and dashboard info. PR welcomed for additional core support. See `lib/utils/core` for example.
2. Using clash api, since v2ray-api is not enabled in official release.

## Technical details for power users

- ~~why v2ray/xray over sing-box?~~ Why choose one when you can have any?
  - seriously, why v2ray/xray over sing-box?
    - load balancing
    - chained proxy in transport layer
    - better server-side functions (gRPC interface etc.), so we choose it also as client to reduce maintenance
  - why sing-box over v2ray/xray?
    - integrated tun makes things easier
- remote profile has only one required field, a REST URL pointing to a v2ray config
- for v2ray to work properly on Android and iOS, Tun2socks is necessary
  - v2ray native tun inbound is only half finished for now
  - Tun2socks with best performance so far: hev-socks5-tunnel, followed by sing-box
  - you can use anyportal with tun disabled on Android, and use external tools to redirect traffic to a socks port, just like on desktop
- android api 29+ does not allow running binary directly
  - you can run custom cores (any version of v2ray, xray) with apk compiled with api target 28
  - play store always requires recent api targets, way over 28 now, so you can only use an embedded core with playstore apk
- why do I need tun via root or system proxy on Android?
  - tun sing-box is actually faster than hev-socks5-tunnel on web page opening
  - there are apps actively detecting if you are using VPN

## License

All rights reserved until further notice (hopefully soon).

## Thanks

### 3rd party libs used in the project

- [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core), MIT
- [xtls/xray-core](https://github.com/xtls/xray-core), MPL-2.0
- [heiher/hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel), MIT

### Inspired by, or related to, but not used in the project

- [Qv2ray/Qv2ray](https://github.com/Qv2ray/Qv2ray), GPL-3.0
- [SagerNet/sing-box](https://github.com/SagerNet/sing-box), GPL

### Toolchains

- [flutter/flutter](https://github.com/flutter/flutter), BSD-3-Clause
  - a full list of flutter dependency can be found in `./pubspec.yaml`
- [jrsoftware/issrc](https://github.com/jrsoftware/issrc)

## Support development

coming soon

## Final words

<p align="center">
  <img width=256 src="assets/icon/icon_rounded_square.png" />
</p>

> "You take the blue pill, the story ends, you wake up in your bed and believe whatever you want to believe. You take the red pill, you stay in Wonderland and I show you how deep the rabbit hole goes."  
>
> — Morpheus, *The Matrix* (1999)

We hope you choose well between your home world and Wonderlands.
