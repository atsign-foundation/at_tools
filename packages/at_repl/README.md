## at_repl

<a href="https://atsign.com#gh-light-mode-only"><img width=250px src="https://atsign.com/wp-content/uploads/2022/05/atsign-logo-horizontal-color2022.svg#gh-light-mode-only" alt="The Atsign Foundation"></a><a href="https://atsign.com#gh-dark-mode-only"><img width=250px src="https://atsign.com/wp-content/uploads/2023/08/atsign-logo-horizontal-reverse2022-Color.svg#gh-dark-mode-only" alt="The Atsign Foundation"></a>

[![pub package](https://img.shields.io/pub/v/at_repl)](https://pub.dev/packages/at_repl)
[![pub points](https://img.shields.io/badge/dynamic/json?url=https://pub.dev/api/packages/at_repl/score&label=pub%20score&query=grantedPoints)](https://pub.dev/packages/at_repl/score)
[![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

A CLI tool for interacting with an atServer using the atProtocol.

### Getting Started

Ensure you have your atSign keys. Keys are usually located in `$HOME/.atsign/keys`.

If you don't have an atSign, visit here <https://my.atsign.com/login>.

If the CLI application is available on [pub](https://pub.dev), activate globally via:

```sh
dart pub global activate at_repl
```

Or locally via:

```sh
cd packages/at_repl
dart pub global activate . -s path
```

### Usage

```sh
➜ dart run bin/at_repl.dart --help
Usage: at_repl [options]

Options:
-a, --atSign          The atSign to use
    --rootUrl         The root URL to connect to
                      (defaults to "root.atsign.org:64")
-k, --keys-file       Path to the atKeys file
-v, --[no-]verbose    Enable verbose output
-h, --[no-]help       Show this help message
```

### Example Execution

![screenshot of usage](./example/image.png)
