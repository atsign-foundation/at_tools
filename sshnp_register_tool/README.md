# sshnp_register_tool

This tool can onboard atSigns easily through the command-line and create the systemd.service (sshnpd.service) file for your device.

# Usage

There are two ways you can use this tool:

1. Dart
2. Binary

## 1. Dart

Fork the repository (or clone it) and run the tool from the repository itself via `dart run`.

```sh
dart run bin/sshnp_register_tool.dart -e <email@email.com>
```

## 2. Binary

Compile the tool and run it from anywhere (dart compile only works for the same OS e.g. windows <-> windows read more [here](https://dart.dev/tools/dart-compile)).

```sh
dart compile exe bin/sshnp_register_tool.dart -o sshnp_register_tool
```

Then

```sh
./sshnp_register_tool -e <email@email.com>
```

# Options and Flags

| Option        | Mandatory   | Description                                                    |
|---------------|-------------|----------------------------------------------------------------|
| -e, --email   | Yes         | Email address where you want your atSigns to be registered to. |
| -r, --rooturl | No          | URL of the root server. (Defaulted to root.atsign.org:64)      |

# sshnpd.service

Selecting 'd' then option (3.) will initialize the `sshnpd.service`. This service will run the `sshnpd` daemon on your device when the device boots up. If the sshnpd.service file needs to be edited, just edit the file in `lib/` and the code will read straight from that file.

Once the file is created, the tool will ask you to edit the file via `nano`. This is because line 11 needs to be changed to the atSigns that both the client and device will be using to communicate ssh without open ports.

# Examples

1. example of onboarding a free new atSign

```zsh
jeremytubongbanua@Jeremys-M2-Air sshnp_register_tool % dart run bin/sshnp_register_tool.dart -e jeremy.tubongbanua@atsign.com
Welcome to the sshnp setup tool!
Which one are you? ('c'=client or 'd'=device)
Enter choice:
^C
jeremytubongbanua@Jeremys-M2-Air sshnp_register_tool % dart run bin/sshnp_register_tool.dart -e jeremy.tubongbanua@atsign.com
Welcome to the sshnp setup tool!
Which one are you? ('c'=client or 'd'=device)
Enter choice:
c

You entered the client setup tool.
Choose an option:
1. I need a free atSign
2. I have an unactivated atSign
Enter choice:
1

Choose an atSign from the list below:
[1]: @51other1blue
[2]: @identicalstarling
[3]: @84theoretical
[4]: @192stepgarage8
[5]: @bittersweetzany
r to refresh
Enter choice:
1

You chose @51other1blue
Enter the OTP sent to your email (jeremy.tubongbanua@atsign.com):
UAE8

INFO|2022-10-05 19:26:42.383602|AtLookup|Creating new connection 

INFO|2022-10-05 19:26:43.307185|AtLookup|from result:data:_de7533d2-459d-4041-8a2d-64b88e49c3d9@51other1blue:327af596-86b0-46c1-8290-3a44378b69e8 

INFO|2022-10-05 19:26:43.381571|AtLookup|auth success 

INFO|2022-10-05 19:26:43.381954|OnboardingCli|Cram authentication status: true 

INFO|2022-10-05 19:26:43.382448|OnboardingCli|Generating pkam keypair 

INFO|2022-10-05 19:26:43.520976|OnboardingCli|Generating encryption keypair 

INFO|2022-10-05 19:26:43.668303|OnboardingCli|atKeys file saved at /Users/jeremytubongbanua/.atsign/keys/@51other1blue_key.atKeys 

INFO|2022-10-05 19:26:43.729822|OnboardingCli|PkamPublicKey update result: data:-1 

INFO|2022-10-05 19:26:43.816179|OnboardingCli|Encryption public key update result data:2 

INFO|2022-10-05 19:26:43.887611|OnboardingCli|Cram secret delete response : data:-1 

INFO|2022-10-05 19:26:44.119920|AtLookup|Creating new connection 

INFO|2022-10-05 19:26:44.947425|OnboardingCli|----------atSign activated--------- 

You have successfully onboarded your atSign @51other1blue
@51other1blue's keys can be found in ~/.atsign/keys/@51other1blue_key.atKeys
SEVERE|2022-10-05 19:26:44.948152|OnboardingCli|Killing current instance of at_onboarding_cli
```

2. example of onboarding an unactivated atSign (owned by you, but was never onboarded before or was just recently reset)

```zsh
jeremytubongbanua@Jeremys-M2-Air sshnp_register_tool % dart run bin/sshnp_register_tool.dart -e jeremy.tubongbanua@atsign.com
Welcome to the sshnp setup tool!
Which one are you? ('c'=client or 'd'=device)
Enter choice:
c

You entered the client setup tool.
Choose an option:
1. I need a free atSign
2. I have an unactivated atSign
Enter choice:
2

What is the unactivated atSign that you own?: 
@soccer0

Successfully sent otp to the email that owns the atSign.
Enter the OTP sent to your email (that owns the atSign)
1B84

Secondary address found! 7aba123c-58f7-55e1-bbd3-1d0eaebc0dcb.swarm0002.atsign.zone:5030 | Iterations: 24/10000000
Connecting...
INFO|2022-10-05 19:29:17.568899|AtLookup|Creating new connection 

INFO|2022-10-05 19:29:19.638669|AtLookup|from result:data:_5a31d7cc-1f68-49df-9f5f-4a5cf54518dd@soccer0:a18cf686-af05-4e81-975b-5012b3aff198 

INFO|2022-10-05 19:29:19.713555|AtLookup|auth success 

INFO|2022-10-05 19:29:19.714062|OnboardingCli|Cram authentication status: true 

INFO|2022-10-05 19:29:19.714560|OnboardingCli|Generating pkam keypair 

INFO|2022-10-05 19:29:19.876550|OnboardingCli|Generating encryption keypair 

INFO|2022-10-05 19:29:19.945189|OnboardingCli|atKeys file saved at /Users/jeremytubongbanua/.atsign/keys/@soccer0_key.atKeys 

INFO|2022-10-05 19:29:20.006261|OnboardingCli|PkamPublicKey update result: data:-1 

INFO|2022-10-05 19:29:20.056280|OnboardingCli|Encryption public key update result data:2 

INFO|2022-10-05 19:29:20.103481|OnboardingCli|Cram secret delete response : data:-1 

INFO|2022-10-05 19:29:20.324417|AtLookup|Creating new connection 

INFO|2022-10-05 19:29:20.873936|OnboardingCli|----------atSign activated--------- 

You have successfully onboarded your atSign @soccer0
@soccer0's keys can be found in ~/.atsign/keys/@soccer0_key.atKeys
SEVERE|2022-10-05 19:29:20.874806|OnboardingCli|Killing current instance of at_onboarding_cli 
```

3. example of initializing sshnpd.service

```zsh
jeremytubongbanua@Jeremys-M2-Air sshnp_register_tool % dart run bin/sshnp_register_tool.dart -e jeremy.tubongbanua@atsign.com
Welcome to the sshnp setup tool!
Which one are you? ('c'=client or 'd'=device)
Enter choice:
d

You entered the device setup tool.
Choose an option:
1. I need a free atSign
2. I have an unactivated atSign
3. Setup sshnpd.service (automatically run sshnpd (daemon) when device boots
Enter choice:
3

Looks like everything went well :)
Type nano etc/systemd/system/sshnpd.service to modify line 11 with the correct atSigns.

jeremytubongbanua@Jeremys-M2-Air sshnp_register_tool % 
```

