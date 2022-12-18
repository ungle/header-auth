# header-auth

Kong plugin for retrieving consumer from consumer name or id in custom header.
It would be useful when other infrastructures that have already authenticated requests before kong gateway and the gateway does not need to authenticate them again.

## How To use

### Install

see [load plugin](https://docs.konghq.com/gateway/latest/plugin-development/distribution/#verify-loading-the-plugin)

### Configuration

| Property         | Required | Default         | Comment                                                                    |
| ---------------- | -------- | --------------- | -------------------------------------------------------------------------- |
| header_name      | true     | x-conusmer-name | Header name that contains consumer name or id from upstream authentication |
| anonymous        | false    |                 | default user if header_name is not set                                     |
| hide_credentials | true     | false           | hide header in ***header_name***  to downstream services                   |


