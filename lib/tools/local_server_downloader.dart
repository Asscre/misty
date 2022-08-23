import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:misty/model/download_service_item.dart';
import 'package:misty/model/download_service_total_asset_item.dart';
import 'package:misty/services/local_server_configuration.dart';
import 'package:misty/tools/local_server_binder.dart';
import 'package:misty/tools/local_server_config_cache.dart';
import 'package:uuid/uuid.dart';

abstract class LocalServerDownloadServiceProtocol {
  /// 所有basic下载资源完成
  basicsDidFullyDownloaded(bool isSuc, List<DownloadServiceItem> basicsBucket);

  /// 所有Asset下载资源完成
  assetsDidFullyDownloaded();

  /// 单个asset下载完成
  simpleAssetDownloadsComplete(DownloadServiceItem item);

  /// 单个asset下载失败
  simpleAssetDownloadsFailure(DownloadServiceItem item, String errMsg);
}

/// Local Server 下载服务
class LocalServerDownloadService {
  factory LocalServerDownloadService() => _getInstance();

  static LocalServerDownloadService get instance => _getInstance();
  static LocalServerDownloadService? _instance;

  LocalServerDownloadService._internal();

  static LocalServerDownloadService _getInstance() {
    _instance ??= LocalServerDownloadService._internal();
    return _instance!;
  }

  static const String _logKey = 'local server downloader';

  /// 最大的同时下载数量
  int downloadMaxCount = 10;

  late LocalServerDownloadServiceProtocol _bind;

  List<DownloadServiceItem> _loadQueue = [];

  Map<String, Set<DownloadServiceItem>> _assetsBucket = {};

  List<DownloadServiceItem> basicsBucket = [];
  int sucCount = 0;

  void invoke(LocalServerDownloadServiceProtocol bind) => _bind = bind;

  /// 预载assets资源
  preloadAssetsData(List<DownloadServiceTotalAssetItem> assets) =>
      _preloadAssetsData(assets);

  /// 预载basics资源, [basicsCache] 是旧的需要去重的缓存
  preloadBasicsData(Map basicJson, Map<String, Map> basics,
          List<DownloadServiceItem>? basicsCache) =>
      _preloadBasicsData(basicJson, basics, basicsCache);

  int assetsBucketCount = 0;

  /// 下载队列
  void _downloadInQueue() {
    if (_loadQueue.length > 10 || _assetsBucket.isEmpty) {
      return;
    }
    List<DownloadServiceItem> dequeueList = _createTmpQueueList();
    _log('已下载个数：$sucCount');
    if (sucCount >= assetsBucketCount) {
      _log('当前_bucket资源已全部下载完毕');
      _assetsBucket.forEach((key, value) {
        for (var element in value) {
          _bind.simpleAssetDownloadsComplete(element);
        }
      });
      _bind.assetsDidFullyDownloaded();
      _assetsBucket = {};
      _loadQueue = [];
      return;
    }
    if (dequeueList.isEmpty) {
      return;
    }
    _loadQueue.addAll(dequeueList);

    _log(
        'bucket个数: ${_assetsBucket.length}  当前队列未下载个数: ${_loadQueue.length} 已下载个数：$sucCount');
    for (var queueItem in dequeueList) {
      // 判断路径之前是否存在
      if (queueItem.filePath.isNotEmpty &&
          queueItem.loadState == LoadStateType.success) {
        _log('当前资源无需下载使用之前缓存 zipUrl: ${queueItem.zipUrl}');
        _assetsBucket.remove(queueItem.zipUrl);
        assetsBucketCount--;
        _downloadInQueue();
        return;
      }
      final zipPath =
          "${LocalServerConfiguration.cacheDirectory}/${(const Uuid().v4())}.zip";
      queueItem.loadState = LoadStateType.loading;
      _log('dio 下载 zipUrl: ${queueItem.zipUrl}');
      Dio().download(queueItem.zipUrl, zipPath).then((resp) {
        if (resp.statusCode != 200) {
          _log('下载ls 压缩包失败  err:${resp.statusCode} zipUrl:${queueItem.zipUrl}');
          throw Exception('下载ls 压缩包失败  err:${resp.statusCode}');
        }
        return unarchive(queueItem, zipPath);
      }).then((item) {
        var assets = _assetsBucket[item.zipUrl];
        if (assets != null && assets.isNotEmpty) {
          for (var bucketItem in assets) {
            bucketItem.replaceLoadState(item);
          }
          _loadQueue.removeWhere((element) => element.zipUrl == item.zipUrl);
        }
        _downloadInQueue();
      }).catchError((err) {
        queueItem.loadState = LoadStateType.failure;
        queueItem.downloadCount += 1;
        var assets = _assetsBucket[queueItem.zipUrl];
        if (assets != null && assets.isNotEmpty) {
          for (var element in assets) {
            element.replaceLoadState(queueItem);
          }
        }
        _assetsBucket.remove(queueItem.zipUrl);
        assetsBucketCount--;
        _downloadInQueue();
        _log('解压失败  err:$err zipUrl:${queueItem.zipUrl}');
      });
    }
  }

