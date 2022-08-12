class MistyStartModel {
  /// cache base host
  String baseHost;

  /// compress file url (not include cache base host)
  String compress;

  /// compress version
  /// 如果此版本号高于缓存版本，则触发更新
  String version;

  /// 资源唯一key，用于查找web程序资源，是该程序的root路径
  String key;
  int? open;
  int? priority;

  MistyStartModel({
    required this.baseHost,
    required this.compress,
    required this.version,
    required this.key,
    this.open = 1,
    this.priority = 0,
  });
}
