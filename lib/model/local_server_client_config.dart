import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:misty/model/download_service_item.dart';
import 'package:misty/model/download_service_total_asset_item.dart';
import 'package:misty/model/local_server_client_config_item.dart';
import 'package:misty/services/local_server_configuration.dart';
import 'package:misty/tools/local_server_config_cache.dart';
import 'package:misty/tools/local_server_downloader.dart';

class LocalServerClientConfig {
  String key = 'local_server_config';

  List<LocalServerClientConfigItem> options = [];

  Map<String, DownloadServiceTotalAssetItem> assets = {};

  Map<String, Map> basics = {};

  Map<String, List<DownloadServiceItem>> mappingZipAssets = {};

  bool isHavePermission = true;

  bool basicIsDown = false;

  Map permissionJsonCache = {};

  /// 解析配置json
  /// 默认的配置是
  /// {
  ///     "option": [
  ///         {
  ///             "key": "test",
  ///             "open": 1,
  ///             "priority": 0,
  ///             "version": "20222022"
  ///         },
  ///         {
  ///             "key": "test2",
  ///             "open": 0,
  ///             "priority": 0,
  ///             "version": "20222222"
  ///         }
  ///     ],
  ///     "assets": {
  ///         "test": {
  ///             "compress": "/local-server/test.zip"
  ///         },
  ///         "test2": {
  ///             "compress": "/local-server/test2.zip"
  ///         }
  ///     },
  ///     "basics": {
  ///         "common": {
  ///             "compress": "/local-server/common.zip",
  ///             "version": "20220501"
  ///         }
  ///     },
  ///     "local_server_open": 1
  /// }
  LocalServerClientConfig.fromJson(Map<String, dynamic> json) {
    // 拿到option，处理优先级和各配置
    List? optionJson = json['option'];
    if (optionJson != null && optionJson.isNotEmpty) {
      for (var value in optionJson) {
        final tmpItem = LocalServerClientConfigItem.parse(value);
        if (tmpItem != null) {
          options.add(tmpItem);
        }
      }
      options.sort((a, b) => (a.priority).compareTo(b.priority));
    }

    Map<String, dynamic> assetJson = json['assets'];
    Map basicMap = json['basics'];
    basicMap.forEach((key, value) {
      basics[key] = value as Map<String, dynamic>;
    });
    // 处理统一资源 Basic ，对比version，不一样的version则需要更新
    LocalServerConfigCache.getBasic().then(
      (value) {
        List<DownloadServiceItem>? oldBasic = List.from(value ?? []);
        // 版本不对，则移除，并需要下载
        if (value?.isNotEmpty ?? false) {
          for (DownloadServiceItem element in value!) {
            var res = basics[element.h5Path];
            if (res != null) {
              if (res['version'] != element.version) {
                oldBasic.removeWhere((e) => element.h5Path == e.h5Path);
              }
            }
          }
        }
        // 触发预下载
        LocalServerDownloadService.instance
            .preloadBasicsData(json['basics'], basics, oldBasic);
      },
    );

    Map<String, DownloadServiceTotalAssetItem> tmpAssets = {};
    for (var e in options) {
      if (assetJson[e.key] != null) {
        tmpAssets[e.key!] = DownloadServiceTotalAssetItem.fromConfigCenter(
            assetJson[e.key], e.key!);
      }
    }
    assets = tmpAssets;
    assets.forEach((key, value) {
      for (var element in value.assets) {
        if (mappingZipAssets.containsKey(element.zipUrl)) {
          mappingZipAssets[element.zipUrl]?.add(element);
        } else {
          mappingZipAssets[element.zipUrl] = [element];
        }
      }
    });

    // 处理 assets 资源，和版本控制
    LocalServerConfigCache.getOptions().then((oldOptions) {
      // assets 缓存和版本处理
      LocalServerConfigCache.getAssets().then((value) {
        var oldAssets = value;
        // 版本不对，则移除，并需要下载
        if (oldOptions != null) {
          for (var e in oldOptions) {
            var res = options.where((element) => element.key == e.key);
            if (res.isNotEmpty && res.first.version != e.version) {
              _log('资源 ${e.key} 需要更新');
              oldAssets?.removeWhere((key, value) => key == e.key);
            }
          }
        }
        // 触发预下载
        LocalServerDownloadService.instance
            .preloadAssetsData(_diffAssets(value, assets));
      });
    });
  }

