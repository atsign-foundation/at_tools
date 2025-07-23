# REPL

The goal of REPL is to provide an interactive interface for people to interact with their atServer.

Once staretd via `dart run bin/at_repl.dart -a <atSign>`, you can do one of two things

1. Pass a raw atProtocol command (such as `scan`, `llookup`, `plookup`, `update` + '\n' etc) which will send a raw command to the atServer and print the response.
2. Use the REPL commands which are prefixed with `/` to interact with the atServer which are commands that use the AtClient object to interact with the atServer.
An atServer is just like a key-value store database, so you can use the REPL commands to get, put, delete, scan, monitor and inspect keys in the atServer.

## REPL Commands

- `/scan [regex]` - Scans for atKeys that match the regex. Defaults to `.*` if no regex is provided.
- `/get <atKey>` - Gets the value of the atKey.
- `/put <atKey> <value>` - Puts the value into the atKey.
- `/delete <atKey>` - Deletes the atKey.
- `/monitor [regex]` - Monitors for atKeys that match the regex. Defaults to omitting the following list of strings: `['statsNotification']`.
- `/help` - Prints the usage of the REPL commands.
- `/inspect [regex]` - inspects AtKeys and gives you an interactive experience where you can enter an index and either v (view) or d (delete) the AtKey. By default, the regex omits the following list of strings: `['shared_key', 'signing_privatekey', 'signing_publickey', 'publickey']`. When it prompts you to enter an index, you can also enter 'l' to relist the keys or 'q' to quit the interactive mode.
- `/inspect_notify` - Uses `notify:list` to receive notifications and allows you to inspect them interactively using similar logic to inspect, and also allows you to delete notifications.

## Interactive Mode

There are different REPL or Interactive modes that you can enter:

- **Main Mode**: This is the default mode where you can enter any of the REPL commands.
- **Inspect Keys Mode**: This mode is entered when you use the `/inspect` command.
- **Inspect Notifications Mode**: This mode is entered when you use the `/inspect_notify` command.
- **Monitor Mode**: This mode is entered when you use the `/monitor` command.

Each of these modes `implements` the interactive session interface

## Default Regexes

We omit certain keys from the default regexes for the following reasons:

1. For monitor mode, we default regex to omit statsNotification because the atServer automatically sends stats notifications which are not useful for the user.
2. For inspect keys mode, we default regex to omit the following list of strings: `['shared_key', 'signing_privatekey', 'signing_publickey', 'publickey']` because these keys are not useful for the user to inspect, and they are used for the atClient to function properly. Generally, these should not be deleted or tampered with unless you know what you are doing.
