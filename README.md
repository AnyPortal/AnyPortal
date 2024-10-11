# AnyPortal

<img src="assets/image/README/dashboard_screen.gif" height="400" /> <img src="assets/image/README/profiles_screen.png" height="400" /> <img src="assets/image/README/settings_screen.png" height="400" /> <img src="assets/image/README/profile_override_screen.png" height="400" />

- v2ray, xray, ... GUI for Windows, macOS, Linux, Android, (iOS currently blocked).
- Typically used in combination with a core (v2ray-core, xray-core, etc)

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
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-api28.apk"><img src="https://img.shields.io/badge/APK-api28-044d29.svg?logo=android"></a><br>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-android-apilatest.apk"><img src="https://img.shields.io/badge/APK-apilatest-168039.svg?logo=android"></a><br>
      </td>
    </tr>
    <tr>
      <td>Windows</td>
      <td>
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-windows.zip"><img src="https://img.shields.io/badge/Portable-x64-0078d7.svg?logo=windows"></a><br>
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
        <a href="https://github.com/anyportal/anyportal/releases/latest/download/anyportal-linux.zip"><img src="https://img.shields.io/badge/Portable-x64-f84e29.svg?logo=linux"> </a><br>
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
> iOS development is currently blocked. iOS app using Network Extension requires a paid Apple Developer Program membership ($99/year) to debug even on our own devices, which is not available for the developers right now.
>
> 2024-09-27

## Dev roadmap

|                        | Windows | Linux | macOS | Android | iOS |
| ---------------------- | ------- | ----- | ----- | ------- | --- |
| AnyPortal              | 🟢       | 🟢     | 🟢     | 🟢       | 🟡   |
| core as exec           | 🟢       | 🟢     | 🟢     | 🟢^1     | ⚫   |
| core as lib            | ⚫       | ⚫     | ⚫     | 🟢^2     | 🟡   |
| tun via root privilege | 🟢^3     | 🟢^4   | 🟢^5   | ⚫       | ⚫   |
| tun via system vpn api | ⚫       | ⚫     | 🔴^6   | 🟢       | 🔴^6 |
| system proxy           | 🟢       | 🟢^7   | 🟢     | ⚫       | ⚫   |

- ^1. Require `api28` variant, not available for play store `apilatest` version.
  - The core exec asset is copied to internal storage upon selection, so you MUST reselect the core if you want to update it.
  - The `working directory` can not be set to a location without execution permission, e.g. the sdcard which has a FAT file system.
  - You MUST manually specify the `envs` if the core needs it, e.g. `{"xray.location.asset" : "/storage/emulated/0/path/to/xray/assets"}`
- ^2. Only latest xray-core is embedded for now.
- ^3. Require `Run as Administrator`, elevated user share configuration with original user
- ^4. Require root, root DOES NOT share configuration with original user
- ^5. Require root, root DOES NOT share configuration with original user. Move the app to Application folder and run `sudo /Applications/anyportal.app/Contents/MacOS/anyportal`.
- ^6. Require an apple developer license to even debug an app that uses Network Extension. Dev progress currently blocked. The iOS app would serve little purpose right now without tun.
- ^7. Tested on Ubuntu 24.04 with Gnome

- ⚫ Not Planned: impossible / no plans / discontinued
- 🟡 Planned: planned / under development
- 🔵 Experimental: experimental implementation / testing
- 🟢 Working: functioning as expected
- 🔴 Not Working: dev blocked / known issues / non-functional

See planning [here](https://github.com/users/anyportal/projects/1/views/1).

## Technical details for power users

- why v2ray/xray over sing-box?
  - load balancing
  - chained proxy in transport layer
  - better server-side functions (gRPC interface etc.), so we choose it also as client to reduce maintenance
- remote profile has only one required field, a REST URL pointing to a v2ray config
- for v2ray to work properly on Android and iOS, tun2socks is necessary
  - v2ray native tun inbound is only half finished for now
  - tun2socks with best performance so far: hev-socks5-tunnel, followed by sing-box
  - you can use anyportal with tun disabled on Android, and use external tools to redirect traffic to a socks port, just like on desktop
- android api 29+ does not allow running binary directly
  - you can run custom cores (any version of v2ray, xray) with apk compiled with api target 28
  - playsotore always requires recent api targets, way over 28 now, so you can only use an embedded core with playstore apk

## License

All rights reserved until further notice (hopefully soon).

## Thanks

### 3-rd party libs used in the project

- [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core), MIT
- [xtls/xray-core](https://github.com/xtls/xray-core), MPL-2.0
- [heiher/hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel), MIT
- a full list of flutter dependency can be found in `./pubspec.yaml`

### Inspired by, or related to, but not used in the project

- [Qv2ray/Qv2ray](https://github.com/Qv2ray/Qv2ray), GPL-3.0
- [SagerNet/sing-box](https://github.com/SagerNet/sing-box), GPL

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
