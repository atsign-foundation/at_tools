class VerbSyntax {
  static const from = r'^from:(?<atSign>@?[^@\s]+$)';
  static const pol = r'^pol$';
  static const cram = r'^cram:(?<digest>.+$)';
  static const pkam = r'^pkam:(?<signature>.+$)';
  static const llookup =
      r'^llookup:((?<operation>meta|all):)?(?:cached:)?((?:public:)|(@(?<forAtSign>[^@:\s]*):))?(?<atKey>[^:]((?!:{2})[^@])+)@(?<atSign>[^@\s]+)$';
  static const plookup =
      r'^plookup:((?<operation>meta|all):)?(?<atKey>[^@\s]+)@(?<atSign>[^@\s]+)$';
  static const lookup =
      r'^lookup:((?<operation>meta|all):)?(?<atKey>(?:[^:]).+)@(?<atSign>[^@\s]+)$';
  static const scan =
      r'^scan$|scan(:(?<forAtSign>@[^@\s]+))?( (?<regex>\S+))?$';
  static const config =
      r'^config:block:(?<operation>add|remove|show)(?:(?<=show)\s?$|(?:(?<=add|remove):(?<atSign>(?:@[^\s@]+)( (?:@[^\s@]+))*$)))';
  static const stats =
      r'^stats(?<statId>:((?!0)\d+)?(,(\d+))*)?(:(?<regex>(?<=:3:).+))?$';
  static const sync = r'^sync:(?<from_commit_seq>[0-9]+|-1)(:(?<regex>.+))?$';
  static const update =
      r'^update:json:(?<json>.+)$|^update:(?:ttl:(?<ttl>\d+):)?(?:ttb:(?<ttb>\d+):)?(?:ttr:(?<ttr>(-?)\d+):)?(ccd:(?<ccd>true|false):)?(?:dataSignature:(?<dataSignature>[^:@]+):)?(isBinary:(?<isBinary>true|false):)?(isEncrypted:(?<isEncrypted>true|false):)?(priority:(?<priority>low|medium|high):)?((?:public:)|(@(?<forAtSign>[^@:\s]*):))?(?<atKey>[^:@]((?!:{2})[^@])+)(?:@(?<atSign>[^@\s]*))? (?<value>.+$)';
  static const update_meta =
      r'^update:meta:((?:public:)|((?<forAtSign>@?[^@\s]*):))?(?<atKey>((?!:{2})[^@])+)@(?<atSign>[^@:\s]*)(:ttl:(?<ttl>\d+))?(:ttb:(?<ttb>\d+))?(:ttr:(?<ttr>\d+))?(:ccd:(?<ccd>true|false))?(:isBinary:(?<isBinary>true|false))?(:isEncrypted:(?<isEncrypted>true|false))?$';
  static const delete =
      r'^delete:(priority:(?<priority>low|medium|high):)?((?:public:)|(@(?<forAtSign>[^@:\s]*):))?(?<atKey>[^:]((?!:{2})[^@])+)@(?<atSign>[^@\s]+)$';
  static const monitor = r'(^monitor$|^monitor ?(?<regex>.*)?)$';
  static const stream =
      r'^stream:((?<operation>init|send|receive|done))?((@(?<receiver>[^@:\s]+)))?( (?<streamId>[\w-]*))?( (?<fileName>.* ))?((?<length>\d*))?';
  static const notify =
      r'^notify:((?<operation>update|delete|append|remove):)?(messageType:(?<messageType>key|text):)?(priority:(?<priority>low|medium|high):)?(strategy:(?<strategy>all|latest):)?(latestN:(?<latestN>\d+):)?(notifier:(?<notifier>[^\s:]+):)(ttl:(?<ttl>\d+):)?(ttb:(?<ttb>\d+):)?(ttr:(?<ttr>(-)?\d+):)?(ccd:(?<ccd>true|false):)?(@(?<forAtSign>[^@:\s]*)):(?<atKey>[^:]((?!:{2})[^@])+)(@(?<atSign>[^@:\s]+))?(:(?<value>.+))?$';
  static const notifyList = r'^notify:list(:(?<fromDate>\d{4}-[01]?\d?-[0123]?\d?))?(:(?<toDate>\d{4}-[01]?\d?-[0123]?\d?))?(:(?<regex>[^:]+))?';
  static const notifyStatus = r'^notify:status:(?<notificationId>\S+)$';
  static const notifyAll =
      r'^notify:all:((?<operation>update|delete):)?(messageType:((?<messageType>key|text):))?(?:ttl:(?<ttl>\d+):)?(?:ttb:(?<ttb>\d+):)?(?:ttr:(?<ttr>-?\d+):)?(?:ccd:(?<ccd>true|false+):)?(?<forAtSign>(([^:\s])+)?(,([^:\s]+))*)?(:(?<atKey>[^@:\s]+))(@(?<atSign>[^@:\s]+))?(:(?<value>.+))?$';
  static const batch = r'^batch:(?<json>.+)$';
}
