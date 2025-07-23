import 'dart:io';
import 'package:io/ansi.dart';

void printUsage([IOSink? stream]) {
  final output = stream ?? stdout;
  
  output.writeln(lightRed.wrap("\n AtClient REPL"));
  output.writeln("Notes:");
  output.writeln(
      "    1) By default, REPL treats input as atProtocol commands. Use / for additional commands listed below");

  output.write(
      "    2) In the usage examples below, it is assumed that the atSign being used is ");
  output.writeln(green.wrap("@alice \n"));
  output.write(magenta.wrap(" help or /help"));
  output.writeln("- print this help message \n");

  output.write(magenta.wrap("/scan"));
  output.write(green.wrap(" [regex] "));
  output.writeln(
      "- scan for all records, or all records whose keyNames match the regex (e.g. /scan test@alice.*) \n");

  output.write(magenta.wrap("/put"));
  output.write(green.wrap(" <atKeyName> "));
  output.write(lightBlue.wrap(" <value> "));
  output.writeln(
      "- create or update a record with the given atKeyName and with the supplied value \n  For example: ");

  output.write(magenta.wrap("   /put"));
  output.write(green.wrap(" test@alice "));
  output.write(lightBlue.wrap(" secrets  "));
  output.writeln(
      "->  will create or update a 'self' record (a record private just to @alice)");

  output.write(magenta.wrap("   /put"));
  output.write(green.wrap(" @bob:test@alice "));
  output.write(lightBlue.wrap(" Hello, Bob!  "));
  output.writeln(
      "->  will create or update a record encrypted for, and then shared with, @bob \n");

  output.write(magenta.wrap("/get"));
  output.write(green.wrap(" <atKeyName> "));
  output.writeln(
      "- retrieve a value from the record with this atKeyName \n For example: ");

  output.write(magenta.wrap("   /get"));
  output.write(green.wrap(" test@alice "));
  output.writeln("- retrieve a value from test@alice. \n");

  output.write(magenta.wrap("/delete"));
  output.write(green.wrap(" <atKeyName> "));
  output.writeln(
      "- delete the record with this atKeyName (e.g. /delete test@alice) \n");

  output.write(magenta.wrap("/q or /quit"));
  output.writeln("- will quit the REPL \n");

  output.write(magenta.wrap("/inspect"));
  output.write(green.wrap(" [regex] "));
  output.writeln(
      "- enter inspect mode to browse and manage AtKeys, optionally filtered by regex (default: excludes shared_key, publickey, and signing_privatekey) \n");

  output.write(magenta.wrap("/inspect_notify"));
  output.writeln(
      "- enter notification inspect mode to browse and manage notifications (view/delete) \n");

  output.write(magenta.wrap("/monitor"));
  output.write(green.wrap(" [regex] "));
  output.writeln(
      "- start monitoring notifications from the atServer with optional regex filtering (default: ignores statsNotification) \n");
}