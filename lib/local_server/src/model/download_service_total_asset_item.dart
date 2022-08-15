import 'package:misty/local_server/src/model/download_service_item.dart';
import 'package:misty/local_server/src/services/local_server_configuration.dart';

class DownloadServiceTotalAssetItem {
  String h5Path = '';
  bool isAssetsDone = false;
  List<DownloadServiceItem> assets = [];

  DownloadServiceTotalAssetItem.fromConfigCenter(
      Map<String, dynamic> json, String keyPath) {
    h5Path = keyPath;
    DownloadServiceItem _createItem(String url, bool isCom) {
      return DownloadServiceItem()
        ..h5Path = h5Path
        ..zipUrl = LocalServerConfiguration.downloadUrl(url)
        ..downloadCount = 0
        ..loadState = LoadStateType.unLoad
        ..isCompress = isCom
        ..filePath = [];
    }

    List<DownloadServiceItem> tmPAssets = [];
    if (json['compress'] != null) {
      tmPAssets.add(_createItem(json['compress'], true));
    }
    if (json['deps'] != null) {
      List deps = json['deps'];
      var tempDeps = deps.toList().map((e) => _createItem(e, false)).toList();
      tmPAssets.addAll(tempDeps);
    }
    assets = tmPAssets;
  }

  DownloadServiceTotalAssetItem.fromJson(Map<String, dynamic> json) {
    h5Path = json['h5Path'];
    isAssetsDone = json['isAssetsDone'];
    if (json['assets'] != null) {
      List tmpAssets = json['assets'];
      assets = tmpAssets.map((e) => DownloadServiceItem.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['h5Path'] = h5Path;
    data['isAssetsDone'] = isAssetsDone;
    if (assets.isNotEmpty) {
      data['assets'] = assets.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
