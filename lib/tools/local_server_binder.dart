import 'dart:io';

import 'package:misty/src/model/download_service_total_asset_item.dart';
import 'package:misty/src/model/local_server_client_config.dart';
import 'package:misty/src/services/local_server_configuration.dart';
import 'package:misty/src/services/local_server_service.dart';

abstract class LocalServerCacheBuilderProtocol {
  dynamic findBuilderResource(String path) {}
}

/// Local Server Binder的配置
class LocalServerCacheBinderSetting {
  factory LocalServerCacheBinderSetting() =>
      _instance ??= LocalServerCacheBinderSetting._();

  static LocalServerCacheBinderSetting? _instance;

  LocalServerCacheBinderSetting._();

  LocalServerClientConfig? lsClientConfig;
  Map<String, dynamic>? basicCache;
  bool unSupportLocalServer = false;
  String baseDomain = "";

  void setConfig(LocalServerClientConfig config) {
    lsClientConfig = config;
  }

  void setSupportLocalServer(bool supportLocalServer) {
    unSupportLocalServer = !supportLocalServer;
  }

  void setBasicCache(Map<String, dynamic> basicCache) {
    this.basicCache = basicCache;
  }

  void setBaseHost(String domain) {
    baseDomain = domain;
  }
}

/// Binder 主要是在webpage，把当前项目的资源，携带上统一资源的资源指向
/// 返回LocalServer服务对应path的url
class LocalServerCacheBinder implements LocalServerCacheBuilderProtocol {
  LocalServerClientConfig? get lsClientConfig =>
      LocalServerCacheBinderSetting().lsClientConfig;

  Map<String, dynamic>? get basicCache =>
      LocalServerCacheBinderSetting().basicCache;

  /// 当前webview是否被禁止使用server
  bool get unSupportLocalServer =>
      LocalServerCacheBinderSetting().unSupportLocalServer;

  Map<String, dynamic> assetsCache = {};
  bool isLocalServer = false;

  String currentH5Path = "";

  void initBinder() {
    LocalServerService().referenceCounter++;
  }

  void dispose() {
    LocalServerService().referenceCounter--;
  }

  @override
  findBuilderResource(String path) {
    return assetsCache[path];
  }

  /// 转换为Local Server 使用的链接
  /// 转换失败则返回原链接[h5Path]
  String convertH5Url2LocalServerUrl(String h5Path) {
    // 无配置或者未打开的话，返回原链接
    if (lsClientConfig == null || !lsClientConfig!.isHavePermission) {
      return h5Path;
    }
    // Local Server 未开启
    if (unSupportLocalServer) {
      isLocalServer = false;
      return h5Path;
    }

    // options 无配置
    if (lsClientConfig!.options.isEmpty) {
      return h5Path;
    }

    DownloadServiceTotalAssetItem? tmpAsset;
    bool hasEmptyFiles = false;

    // 拿到对应的assets资源，和统一资源basic
    void _fetchMemorySources(DownloadServiceTotalAssetItem tmpAsset) {
      for (var element in tmpAsset.assets) {
        for (var filePath in element.filePath) {
          String path = LocalServerConfiguration.joinZipPathSync(
              element.zipUrl, filePath);
          File assetFile = File(path);

          if (!assetFile.existsSync()) {
            hasEmptyFiles = true;
            return;
          }
          var contents = assetFile.readAsBytesSync();
          List<String> splits = assetFile.path.split('/');
          String fileName = splits.last;
          assetsCache[fileName] = contents;
        }
      }
      if (basicCache != null) {
        assetsCache.addAll(basicCache!);
      }
    }

    Uri h5Uri = Uri.parse(h5Path);
    String path = h5Uri.path;
    String query = h5Uri.query;
    bool canUse = false;
    String optionKey = "";

    // 判断是否资源已经下载完成可使用
    for (var option in lsClientConfig!.options) {
      if (h5Path.contains(option.key!) && (option.isAssetsDone ?? false)) {
        canUse = true;
        optionKey = option.key!;
        break;
      }
    }
    if (!canUse) {
      isLocalServer = false;
      return h5Path;
    }
    tmpAsset = lsClientConfig!.assets[optionKey];
    if (tmpAsset == null) {
      isLocalServer = false;
      return h5Path;
    }
    _fetchMemorySources(tmpAsset);
    if (hasEmptyFiles) {
      return h5Path;
    }
    isLocalServer = true;
    return LocalServerService()
        .getLocalServerWebUrl(h5Path, query.isEmpty ? path : '$path?$query');
  }
}
