<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## at_pkam

A command line tool to create PKAM authentication tokens.

### Building

__Assumption__ - you have the [Dart SDK](https://dart.dev/get-dart) installed.
The version should be >= 2.12.0 and <3.0.0.

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
FormatException: ArgParserException
-p, --file_path        .keys or .zip file path which contains keys
-r, --from_response    from:@atSign response
-a, --aes_key          aes key file path
                       (defaults to "")
```

Starting up the VM every time for a small command line app is a little slow,
so it's better to create a compiled binary:

```bash
dart compile exe bin/main.dart -o pkam
```

The binary can now be run with `./pkam` along with appropriate arguments.

### Usage

The PKAM tool is used to generate an authentication token to sign into an
@platform secondary server. You're going to need:

* The name of the secondary e.g. @turingcomplete
* The address and port of the secondary e.g. turingcomplete.mydomain.com:6565
* Keys for the secondary generated during activation e.g. @turingcomplete_key.atKeys

#### Connect to the secondary with OpenSSL

__Assumption__ - you have [OpenSSL](https://www.openssl.org/) installed.

```bash
openssl s_client -ign_eof turingcomplete.mydomain.com:6565
```

There will then follow a bunch of certificate and handshake information like:

```
CONNECTED(00000003)
depth=2 C = US, O = Internet Security Research Group, CN = ISRG Root X1
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = R3
verify return:1
depth=0 CN = turingcomplete.mydomain.com
verify return:1
---
Certificate chain
 0 s:CN = turingcomplete.mydomain.com
   i:C = US, O = Let's Encrypt, CN = R3
 1 s:C = US, O = Let's Encrypt, CN = R3
   i:C = US, O = Internet Security Research Group, CN = ISRG Root X1
 2 s:C = US, O = Internet Security Research Group, CN = ISRG Root X1
   i:O = Digital Signature Trust Co., CN = DST Root CA X3
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFKDCCBBCgAwIBAgISAwjRI5/zjWcPXyhPKz1sLdrKMA0GCSqGSIb3DQEBCwUA
MDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQD
EwJSMzAeFw0yMTA2MDExMTMyMTBaFw0yMTA4MzAxMTMyMTBaMBwxGjAYBgNVBAMT
EWRlc3MuamF2YWdvbmUub3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEAxHfYduxaBmQbS/SvmJY1rUoyzG5sr0H7M95sSwGyMcnpULEGq54g5+fSumCI
57OlC12T2skkq+Bz3I6HPppTHFLyJ1vzxZmlPRJhemc+lttnaDVI2Jnx/1IIlN3k
D8VOCJq0uGHX0NVjERdAhYaroAlsAC4fulHHiArO0uq0KPOjmaHvhZU2gfv0g8w2
uRiebwg0BQSkO5nY+8CEvnPwoW10dkP2EERZ3sk4iJscJWxK1u5qaZfUXu2aA23I
s5u2MNKxCEPz97EBC0qAcJcgtaS9TBJhS0MFD3NhmmR+NHNJ3OollOfDOVNxZRyi
fbQWnmB4/Xc6w1qwcSxOlQz8CQIDAQABo4ICTDCCAkgwDgYDVR0PAQH/BAQDAgWg
MB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB0G
A1UdDgQWBBQAr+DwphsaqG0vRD9MsL38VqU3JTAfBgNVHSMEGDAWgBQULrMXt1hW
y65QCUDmH6+dixTCxjBVBggrBgEFBQcBAQRJMEcwIQYIKwYBBQUHMAGGFWh0dHA6
Ly9yMy5vLmxlbmNyLm9yZzAiBggrBgEFBQcwAoYWaHR0cDovL3IzLmkubGVuY3Iu
b3JnLzAcBgNVHREEFTATghFkZXNzLmphdmFnb25lLm9yZzBMBgNVHSAERTBDMAgG
BmeBDAECATA3BgsrBgEEAYLfEwEBATAoMCYGCCsGAQUFBwIBFhpodHRwOi8vY3Bz
LmxldHNlbmNyeXB0Lm9yZzCCAQQGCisGAQQB1nkCBAIEgfUEgfIA8AB2AG9Tdqwx
8DEZ2JkApFEV/3cVHBHZAsEAKQaNsgiaN9kTAAABecePV2MAAAQDAEcwRQIgf1kf
G7TYMivat36rY10ofYf6VURYwJMTENKSQWKYK6ICIQDhBDBbVWzhK9NiKloTWWpi
ABV3FJqgUqAI+IN9zQBSdAB2APZclC/RdzAiFFQYCDCUVo7jTRMZM7/fDC8gC8xO
8WTjAAABecePVzQAAAQDAEcwRQIgfPT+NMBjqeCEXpWuhAm/JBfEP3zJEqn1ha7Z
/6YOrG4CIQDYcgMZYN3BPS1G97sa5bKyeIk7Ph7ZXGVWLLd3+rS0UTANBgkqhkiG
9w0BAQsFAAOCAQEALPibZueYDjXzbZQXYbCnYeZJU+u6jjEOgJOP/9GyN5BM96o/
2U4cg5aOSAFrG3T3bHzSvcWws68bqwvAd1Z3+6ZMzERd/ecLCQ3BWsio5kDlbxmk
eFN3C1HUDAeXahpOaAAXPtWTrNZtE5fQMM5ZY7dOZSArnzUPaHM3BYy8zzKKu4fD
N6UjKBOEvc3XwkP739FjEdHfaHckaWwQGuPSYcTO6vtQ307+it1tWV1+9vn0uswx
1BN7WSzRQoQcPGmrcpO3vgt4O+5CXk0xTtyabMGeTgGmpadIotnpvbld+W4N+p4P
xJQgdx1Vh8aTNBDKsJTmj3a6rckwdtHUBpj6qg==
-----END CERTIFICATE-----
subject=CN = turingcomplete.mydomain.com

issuer=C = US, O = Let's Encrypt, CN = R3

---
No client certificate CA names sent
Requested Signature Algorithms: ECDSA+SHA256:RSA-PSS+SHA256:RSA+SHA256:ECDSA+SHA384:RSA-PSS+SHA384:RSA+SHA384:RSA-PSS+SHA512:RSA+SHA512:RSA+SHA1
Shared Requested Signature Algorithms: ECDSA+SHA256:RSA-PSS+SHA256:RSA+SHA256:ECDSA+SHA384:RSA-PSS+SHA384:RSA+SHA384:RSA-PSS+SHA512:RSA+SHA512
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 4541 bytes and written 419 bytes
Verification: OK
---
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Server public key is 2048 bit
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 0 (ok)
---
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: 620EB882C045BA493B48D36D13CDE0CD65C83EBF0ACA471566C0EB197383AA5C
    Session-ID-ctx:
    Resumption PSK: 73465DE8E3702D9633D80008BC5B62B8819CB9CFA1A0E7C1EA9DCA9709096F3162A83AD3BB0699DBF2ECC71787659600
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 172800 (seconds)
    TLS session ticket:
    0000 - de 6a 37 8d 80 10 d5 ba-53 b5 68 78 3f 6d 39 c5   .j7.....S.hx?m9.
    0010 - 9c e7 3f 54 e4 0d bb d7-3f 2a bf a3 4f 4c 40 09   ..?T....?*..OL@.
    0020 - 44 77 83 c6 97 8d 68 eb-7c 19 e9 6d a7 58 aa 1a   Dw....h.|..m.X..
    0030 - 06 af 8d 02 bf c5 88 e1-9d a8 28 94 cb 92 e1 6d   ..........(....m
    0040 - f9 01 78 e1 dd b9 f5 0e-0b 0c 26 d8 0e 47 21 f5   ..x.......&..G!.
    0050 - c7 9e d6 b6 b9 7a 64 a8-96 44 7f 81 e2 a8 75 04   .....zd..D....u.
    0060 - e9 65 8f 20 da 1e 4e a4-0d b4 4f dd eb 2e a8 68   .e. ..N...O....h
    0070 - 84 30 b3 17 23 a7 51 c2-c4 7d 07 2e 0f c4 0a 23   .0..#.Q..}.....#
    0080 - 4e 97 e1 6e 69 1e c7 57-c2 e5 0d 8f 69 35 09 a6   N..ni..W....i5..
    0090 - 79 ee 75 4f 09 43 a2 5e-17 8c 23 b4 8e 9e bc 7c   y.uO.C.^..#....|
    00a0 - f7 ca 6b 79 e1 3d 17 d2-3d 08 f4 68 4d 78 dc 68   ..ky.=..=..hMx.h

    Start Time: 1622826331
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: 57334F5145A174B8F8E1252068F4B42DFEAB6F823E1B6E4B507B41DEB97AC070
    Session-ID-ctx:
    Resumption PSK: D52439A67A5398787A089F8DFFB7D44EF469E7DD989E5ADA2EC78DFE80B0FFFB1B7CB0EB87564E716ECC9F6D826E377F
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 172800 (seconds)
    TLS session ticket:
    0000 - de 6a 37 8d 80 10 d5 ba-53 b5 68 78 3f 6d 39 c5   .j7.....S.hx?m9.
    0010 - 4f 0a 49 1f b5 f1 f0 d9-65 66 af 84 63 ee b6 63   O.I.....ef..c..c
    0020 - 59 63 26 5a 66 f7 18 c1-2d f4 b3 21 46 60 22 9d   Yc&Zf...-..!F`".
    0030 - 75 b4 84 dd 87 40 6d bd-34 36 e1 52 12 50 c8 07   u....@m.46.R.P..
    0040 - 26 49 9a 9b 9d bc c6 5d-88 e5 99 56 ae 2f d8 d6   &I.....]...V./..
    0050 - 52 9f 22 a7 0d 50 8c cc-a9 90 1e bc 4e 6d 04 83   R."..P......Nm..
    0060 - 15 13 37 4c 9c 1f 8c ce-05 e0 93 7e bf 92 98 e3   ..7L.......~....
    0070 - d5 f5 52 71 ae ee 53 29-1c a0 62 29 c7 b7 a4 d9   ..Rq..S)..b)....
    0080 - 30 71 0b e1 8d 67 b1 9d-de 7d 9d 58 a8 db c3 31   0q...g...}.X...1
    0090 - 2f dc db ba 2b b1 79 47-67 af e8 13 d2 c1 ab 34   /...+.yGg......4
    00a0 - d3 55 7a 3e 5d 1f eb 34-b3 27 24 26 b5 8a 69 ec   .Uz>]..4.'$&..i.

    Start Time: 1622826331
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
```

Culminating in an `@` prompt. At the prompt initiate the authentication process:

```
from:@turingcomplete
```

This will result in a response like:

```
data:_82a2a0e5-9ad4-4f71-99f7-0cdd3798c7d0@turingcomplete:037e245d-34a6-4470-8764-992419a6c2fe
```

Copy the response after `data:` and use it in the PKAM tool (__Assumption__ you
have two sessions running, one for OpenSSL and the other for PKAM):

```
./pkam -p ~/@turingcomplete_key.atKeys -r \
_82a2a0e5-9ad4-4f71-99f7-0cdd3798c7d0@turingcomplete:037e245d-34a6-4470-8764-992419a6c2fe
```

__Assumption__ - your keys file has been copied to the HOME directory.

PKAM will generate a response like:

```
klW5RKSA6IevZJhR4Ig0rqqxbGt1f5G9Oa8yw7y/+AMTlu6LN8KUGvPTqc0EP9T0zUjxCVLBqvvD2e0ugRuarigEmQl0vktb7d7Vp3Bve6J+EI8rKhTDEzhe1XfN0LJTov1Gpo6DzYHq8bnP/4APNxnKPXS+ls5aIXh/I8yvxlO90+CHxyjjsMRm2c33eD+0vwGuGq+X+wT/YOU4TzAllIKlxHlA5kehTgS5WGinl3A8WG5pKE/+gFu3SRg/5sFwKf2E8DyYQaGRMuyMbOfLg4c3NTODyyMxZWx9bc2gtJ/kC52ngsPyBS3X0eyt1BSZliX/NeqTVTEWzMZMiOcf9w==
```

Go back to the openssl session and prefix `pkam:` to the response:

```
pkam:klW5RKSA6IevZJhR4Ig0rqqxbGt1f5G9Oa8yw7y/+AMTlu6LN8KUGvPTqc0EP9T0zUjxCVLBqvvD2e0ugRuarigEmQl0vktb7d7Vp3Bve6J+EI8rKhTDEzhe1XfN0LJTov1Gpo6DzYHq8bnP/4APNxnKPXS+ls5aIXh/I8yvxlO90+CHxyjjsMRm2c33eD+0vwGuGq+X+wT/YOU4TzAllIKlxHlA5kehTgS5WGinl3A8WG5pKE/+gFu3SRg/5sFwKf2E8DyYQaGRMuyMbOfLg4c3NTODyyMxZWx9bc2gtJ/kC52ngsPyBS3X0eyt1BSZliX/NeqTVTEWzMZMiOcf9w==
```

Should result in:

```
data:success
@turingcomplete@
```

At which point commands can be issued e.g. to scan for another secondary:

```
scan:@bletchleycolossus
```