class VerbSyntax {
  static const String from = r'^from:(?<atSign>@?[^@\s]+$)';
  static const String pol = r'^pol$';
  static const String cram = r'^cram:(?<digest>.+$)';
  static const String pkam = r'^pkam:(?<signature>.+$)';
  static const String llookup =
      r'^llookup:((?<operation>meta|all):)?(?:cached:)?((?:public:)|(@(?<forAtSign>[^@:\s]*):))?(?<atKey>[^:]((?!:{2})[^@])+)@(?<atSign>[^@\s]+)$';
  static const String plookup =
      r'^plookup:((?<operation>meta|all):)?(?<atKey>[^@\s]+)@(?<atSign>[^@\s]+)$';
  static const String lookup =
      r'^lookup:((?<operation>meta|all):)?(?<atKey>(?:[^:]).+)@(?<atSign>[^@\s]+)$';
  static const String scan =
      r'^scan$|scan(:(?<forAtSign>@[^@\s]+))?( (?<regex>\S+))?$';
  static const String config =
      r'^config:block:(?<operation>add|remove|show)(?:(?<=show)\s?$|(?:(?<=add|remove):(?<atSign>(?:@[^\s@]+)( (?:@[^\s@]+))*$)))';
  static const String stats =
      r'^stats(?<statId>:((?!0)\d+)?(,(\d+))*)?(:(?<regex>(?<=:3:).+))?$';
  static const String sync =
      r'^sync:(?<from_commit_seq>[0-9]+|-1)(:(?<regex>.+))?$';
  static const String syncStream =
      r'^sync:stream:(?<from_commit_seq>[0-9]+|-1)(:(?<regex>.+))?$';
  static const String update =
      r'^update:json:(?<json>.+)$|^update:(?:ttl:(?<ttl>\d+):)?(?:ttb:(?<ttb>\d+):)?(?:ttr:(?<ttr>(-?)\d+):)?(ccd:(?<ccd>true|false):)?(?:dataSignature:(?<dataSignature>[^:@]+):)?(?:sharedKeyStatus:(?<sharedKeyStatus>[^:@]+):)?(isBinary:(?<isBinary>true|false):)?(isEncrypted:(?<isEncrypted>true|false):)?(priority:(?<priority>low|medium|high):)?((?:public:)|(@(?<forAtSign>[^@:\s]*):))?(?<atKey>[^:@]((?!:{2})[^@])+)(?:@(?<atSign>[^@\s]*))? (?<value>.+$)';
  static const String update_meta =
      r'^update:meta:((?:public:)|((?<forAtSign>@?[^@\s]*):))?(?<atKey>((?!:{2})[^@])+)@(?<atSign>[^@:\s]*)(:ttl:(?<ttl>\d+))?(:ttb:(?<ttb>\d+))?(:ttr:(?<ttr>\d+))?(:ccd:(?<ccd>true|false))?(?:sharedKeyStatus:(?<sharedKeyStatus>[^:@]+):)?(:isBinary:(?<isBinary>true|false))?(:isEncrypted:(?<isEncrypted>true|false))?$';
  static const String delete =
      r'^delete:(priority:(?<priority>low|medium|high):)?(?:cached:)?((?:public:)|(@(?<forAtSign>[^@:\s]*):))?(?<atKey>[^:]((?!:{2})[^@])+)(@(?<atSign>[^@\s]+))?$';
  static const String monitor =
      r'^monitor(:(?<epochMillis>\d+))?( (?<regex>.+))?$';
  static const String stream =
      r'^stream:((?<operation>init|send|receive|done|resume))?((@(?<receiver>[^@:\s]+)))?( ?namespace:(?<namespace>[\w-]+))?( ?startByte:(?<startByte>\d+))?( (?<streamId>[\w-]*))?( (?<fileName>.* ))?((?<length>\d*))?$';
  static const String notify =
      r'^notify:((?<operation>update|delete):)?(messageType:(?<messageType>key|text):)?(priority:(?<priority>low|medium|high):)?(strategy:(?<strategy>all|latest):)?(latestN:(?<latestN>\d+):)?(notifier:(?<notifier>[^\s:]+):)?(ttl:(?<ttl>\d+):)?(ttb:(?<ttb>\d+):)?(ttr:(?<ttr>(-)?\d+):)?(ccd:(?<ccd>true|false):)?(@(?<forAtSign>[^@:\s]*)):(?<atKey>[^:@]((?!:{2})[^@])+)(@(?<atSign>[^@:\s]+))?(:(?<value>.+))?$';
  static const String notifyList =
      r'^notify:list(:(?<fromDate>\d{4}-[01]?\d?-[0123]?\d?))?(:(?<toDate>\d{4}-[01]?\d?-[0123]?\d?))?(:(?<regex>[^:]+))?';
  static const String notifyStatus = r'^notify:status:(?<notificationId>\S+)$';
  static const String notifyAll =
      r'^notify:all:((?<operation>update|delete):)?(messageType:((?<messageType>key|text):))?(?:ttl:(?<ttl>\d+):)?(?:ttb:(?<ttb>\d+):)?(?:ttr:(?<ttr>-?\d+):)?(?:ccd:(?<ccd>true|false+):)?(?<forAtSign>(([^:\s])+)?(,([^:\s]+))*)(:(?<atKey>[^@:\s]+))(@(?<atSign>[^@:\s]+))?(:(?<value>.+))?$';
  static const String batch = r'^batch:(?<json>.+)$';
}
