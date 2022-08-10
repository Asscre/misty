import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:misty/src/model/download_service_item.dart';
import 'package:misty/src/model/download_service_total_asset_item.dart';
import 'package:misty/src/model/local_server_client_config_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 相应的配置本地存储
class LocalServerConfigCache {
  static const String _optionKey = 'local_options_key';
  static const String _basicKey = 'local_basic_key';
  static const String _assetsKey = 'local_assets_key';
  static SharedPreferences? _sp;
  static Future<SharedPreferences> get getSp async {
    if (_sp != null) {
      return _sp!;
    } else {
      _sp = await SharedPreferences.getInstance();
      return _sp!;
    }
  }

  static Future setOptions(List<LocalServerClientConfigItem> items) async {
    List<Map<String, dynamic>> jsonList = items.map((e) => e.toJson()).toList();
    _saveJson(_optionKey, jsonList);
  }

  static Future<List<LocalServerClientConfigItem>?> getOptions() async {
    List? res = await _getJson<List>(_optionKey);
    if (res == null) {
      return null;
    }
    List<Map<String, dynamic>> decode =
        res.cast<Map<String, dynamic>>().toList();
    var optionList =
        decode.map((e) => LocalServerClientConfigItem.fromJson(e)).toList();
    return optionList;
  }

  static Future setBasic(List<DownloadServiceItem> basic) async {
    List<Map<String, dynamic>> jsonList = basic.map((e) => e.toJson()).toList();
    _saveJson(_basicKey, jsonList);
  }

  static Future<List<DownloadServiceItem>?> getBasic() async {
    List? res = await _getJson<List>(_basicKey);
    if (res == null) {
      return null;
    }
    List<Map<String, dynamic>> decode =
        res.cast<Map<String, dynamic>>().toList();
    var basicList = decode.map((e) => DownloadServiceItem.fromJson(e)).toList();
    return basicList;
  }

  static Future setAssets(
      Map<String, DownloadServiceTotalAssetItem> map) async {
    Map<String, String> saveJson =
        map.map((key, value) => MapEntry(key, json.encode(value.toJson())));
    String saveData = json.encode(saveJson);
    _saveJson(_assetsKey, saveData);
  }

  static Future<Map<String, DownloadServiceTotalAssetItem>?> getAssets() async {
    String? decodeStr = await _getJson<String>(_assetsKey);
    if (decodeStr == null) {
      return null;
    }

    try {
      Map<String, dynamic> saveJson = json.decode(decodeStr);
      var res = saveJson.map((key, value) => MapEntry(
          key, DownloadServiceTotalAssetItem.fromJson(json.decode(value))));
      return res;
    } catch (e) {
      _log(e.toString());
      rethrow;
    }
  }

  static void _saveJson(String key, Object jsonString) async {
    var sp = await getSp;
    if (jsonString is String) {
      sp.setString(key, jsonString);
    } else {
      var res = json.encode(jsonString);
      sp.setString(key, res);
    }
  }

  /// List, Map 转换不了里面的具体对象
  static Future<T?> _getJson<T>(String key) async {
    var sp = await getSp;
    var res = sp.getString(key);
    if (res == null) {
      return null;
    }
    if (T == String) {
      return res as T;
    }
    return json.decode(res) as T;
  }

  static void _log(Object msg) {
    if (!kReleaseMode) {
      log(msg.toString(), name: 'Local Service Cache');
    }
  }
}
