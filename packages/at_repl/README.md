## at_repl
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
