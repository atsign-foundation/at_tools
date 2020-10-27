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
  static const stats = r'^stats(?<statId>:((?!0)\d+)?(,(\d+))*)?$';
  static const sync = r'^sync:(?<from_commit_seq>[0-9]+$|-1)';
  static const update =
      r'^update:(?:ttl:(?<ttl>\d+):)?(?:ttb:(?<ttb>\d+):)?(?:ttr:(?<ttr>(-?)\d+):)?(ccd:(?<ccd>true|false):)?(isBinary:(?<isBinary>true|false):)?(isEncrypted:(?<isEncrypted>true|false):)?((?:public:)|(@(?<forAtSign>[^@:\s]*):))?(?<atKey>[^:@]((?!:{2})[^@])+)(?:@(?<atSign>[^@\s]*))? (?<value>.+$)';
  static const update_meta =
      r'^update:meta:((?:public:)|((?<forAtSign>@?[^@\s]*):))?(?<atKey>((?!:{2})[^@])+)@(?<atSign>[^@:\s]*)(:ttl:(?<ttl>\d+))?(:ttb:(?<ttb>\d+))?(:ttr:(?<ttr>\d+))?(:ccd:(?<ccd>true|false))?(:isBinary:(?<isBinary>true|false))?(:isEncrypted:(?<isEncrypted>true|false))?$';
  static const delete = r'^delete:(?<atKey>.+$)';
  static const monitor = r'(^monitor$|^monitor ?(?<regex>.*)?)$';
  static const stream =
      r'^stream:((?<operation>init|send|receive|done))?((@(?<receiver>[^@:\s]+)))?( (?<streamId>[\w-]*))?( (?<fileName>[\w.-]*))?( (?<length>\d*))?';
  static const notify =
      r'^notify:((?<operation>update|delete):)?(ttl:(?<ttl>\d+):)?(ttb:(?<ttb>\d+):)?(ttr:(?<ttr>(-)?\d+):)?(ccd:(?<ccd>true|false):)?(@(?<forAtSign>[^@:\s]*)):(?<atKey>[^:]((?!:{2})[^@])+)@(?<atSign>[^@:\s]+)(:(?<value>.+))?$';
  static const notifyList = r'^notify:(list (?<regex>.*)|list$)';
}
