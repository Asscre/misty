/// local server options 配置model
class LocalServerClientConfigItem {
  /// H5 路径标识
  String? key;

  /// 该路径是否下载完毕
  bool? isAssetsDone;

  /// 该路径优先级
  int priority = 0;

  /// 版本
  String? version;

  LocalServerClientConfigItem({this.key, this.isAssetsDone, this.version, this.priority = 0});

  static LocalServerClientConfigItem? parse(Map json) {
    if (json['open'] == null || json['open'] == 0) {
      return null;
    }
    return LocalServerClientConfigItem()
        ..isAssetsDone = false
        ..key = json['key']
        ..priority = json['priority'] ?? 0
        ..version = json['version'];
  }

  LocalServerClientConfigItem.fromJson(Map<String, dynamic> json) {
    isAssetsDone = json['isAssetsDone'];
    key = json['key'];
    priority = json['priority'] ?? 0;
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['isAssetsDone'] = isAssetsDone;
    data['key'] = key;
    data['priority'] = priority;
    data['version'] = version;
    return data;
  }

}