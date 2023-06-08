## at_repl
<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

[![pub package](https://img.shields.io/pub/v/at_repl)](https://pub.dev/packages/at_repl)
[![pub points](https://img.shields.io/badge/dynamic/json?url=https://pub.dev/api/packages/at_repl/score&label=pub%20score&query=grantedPoints)]([https://pub.dev/packages/at_repl](https://pub.dev/packages/at_repl/score))
[![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)
A CLI application that talks directly to the atPlatform.

## Getting Started 
Ensure you have you atSign keys, keys are usually located in "homeDirectory\.atsign\keys".

If you don't have an atSign, visit here https://my.atsign.com/login. 

If the CLI application is available on [pub](https://pub.dev), activate globally via:

```sh
dart pub global activate at_repl
```

Or locally via:

```sh
dart pub global activate --source=path <path to this package>
```

## Usage

-a, user's atsign (REQUIRED)
-r, root URL (defaults to root.atsign.org:64) 
-v, verbose
-n, enforce namespaces (defaults to false)


```sh
#example of full REPL command
$ at_repl -a @xavierlin -r root.atsign.org:64 -v -n

#example of shortened REPL command
$ at_repl -a @xavierlin

```
