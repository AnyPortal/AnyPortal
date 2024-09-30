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
      "config": {}
    }
  ]
}
```

- `name`: name of the profile
- `config`: complete v2ray json config of the profile

Upon updating, profiles of new names are added, missing names deleted, existing names updated.
