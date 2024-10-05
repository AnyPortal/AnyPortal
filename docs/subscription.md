# Subscription

A subscription is a remote profile group.

## protocol

Currently only fv2ray REST is implemented.

### fv2ray REST

It's a REST url expecting the following content.

```json
{
  "version": 1,
  "profiles": [
    {
      "name": "",
      "coreType": "",
      "coreConfig": {},
      "format": "json",
    }
  ]
}
```

- `name`: name of the profile
- `coreType`: "v2ray" | "xray" | "sing-box" | ...
- `coreConfig`: complete config of the profile
- `format`: "json" | "string" | ...

Upon updating, profiles of new names are added, missing names deleted, existing names updated.
