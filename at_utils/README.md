<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for a little internet optimism

# at_utils
`at_utils` is the Utility library for @protocol projects. It contains utility classes for atsign, atmetadata, configuration and logger.

## Installation:
To use this library in your app, first add it to your `pubspec.yaml`.

```yaml
dependencies:
  at_utils: ^2.0.5
```
### Add to your project 
```bash
pub get 
```
### Import in your application code
```dart
import 'package:at_utils/at_utils.dart';
```
## Usage

```dart
AtSignLogger logger = AtSignLogger('YOUR PROJECT/APPLICATION NAME');
logger.info('INFO MESSASGE YOU WANT TO PRINT');
logger.shout('SHOUT MESSASGE YOU WANT TO PRINT');
logger.sever('SEVERE MESSASGE YOU WANT TO PRINT');
logger.warning('WARNING MESSASGE YOU WANT TO PRINT');
```

**OUTPUT:**

```bash
💡 [INFO] | August 6, 2021 11:59:59 AM | YOUR PROJECT/APPLICATION NAME | INFO MESSASGE YOU WANT TO PRINT 

🔫 [SHOUT] | August 6, 2021 11:59:59 AM | YOUR PROJECT/APPLICATION NAME | SHOUT MESSASGE YOU WANT TO PRINT

💥 [SEVERE] | August 6, 2021 11:59:59 AM | YOUR PROJECT/APPLICATION NAME | SEVERE MESSASGE YOU WANT TO PRINT

❓ [WARNING] | August 6, 2021 11:59:59 AM | YOUR PROJECT/APPLICATION NAME | WARNING MESSASGE YOU WANT TO PRINT
```
Please refer to the [Example](https://pub.dev/packages/at_utils/example) section more information on how to use this library.
