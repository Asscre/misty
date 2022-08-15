class MistyStartModel {
  /// cache base host
  String baseHost;

  /// compress file url (not include cache base host)
  // String compress;

  /// compress version
  /// 如果此版本号高于缓存版本，则触发更新
  // String version;

  /// 程序zip资源
  List<Map<String, String>> assets;

  /// 资源唯一key，用于查找web程序资源，是该程序的root路径
  // String key;
  // int? open;
  // int? priority;
  Basics basics;
  List<Option> options;

  MistyStartModel({
    required this.baseHost,
    required this.basics,
    required this.options,
    // required this.compress,
    required this.assets,
    // required this.version,
    // required this.key,
    // this.open = 1,
    // this.priority = 0,
  });
}

class Option {
  late String key;
  late int open;
  late int priority;
  late String version;

  Option({
    required this.key,
    required this.open,
    required this.priority,
    required this.version,
  });

  Option.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    open = json['open'];
    priority = json['priority'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['open'] = open;
    data['priority'] = priority;
    data['version'] = version;
    return data;
  }
}

class Basics {
  Common? common;

  Basics({this.common});

  Basics.fromJson(Map<String, dynamic> json) {
    common = json['common'] != null ? Common.fromJson(json['common']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (common != null) {
      data['common'] = common!.toJson();
    }
    return data;
  }
}

class Common {
  late String compress;
  late String version;

  Common({required this.compress, required this.version});

  Common.fromJson(Map<String, dynamic> json) {
    compress = json['compress'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['compress'] = compress;
    data['version'] = version;
    return data;
  }
}
