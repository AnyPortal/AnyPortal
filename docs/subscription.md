# Subscription

A subscription is a remote profile group.

## Protocol

- AnyPortalREST
- file
- generic

### AnyPortalREST

It's a REST url expecting the following content.

```json
{
  "version": 1.1,
  "profiles": [
    {
      "name": "",
      "key": "",
      "coreType": "",
      "coreConfig": "",
      "format": "json",
    }
  ]
}
```

- `name`: name of the profile
- `key`: key of the profile. If not provided, `name` will be used as key. During updating, profiles of new keys are added, missing keys deleted, existing keys updated.
- `coreType`: "v2ray" | "xray" | "sing-box" | ...
- `coreConfig`: complete config of the profile, see examples below
- `format`: "json" | "yaml" | ...

| AnyPortalREST | AnyPortal   |
| ------------- | ----------- |
| v1            | v0.2.0+11   |
| v1.1          | v0.6.27+101 |

#### Example minimal coreConfig

AnyPortal uses complete config of corrsponding cores with injections. Some fields (like socks inbound) may be injected on the fly thus can be omitted.

##### v2ray/xray

- the minimal config should contain an outbound

```json
{
  "outbounds": [
    {
      "protocol": "trojan",
      ...
    },
  ]
}
```

### file

a folder, like `file:///path/to/folder`

### generic

a https url, with text content like

```plain
vmess://99c80931-f3f1-4f84-bffd-6eed6030f53d@qv2ray.net:31415?encryption=none#VMessTCPNaked
vless://eyJ2IjoiMiIsInBzIjoiIiwiYWRkIjoiZXhhbXBsZS5vcmciLCJwb3J0IjoiNDQzIiwidHlwZSI6Im5vbmUiLCJpZCI6Ijc2YmRhZjJmLTdkZWMtNGJlOS1iYzZjLWM2ZThlMmE5ZWJiNSIsImFpZCI6IjAiLCJuZXQiOiJ3cyIsInBhdGgiOiIvIiwiaG9zdCI6ImV4YW1wbGUub3JnIiwidGxzIjoiIn0=
```

Only following proxy protocols are supported for now.

- trojan
- ss
- vmess
- vless

Only following cores are supported for now.

- v2ray/xray
- sing-box

Due to lack of specification, it is NOT guaranteed to decode all parameters.

PR welcomed.
