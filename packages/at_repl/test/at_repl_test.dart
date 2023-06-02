import 'package:at_repl/at_repl.dart';

void main() async {
  final String atSign = '@jeremy_0';
  REPL repl = REPL(atSign);
  final bool authenticated = await repl.authenticate();
  print('authentication success: $authenticated');
  final String result = await repl.executeCommand('scan');
  print('scan output: $result');
}
