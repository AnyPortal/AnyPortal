# Subscription

A subscription is a remote profile group.

## Protocol

Currently only AnyPortalREST is implemented.

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