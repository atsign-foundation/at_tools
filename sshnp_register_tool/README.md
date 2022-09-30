# sshnp_register_tool

This tool can onboard atSigns easily through the command-line and create the systemd.service (sshnpd.service) file for your device.

# Usage

There are two ways you can use this tool:

1. Dart
2. Binary

## 1. Dart

Fork the repository (or clone it) and run the tool from the repository itself via dart.

```sh
dart run bin/sshnp_register_tool.dart -e <email@email.com>
```

## 2. Binary

Compile the tool and run it from anywhere.

```sh
dart compile exe bin/sshnp_register_tool.dart -o sshnp_register_tool
```

Then

```sh
./sshnp_register_tool.dart -e <email@email.com>
```

# Options and Flags

| Option        | Mandatory   | Description                                                    |
|---------------|-------------|----------------------------------------------------------------|
| -e, --email   | Yes         | Email address where you want your atSigns to be registered to. |
| -r, --rooturl | No          | URL of the root server. (Defaulted to root.atsign.org:64)      |

# sshnpd.service

Selecting 'd' then option (3.) will initialize the `sshnpd.service`. This service will run the `sshnpd` daemon on your device when the device boots up. If the sshnpd.service file needs to be edited, just edit the file in `lib/` and the code will read straight from that file.

Once the file is created, the tool will ask you to edit the file via `sudo nano`. This is because line 11 needs to be changed to the atSigns that both the client and device will be using to communicate ssh without open ports.

# Examples

TODO

1. example of onboarding a free new atSign
2. example of onboarding an unactivated atSign
3. example of initializing sshnpd.service