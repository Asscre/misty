import 'package:misty/local_server/src/services/local_server_configuration.dart';

/// zip下载状态
enum LoadStateType {
  // 未下载
  unLoad,
  // 加载中
  loading,
  // 已下载
  success,
  // 下载失败
  failure,
}

class DownloadServiceItem {
  /// H5路径
  String h5Path = '';

  /// zip 压缩 url
  String zipUrl = '';

  /// 下载次数
  int downloadCount = 0;

  /// 下载状态
  LoadStateType loadState = LoadStateType.unLoad;

  /// file path
  List<String> filePath = [];

  /// 是否为Compress路径
  bool isCompress = false;

  String? version;

  DownloadServiceItem();

  DownloadServiceItem.fromJson(Map<String, dynamic> json) {
    h5Path = json['h5Path'];
    zipUrl = LocalServerConfiguration.downloadUrl(json['zipUrl']);
    isCompress = json['isCompress'];
    downloadCount = json['downloadCount'];
    loadState = LoadStateType.values[json['loadState'] ?? 0];
    if (json['filePath'] != null && json['filePath'] is List) {
      filePath = json['filePath'].cast<String>();
    }
    version = json['version'];
  }

  void replaceLoadState(DownloadServiceItem oldItem) {
    downloadCount = oldItem.downloadCount;
    filePath = oldItem.filePath;
    loadState = oldItem.loadState;
    version = oldItem.version;
  }

  void replaceFull(DownloadServiceItem oldItem) {
    downloadCount = oldItem.downloadCount;
    filePath = oldItem.filePath;
    loadState = oldItem.loadState;
    h5Path = oldItem.h5Path;
    zipUrl = LocalServerConfiguration.downloadUrl(oldItem.zipUrl);
    downloadCount = oldItem.downloadCount;
    filePath = oldItem.filePath;
    isCompress = oldItem.isCompress;
    version = oldItem.version;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['h5Path'] = h5Path;
    data['zipUrl'] = LocalServerConfiguration.downloadUrl(zipUrl);
    data['downloadCount'] = downloadCount;
    data['loadState'] = loadState.index;
    data['filePath'] = filePath;
    data['isCompress'] = isCompress;
    data['version'] = version;
    return data;
  }
}
