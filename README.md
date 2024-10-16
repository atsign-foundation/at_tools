<a href="https://atsign.com#gh-light-mode-only"><img width=250px src="https://atsign.com/wp-content/uploads/2022/05/atsign-logo-horizontal-color2022.svg#gh-light-mode-only" alt="The Atsign Foundation"></a><a href="https://atsign.com#gh-dark-mode-only"><img width=250px src="https://atsign.com/wp-content/uploads/2023/08/atsign-logo-horizontal-reverse2022-Color.svg#gh-dark-mode-only" alt="The Atsign Foundation"></a>

[![GitHub License](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/atsign-foundation/at_tools/badge)](https://securityscorecards.dev/viewer/?uri=github.com/atsign-foundation/at_tools&sort_by=check-score&sort_direction=desc)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/8121/badge)](https://www.bestpractices.dev/projects/8121)

## at_tools

This repository contains atProtocol tools for developers
building atPlatform applications who wish to utilize the authentication
methods:

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

### Quickly build tools

Using melos, we can quickly build at_pkam, at_cram, at_cli, and at_repl via the
following commands:

```bash
dart pub get
dart run melos run build-tools
```

Then move the tools to a folder which you've exposed to the path for
convenience, for example:

```bash
cp ./build-tools/* ~/.local/bin/
# or
sudo cp ./build-tools/* /usr/local/bin/
```