  /// 更改Assets 的状态
  void changeAssetsFromZipUrl(DownloadServiceItem item) {
    if (mappingZipAssets.containsKey(item.zipUrl)) {
      for (var element in mappingZipAssets[item.zipUrl]!) {
        element.replaceLoadState(item);
      }
    }
  }

  List<DownloadServiceTotalAssetItem> _diffAssets(
      Map<String, DownloadServiceTotalAssetItem>? oldValue,
      Map<String, DownloadServiceTotalAssetItem>? newValue) {
    if (newValue == null || newValue.isEmpty) {
      return [];
    }
    List<DownloadServiceTotalAssetItem> resultList = [];
    Map<String, dynamic> oldMap = oldValue ?? {};
    Map<String, dynamic> newMap = newValue;

    newMap.keys.toList().forEach((keyPath) {
      DownloadServiceTotalAssetItem? oldAsset = oldMap[keyPath];
      DownloadServiceTotalAssetItem? newAsset = newMap[keyPath];
      // 如果在旧数据中没有找到新的页面缓存则 当前新数据加入结果数组
      if (oldAsset == null) {
        resultList.add(newMap[keyPath]);
        return;
      }

      //以上可以确保new和old数据同时有数据，接下来求两集合相交 找到 内部Zip的差异
      final oldZips = oldAsset.assets.map((e) => e.zipUrl).toSet();
      final newZips = newAsset!.assets.map((e) => e.zipUrl).toSet();
      Set<String> intersects = newZips.intersection(oldZips);

      // 遍历旧数据，如果当前zipurl不属于intersects子集，则执行清理文件操作，
      // 并标记整体当前oldAsset isAssetsDone 为false

      // 检查当前Asset旧数据是否可以转移到新数据里
      for (var oldZipItem in oldAsset.assets) {
        if (intersects.contains(oldZipItem.zipUrl)) {
          bool checkFileExist = true;
          for (var fileName in oldZipItem.filePath) {
            var realFilePath = LocalServerConfiguration.joinZipPathSync(
                oldZipItem.zipUrl, fileName);
            File file = File(realFilePath);
            // 检查文件是否可用，如果不可用则不能转移到new Asset
            if (!file.existsSync()) {
              checkFileExist = false;
            }
          }
          // 如果其中有file本地找不到则，标记当前Asset需要下载
          if (!checkFileExist) {
            oldZipItem.loadState = LoadStateType.unLoad;
            oldZipItem.filePath = [];
            oldAsset.isAssetsDone = false;
          }
        } else {
          // 如果不相交也不能转移
          oldZipItem.loadState = LoadStateType.unLoad;
          oldAsset.isAssetsDone = false;
          for (var fileName in oldZipItem.filePath) {
            var realFilePath = LocalServerConfiguration.joinZipPathSync(
                oldZipItem.zipUrl, fileName);
            File file = File(realFilePath);
            if (file.existsSync()) {
              file.deleteSync();
            }
          }
          oldZipItem.filePath = [];
        }
      }

      List<DownloadServiceItem> tmpNewAssets = [];
      int newAssetAllSucCount = 0;
      for (var newZipItem in newAsset.assets) {
        if (intersects.contains(newZipItem.zipUrl)) {
          newAssetAllSucCount++;
          for (DownloadServiceItem downloadItem in oldAsset.assets) {
            if (downloadItem.zipUrl == newZipItem.zipUrl) {
              tmpNewAssets.add(downloadItem);
              break;
            }
          }
        } else {
          tmpNewAssets.add(newZipItem);
        }
      }
      if (newAssetAllSucCount == newAsset.assets.length) {
        newAsset.isAssetsDone = oldAsset.isAssetsDone;
      }

      newAsset.assets = tmpNewAssets;
      resultList.add(newAsset);
    });
    return resultList;
  }

  static void _log(Object msg) {
    if (!kReleaseMode) {
      log(msg.toString(), name: 'Local Service Config');
    }
  }
}
