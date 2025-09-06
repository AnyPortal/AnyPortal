# Subscription

A subscription is a remote profile group.

## Protocol

- AnyPortalREST
- file
- generic

### AnyPortalREST

It's a REST url expecting the following content.

#### root

```json
{
  "version": 1.2,
  "profiles": [],
  "name": "",
  "autoUpdateInterval": 86400,
  "subscriptionUserInfo": {
    "expire": 0,
    "total": 0,
    "upload": 0,
    "download": 0,
  },
  "supportUrl": "",
  "profileWebPageUrl": "",
}
```

- `profiles`: list of [Profile](#profile)
- [optional] `name`: name of the profile group
- [optional] `autoUpdateInterval`: time in seconds
- [optional] `subscriptionUserInfo`
  - [optional] `expire`: unix timestamp
  - [optional] `total`: total allowance
  - [optional] `upload`: upload usage
  - [optional] `download`: download usage
- [optional] `supportUrl`: support url
- [optional] `profileWebPageUrl`: profile web page url

| AnyPortalREST | AnyPortal   |
| ------------- | ----------- |
| v1            | v0.2.0+11   |
| v1.1          | v0.6.27+101 |
| v1.2          | v0.6.28+102 |

#### Profile

```json
{
  "name": "",
  "key": "",
  "coreType": "",
  "coreConfig": "",
  "format": "json",
}
```

- `name`: name of the profile
- `key`: key of the profile. If not provided, `name` will be used as key. During updating, profiles of new keys are added, missing keys deleted, existing keys updated.
- `coreType`: "v2ray" | "xray" | "sing-box" | ...
- `coreConfig`: complete config of the profile, see examples below
- `format`: "json" | "yaml" | ...

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

a folder, like `file:///path/to/folder/`

### generic

a https url, with text content like

```plain
#profile-title: base64:cHJvZmlsZS10aXRsZQ==
#profile-update-interval: 86400
#subscription-userinfo: upload=0; download=0; total=0; expire=0
#support-url: https://example.org/
#profile-web-page-url: https://example.org/
vmess://99c80931-f3f1-4f84-bffd-6eed6030f53d@example.org:31415?encryption=none#VMessTCPNaked
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
