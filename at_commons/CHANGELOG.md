## 3.0.13
- Generate default notification id
## 3.0.12
- Added optional parameter to info verb. Valid syntax is now either 'info' or 'info:brief'
## 3.0.11
- Rename 'NotifyDelete' to 'NotifyRemove' since 'notify:delete' is already in use.
## 3.0.10
- Added syntax regex for 'notifyDelete' verb
## 3.0.9
- Bug fix in notify verb syntax
## 3.0.8
- Support for encryption shared key and public key in notify verb
## 3.0.7
- Added encryption shared key and public key checksum to metadata
## 3.0.6
- Added syntax regexes for new verbs 'info' and 'noop'
## 3.0.5
- Rename TimeoutException to AtTimeoutException to prevent confusion with Dart async's TimeoutException
## 3.0.4
- Add TimeoutException
## 3.0.3
- Add static factor methods for AtKey creation
## 3.0.2
- added constants for compaction and notification expiry
## 3.0.1
- Add AtKey validations
## 3.0.0
- sync pagination changes
## 2.0.5
- version 2.0.4 update issue
## 2.0.4
- Shared key status in metadata
- Add last notification time to Monitor
## 2.0.3
- Syntax change in stream verb to support resume
## 2.0.2
- Fix regex issue in Notify verb
## 2.0.1
- Remove trailing space in StatsVerbBuilder
## 2.0.0
- Null safety upgrade
## 1.0.1+8
- Refactor code with dart lint rules
## 1.0.1+7
- Third party package dependency upgrade
## 1.0.1+6
- Replace ByteBuffer with ByteBuilder
## 1.0.1+5
- Notification sub system changes
## 1.0.1+4
- added createdAt and updatedAt to metadata
  Introduced batch verb for sync
## 1.0.1+3
- Notify verb builder and update verb syntax changes
## 1.0.1+2
- Update verb builder changes
## 1.0.1+1
- Stream verb syntax changes
## 1.0.1
- Initial version, created by Stagehand
