<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

[![Build Status](https://github.com/atsign-foundation/at_tools/actions/workflows/at_tools.yaml/badge.svg)](https://github.com/atsign-foundation/at_tools/actions/workflows/at_tools.yaml)
[![GitHub License](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/atsign-foundation/at_tools/badge)](https://api.securityscorecards.dev/projects/github.com/atsign-foundation/at_tools)

## at_tools

This repository contains atProtocol tools and libraries for developers
building atPlatform applications who wish to utilize the authentication
methods and commonly used components of the atProtocol:

(These libraries can also be found on pub.dev as linked)

### pub.dev packages

[at_commons](https://pub.dev/packages/at_commons) Commonly used components
in implementation of the atProtocol.

[at_utils](https://pub.dev/packages/at_utils) This is the Utility library
for atProtocol projects. It contains utility classes for atsign, atmetadata,
configuration and logger.


### standalone tools

[at_cli](./packages/at_cli) A command line tool to execute verbs on the atPlatform.

[at_cram](./packages/at_cram) The challenge–response authentication mechanism of the
atProtocol.

[at_dump_atKeys](./packages/at_dump_atKeys) A command line tool to dump keys from a
.atKeys file.

[at_pkam](./packages/at_pkam) The public key authentication mechanism of the
atProtocol.

[at_ve_doctor](./packages/at_ve_doctor) A very simple way to test the status of the
secondaries running in the Virtual Environment. Using the
[at_server_status](https://pub.dev/packages/at_server_status) package.

[sshnp_register_tool](./sshnp_register_tool/) - Register/Onboard atSigns easily on your client or IoT device using this tool. The tool can also initialize your `sshnpd.service` on your IoT device.
