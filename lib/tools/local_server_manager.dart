import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:misty/model/download_service_item.dart';
import 'package:misty/model/local_server_client_config.dart';
import 'package:misty/services/local_server_configuration.dart';
import 'package:misty/services/local_server_service.dart';
import 'package:misty/tools/local_server_binder.dart';
import 'package:misty/tools/local_server_config_cache.dart';
import 'package:misty/tools/local_server_downloader.dart';
import 'package:misty/tools/local_server_status_handler.dart';

class LocalServerManager
    implements LocalServerStatusHandler, LocalServerDownloadServiceProtocol {
  late LocalServerClientConfig localServerClientConfig;
  Map<String, dynamic> basicCache = {};
  Map<String, bool> serviceDegradationMap = {};
  List<LocalServerCacheBinder> builders = [];
  final Map<String, dynamic> _fileCache = {};
  int loadStartTime = 0;

  bool unSupportLocalServer = false;

  void init() {
    _invokeModule();
  }

  void startLocalServer([String? address, int? port]) =>
      LocalServerService().startServer(address, port);

  void cancelLocalServer() => LocalServerService().cancelServer();

  void registerBuilder(LocalServerCacheBinder builder) => builders.add(builder);

  void resignBuilder(LocalServerCacheBinder builder) =>
      builders.remove(builder);

  void _invokeModule() async {
    LocalServerDownloadService().invoke(this);
    LocalServerService().invoke();
    LocalServerService().registerStatusObserve(this);
  }

  void prepareManager(LocalServerClientConfig localServerClientConfig) async {
    loadStartTime = DateTime.now().millisecondsSinceEpoch;
    this.localServerClientConfig = localServerClientConfig;
    LocalServerConfiguration.getDistDirectory();
    LocalServerCacheBinderSetting().setConfig(localServerClientConfig);
  }

  void setWebViewErrorCode(int errorCode) {
    switch (errorCode) {
      case -1:
      case -7:
      case -2:
      case -6:
      case -1004:
        unSupportLocalServer = true;
        break;
      default:
        break;
    }
  }

  @override
  fetchRespondsSources(String path) {
    dynamic res;
    for (var builder in builders) {
      res = builder.findBuilderResource(path);
      if (res != null) {
        break;
      }
    }

    if (res == null) {
      Map? sourceMsg = _fileCache[path];
      if (sourceMsg == null) {
        return null;
      } else {
        String path = LocalServerConfiguration.joinZipPathSync(
            sourceMsg['zipUrl'], sourceMsg['filePath']);
        File temFile = File(path);
        if (temFile.existsSync()) {
          return temFile.readAsBytesSync();
        } else {
          return null;
        }
      }
    }
    return res;
  }

  @override
  void simpleAssetDownloadsComplete(DownloadServiceItem item) {
    for (var file in item.filePath) {
      if (file.isEmpty) {
        return;
      }
      List<String> splits = file.split('/');
      String fileName = splits.last;
      Map map = {};
      map['zipUrl'] = item.zipUrl;
      map['h5Path'] = item.h5Path;
      map['filePath'] = file;
      _fileCache[fileName] = map;
    }
    localServerClientConfig.changeAssetsFromZipUrl(item);
  }

  @override
  simpleAssetDownloadsFailure(DownloadServiceItem item, String errMsg) {
    _log('[simpleAssetDownloadsFailure]$errMsg');
  }

  @override
  basicsDidFullyDownloaded(bool isSuc, List<DownloadServiceItem> basicsBucket) {
    if (localServerClientConfig.basicIsDown) {
      return;
    }
    Map<String, dynamic> tmpBasicCache = {};
    for (var loadItem in basicsBucket) {
      for (var p in loadItem.filePath) {
        String path =
            LocalServerConfiguration.joinZipPathSync(loadItem.zipUrl, p);
        File assetFile = File(path);
        if (assetFile.existsSync()) {
          var contents = assetFile.readAsBytesSync();
          List<String> splits = assetFile.path.split('/');
          String fileName = splits.last;
          tmpBasicCache[fileName] = contents;
        }
      }
    }
    basicCache = tmpBasicCache;
    LocalServerCacheBinderSetting().setBasicCache(basicCache);
    localServerClientConfig.basicIsDown = isSuc;
    _log(
        '??????Basic???????????????: ${(DateTime.now().millisecondsSinceEpoch - loadStartTime) / 1000}');
  }

  @override
  assetsDidFullyDownloaded() {
    for (var element in localServerClientConfig.options) {
      element.isAssetsDone = true;
    }
    _log(
        '??????Asset ????????? ?????????${(DateTime.now().millisecondsSinceEpoch - loadStartTime) / 1000}');
    LocalServerConfigCache.setAssets(localServerClientConfig.assets);
    LocalServerConfigCache.setOptions(localServerClientConfig.options);
  }

  @override
  createServerSuccess(int port, String localAddress) {
    _log('??????localserver ?????? port: $port localAddress:$localAddress');
  }

  @override
  createServerFailure(err) {
    _log('??????localserver ?????? err: ${err.toString()}');
  }

  @override
  serverWillCancel() {
    _log('localserver ???????????????');
  }

  @override
  serverDidCancel() {
    _log('localserver ????????????');
  }

  @override
  requestServerFailure(String path, Object error) {
    _log('localserver ???????????? uri:$path err:$error');
  }

  void _log(Object msg) {
    if (!kReleaseMode) {
      log(msg.toString(), name: 'Local Service Config');
    }
  }
}