  /// 解压
  DownloadServiceItem unarchive(DownloadServiceItem item, String downPath) {
    _log('unarchive 解压 path:${item.h5Path} zip:${item.zipUrl}');
    Directory saveDirct =
        LocalServerConfiguration.getCurrentZipPathSyncDirectory(item.zipUrl);
    final zipFile = File(downPath);
    if (!zipFile.existsSync()) {
      throw Exception('Local server 下载包文件路径不存在：$downPath');
    }
    List<int> bytes = zipFile.readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);

    try {
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          String filePath = '${saveDirct.path}/$filename';
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
          item.filePath.add(filename);
        } else {
          Directory('${saveDirct.path}/$filename').create(recursive: true);
        }
      }
      item.loadState = LoadStateType.success;
      // 清理之前的缓存
      File oldfile = File(downPath);
      if (oldfile.existsSync()) {
        oldfile.deleteSync();
      }
      _log('unarchive 解压成功');
      return item;
    } catch (e) {
      _log(
          'unarchive 解压失败 item: ${item.toJson().toString()}  downPath: $downPath  err: $e');
      rethrow;
    }
  }

  /// 创建下载任务列表
  List<DownloadServiceItem> _createTmpQueueList() {
    List<DownloadServiceItem> dequeueList = [];
    sucCount = 0;
    void _addQueue(DownloadServiceItem item) {
      if (dequeueList.length >= downloadMaxCount ||
          (dequeueList.length + _loadQueue.length) >= downloadMaxCount) {
        return;
      }
      if (_loadQueue.indexWhere((element) => element.zipUrl == item.zipUrl) !=
          -1) {
        // 下载列表中已存在则跳过
        return;
      }
      item.loadState = LoadStateType.unLoad;
      dequeueList.add(item);
    }

    void _traverseBucket() {
      _assetsBucket.forEach((key, value) {
        for (var tmpItem in value) {
          switch (tmpItem.loadState) {
            case LoadStateType.unLoad:
            case LoadStateType.loading:
              _addQueue(tmpItem);
              break;
            case LoadStateType.success:
              sucCount++;
              break;
            case LoadStateType.failure:
              _addQueue(tmpItem);
              break;
          }
        }
      });
    }

    _traverseBucket();
    return dequeueList;
  }

  /// basics 是另外下载的处理
  void _fetchBasicsDataFromNetwork(String key, DownloadServiceItem curItem,
      List<DownloadServiceItem> basicsCache) {
    if (basicsCache.isNotEmpty) {
      _bind.basicsDidFullyDownloaded(false, basicsCache);
    }
    // 判断basic是否全部下载
    void checkBasicDownloadAllDown() async {
      int sucLen = basicsBucket
          .where((element) => element.loadState == LoadStateType.success)
          .toList()
          .length;
      if (sucLen >=
          (LocalServerCacheBinderSetting().lsClientConfig?.basics.length ??
              1)) {
        // 保存记录
        await LocalServerConfigCache.setBasic(basicsBucket);
        // 通知外部basic单元就位
        _bind.basicsDidFullyDownloaded(true, basicsBucket);
      }
    }

    // 判断是否需要递归下载
    void checkBasicDownloadNeedRecursion() {
      int dirtyCount = basicsBucket
          .where((element) => (element.loadState == LoadStateType.unLoad &&
              element.downloadCount < downloadMaxCount))
          .toList()
          .length;
      if (dirtyCount <= 0) {
        _log("结束Basic 下载，部分资源下载失败");
        return;
      }
      _fetchBasicsDataFromNetwork(key, curItem, basicsCache);
    }

    // merge下载好的路径到_basicsBucket
    void replaceItem(DownloadServiceItem item) {
      for (var element in basicsBucket) {
        if (element.h5Path == item.h5Path) {
          element.replaceLoadState(item);
        }
      }
    }

    bool checkBasicCacheIsAvailable() {
      var cacheItemList =
          basicsCache.where((element) => element.h5Path == key).toList();
      if (cacheItemList.isEmpty) {
        return false;
      }
      var cacheItem = cacheItemList.first;
      // 之前没有持久化文件，则进入下载
      if (cacheItem.filePath.isEmpty) {
        return false;
      }

      if (cacheItem.zipUrl == curItem.zipUrl) {
        bool isExitFilePath = true;
        for (var filePath in cacheItem.filePath) {
          String tmpPath = LocalServerConfiguration.joinZipPathSync(
              cacheItem.zipUrl, filePath);
          File cacheFile = File(tmpPath);
          if (!cacheFile.existsSync()) {
            isExitFilePath = false;
          }
        }
        if (!isExitFilePath) {
          return false;
        }
        replaceItem(cacheItem);
        checkBasicDownloadAllDown();
        return true;
      } else {
        for (var deletePath in cacheItem.filePath) {
          String filePath = LocalServerConfiguration.joinZipPathSync(
              cacheItem.zipUrl, deletePath);
          File cacheFile = File(filePath);
          if (cacheFile.existsSync()) {
            cacheFile.deleteSync(recursive: true);
          }
        }
        cacheItem.filePath = [];
        return false;
      }
    }

    // 持久化检查有问题，进入本次下载
    if (checkBasicCacheIsAvailable()) {
      return;
    }
    final zipPath = '${LocalServerConfiguration.cacheDirectory}/$key.zip';
    Dio()
        .download(LocalServerConfiguration.downloadUrl(curItem.zipUrl), zipPath)
        .then((resp) {
      if (resp.statusCode != 200) {
        curItem.downloadCount++;
        curItem.loadState = LoadStateType.failure;
        throw Exception('下载ls 压缩包失败  err: ${resp.statusCode}');
      }
      return unarchive(curItem, zipPath);
    }).then((item) {
      replaceItem(item);
      checkBasicDownloadAllDown();
    }).catchError((err) {
      // 失败的移除，不在本次下载（可调整为尝试几次后再移除）
      basicsBucket.removeWhere((element) => element.zipUrl == curItem.zipUrl);
      _log(
          "basic 资源下载失败 zipUrl: ${LocalServerConfiguration.downloadUrl(curItem.zipUrl)}");
      checkBasicDownloadNeedRecursion();
    });
  }

  Map<String, Set<DownloadServiceItem>> _convertToBucketList(
      List<DownloadServiceTotalAssetItem> assets) {
    Map<String, Set<DownloadServiceItem>> _innerMap = {};
    for (var totalAsset in assets) {
      for (var value in totalAsset.assets) {
        Set? tmpZipBucket = _innerMap[value.zipUrl];
        if (tmpZipBucket == null) {
          Set<DownloadServiceItem> tmp = {}..add(value);
          _innerMap[value.zipUrl] = tmp;
        } else {
          tmpZipBucket.add(value);
        }
      }
    }
    return _innerMap;
  }

  void _preloadAssetsData(List<DownloadServiceTotalAssetItem> assets) {
    _assetsBucket.addAll(_convertToBucketList(assets));
    int tmpAssetsBucketCount = 0;
    _assetsBucket.forEach((key, value) {
      for (var element in value) {
        tmpAssetsBucketCount++;
        _log(
            'assets bucket 已有资源 loadState: ${element.loadState} path: ${element.h5Path} zip: ${element.zipUrl}');
      }
    });
    assetsBucketCount = tmpAssetsBucketCount;
    _downloadInQueue();
  }

  void _preloadBasicsData(Map basicJson, Map<String, Map> basics,
      List<DownloadServiceItem>? basicsCache) async {
    void makeBasicItemInBucket(String key) {
      if (basicJson[key] != null) {
        DownloadServiceItem tmpItem = DownloadServiceItem()
          ..h5Path = key
          ..zipUrl = LocalServerConfiguration.downloadUrl(
              basicJson[key]['compress'] ?? '')
          ..version = basicJson[key]['version']
          ..filePath = [];
        basicsBucket.add(tmpItem);
        _fetchBasicsDataFromNetwork(key, tmpItem, basicsCache ?? []);
      }
    }

    var basic = basics;
    for (var element in basic.keys) {
      makeBasicItemInBucket(element);
    }
  }

  void _log(Object msg) {
    if (!kReleaseMode) {
      log(msg.toString(), name: _logKey);
    }
  }
}
