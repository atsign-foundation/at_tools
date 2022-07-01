<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

## at_cram

The at_cram utility is used to create the authentication digest when connecting
to a secondary server that does not yet have pkam authentication activated.

When a secondary is started up for the first time it is started with a shared
secret via the commandline. That shared secret is shared with the person who
owns the atSign of the secondary. This is normally done on both the
[atsign.com](atsign.com) website and when using
[dess](https://github.com/atsign-foundation/dess) via the use of a QRCode.

When using the [Virtual Environment](https://github.com/atsign-foundation/at_virtual_environment) (VE) the 
shared secrets can be found [here](https://github.com/atsign-foundation/at_tools/tree/trunk/at_cram/cramkeys)
for each of the preconfigured atSigns in VE.

The cram: atProtocol verb is only used to bootstrap a new secondary so that the public keys can be transfered to the secondary. Once the pkam keys have been set the cram process is disabled. The means that before the secondary is used for the atSigns data the cram is disabled and the pkam used going forward.

To use the at_cram utility connect to a new secondary with a known shared secret, enter the from: verb
and the atSign to authenticate as then use the cram: verb with the result of the at_cram binary.
 To use the at_cram tool run `dart bin/at_cram <file containing shared secret>` then cut and paste the 
result in to the cram:<digest> verb.

For example when using VE

[![asciicast](https://asciinema.org/a/4YBCRUt4duFs9u4fAEfmMhhAS.svg)](https://asciinema.org/a/4YBCRUt4duFs9u4fAEfmMhhAS)

### at_cram_single
The `at_cram_single` dart program can cram digest all in a single command. Simply:
1. `dart bin/at_cram_single.dart <cramSecret> <challenge>`
2. Program will output digest (Use the digest via `cram:<digest>` in the @protocol)

Or compile the program:
1. Compile `dart compile exe bin/at_cram_single.dart -o cram`
2. Run `./cram <cramSecret> <digest>`
3. Program will output digest (Use the digest via `cram:<digest>` in the @protocol)

Here we connect to the @colin🛠  secondary on port 25004 using openssl and then issue the from: verb with
@colin🛠 as the argument, the challenge is given back in return. This challenge is then put into the
at_cram tool and a digest given back. This digest in then entered using the cram: verb and it is successful 
as the @colin🛠@ prompt is returned.

## How this works

The shared secret is known to the person and the secondary but we do not want to send it across the wire.
The solution is adding the shared secret to the challenge and then sending over a SHA hash of the resulting string. This is what the at_cram binary does, it is not complex at all, but very effective.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
