<a href="https://atsign.com#gh-light-mode-only"><img width=250px src="https://atsign.com/wp-content/uploads/2022/05/atsign-logo-horizontal-color2022.svg#gh-light-mode-only" alt="The Atsign Foundation"></a><a href="https://atsign.com#gh-dark-mode-only"><img width=250px src="https://atsign.com/wp-content/uploads/2023/08/atsign-logo-horizontal-reverse2022-Color.svg#gh-dark-mode-only" alt="The Atsign Foundation"></a>

# at_cli

A command line tool to execute verbs on at platform.

### Building

__Assumption__ - you have the [Dart SDK](https://dart.dev/get-dart) installed. The version should be >= 2.12.0 and <4.0.0.

First fetch dependencies (as defined in pubspec.yaml):

```bash
dart pub get
```

It's now possible to run the command in the Dart VM:

```bash
dart run bin/main.dart
```

At which point it will print out some usage instructions:

```
Usage: 
-a, --auth           Set this flag if command needs auth to server
-m, --mode           Choose Authentication mode if auth required
                     [cram, pkam]
-f, --authKeyFile    cram/pkam file path
    --atsign         Current Atsign
-c, --command        The at command to execute
-v, --verb           The verb to execute
-p, --public         set to true if key has public access
-k, --key            key to update
    --value          value of the key
-w, --shared_with    atsign to whom key is shared
-b, --shared_by      atsign who shared the key
-r, --regex          regex for scan
```

If you're going to run `atcli` a lot then it makes sense to create a binary
and copy it to somewhere on the PATH e.g.

```bash
dart compile exe bin/main.dart -o ~/atcli
sudo cp ~/atcli /usr/local/bin/
```

Verify the following information in config.yaml file. Please provide valid values.

```
root_server:
  # The port on which root server runs.
  port: 64
  host: 'root.atsign.org'
  
 auth:
  required: true # Authentication required for the Verb or not
  mode: cram     # Mode of Authentication (cram or pkam)
  key_file_location: 'bin/@alice' # File path which contains PKAM/CRAM secret 
  at_sign: '@alice'
```

Also, we can provide auth related information from commandline as mentioned above.

Here are some examples to execute verbs

__scan__
```
# Without Authentication
dart run bin/main.dart -v scan

#This command will return all the keys available publicly for atsign provided in config.yaml
# Alternatively we can provide atSign from commandline as follows
dart run bin/main.dart -v scan -a @alice

#sample output
[firstname@alice, location@alice, signing_publickey@alice]
```
```
# With Authentication
dart run bin/main.dart -v scan -a true
 or 
dart run bin/main.dart -v scan -a true -a @alice

# This command will return all the keys available for @alice by authenticating using cram/pkam provided in config.yaml

#sample output
[@alice:signing_privatekey@alice, public:firstname@alice, public:location@alice, public:signing_publickey@alice]

Note: We can provide Authenication mode using -m/--mode option, cram/pkam file path using -f/--authKeyFile options
```
__update__

Update verb is used to update/create a key with value.
Update verb required authentication. 
```
# Update/Create a key 'firstname' with value as 'alice' which is private to alice
 dart run bin/main.dart -v update -k firtname --value alice -p false -a true
 
# Sample output
true

# Update/Create a key 'lastname' with value as alice which is available publicly
 dart run bin/main.dart -v update -k firtname --value alice -p true -a true
 
# Sample output
true
```
__lookup__

Lookup verb is used to lookup particular key of an atSign. Lookup verb requires authentication.
```
# To lookup bob email
dart run bin/main.dart -v lookup -k email --atsign @bob -a true

# Sample output
bob@at.com

# You can run command to lookup bob's email as follows
 dart run bin/main.dart -c lookup:email@bob -a true
 
# Sample output
 bob@at.com
```

__llookup__

The "llookup" verb can be used to locally lookup keys stored on the secondary server. To execute Llookup authentication is required.
```
# To llookup firstname@alice
  dart run bin/main.dart -v llookup -k firstname --atsign @alice -a true

#sample output
  alice
  
# Alternatively we can run command directly as follows
dart run bin/main.dart -c llookup:firstname@alice -a true

# sample output
  alice
```

__plookup__

The "plookup" verb, provides a proxied public lookups for a resolver that perhaps is behind a firewall. This will allow a resolver to contact an atServer and have the atServer lookup both public atSign handles information.
```
# To lookup the value of public:location@alice
 dart run bin/main.dart -v plookup -k location --atsign @alice -a true 
 
# Sample output
 india
 
# We can run plookup command directly as follows
 dart run bin/main.dart -c plookup:location@alice -a true
 
# Sample output
 india
```