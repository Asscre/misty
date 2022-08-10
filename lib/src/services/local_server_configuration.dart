import 'dart:convert';
import 'dart:io';

import 'package:misty/tools/local_server_binder.dart';
import 'package:path_provider/path_provider.dart';

/// 本地文件缓存目录管理
class LocalServerConfiguration {
  static String? cacheDirectory;
  static Directory? distDirectory;
  static String kFileName = 'app_web_cache';
  static String kFileNameDist = 'app_web_cache/dist';
  static String kFileBasic = 'app_web_cache/basic';

  /// basic 统一文件类的存放目录
  static Future getBasicFile(String keyPath) async {
    Directory directory;
    if (cacheDirectory != null) {
      directory = Directory(cacheDirectory!);
    } else {
      directory = await getTemporaryDirectory();
      cacheDirectory = directory.path;
    }
    String distPath = '${directory.path}/$kFileBasic/$keyPath';
    final tmpFile = File(distPath);
    if (tmpFile.existsSync()) {
      return tmpFile;
    } else {
      try {
        final tmpDir = await tmpFile.create(recursive: true);
        return tmpDir;
      } catch (e) {
        rethrow;
      }
    }
  }

  /// dist 各项目的存放目录
  static Future<Directory> getDistDirectory() async {
    Directory directory;
    if (distDirectory != null) {
      return distDirectory!;
    }
    if (cacheDirectory != null) {
      directory = Directory(cacheDirectory!);
    } else {
      directory = await getTemporaryDirectory();
      cacheDirectory = '${directory.path}/$kFileName';
    }
    String distPath = '${directory.path}/$kFileNameDist';
    final tmpDirectory = Directory(distPath);
    if (tmpDirectory.existsSync()) {
      distDirectory = tmpDirectory;
      return tmpDirectory;
    } else {
      try {
        final tmpDir = await tmpDirectory.create(recursive: true);
        distDirectory = tmpDir;
        return tmpDir;
      } catch (e) {
        rethrow;
      }
    }
  }

  /// 检查当前项目是否已经存在
  static Future<bool> checkZipPathDirectoryIsExist(String zippurl) async {
    String zipTmpPath = base64Encode(utf8.encode(zippurl));
    final dist = await getDistDirectory();
    String zipPath = '${dist.path}/$zipTmpPath';
    final checkDirect = Directory(zipPath);
    return checkDirect.existsSync();
  }

  /// 返回对应路径
  static String joinZipPathSync(String zipUrl, String fileName) {
    Directory tmpDir = getCurrentZipPathSyncDirectory(zipUrl);
    if (fileName.isEmpty) {
      return tmpDir.path;
    }
    return '${tmpDir.path}/$fileName';
  }

  /// 返回对应目录
  static Directory getCurrentZipPathSyncDirectory(String zipUrl,
      {bool isExist = false}) {
    String zipTmpPath = base64Encode(utf8.encode(zipUrl));
    final dist = distDirectory!;
    String zipPath = '${dist.path}/$zipTmpPath';
    final checkDirect = Directory(zipPath);
    return checkDirect;
  }

  /// 处理为完整的下载downloadUrl
  /// 必须配置 [LocalServerCacheBinderSetting.instance.baseDomain]
  static String downloadUrl(String url) {
    String downUrl = url;
    if (!downUrl.startsWith('http') && !downUrl.startsWith('https')) {
      if (!downUrl.startsWith("/")) {
        downUrl = "/$downUrl";
      }
      downUrl = LocalServerCacheBinderSetting.instance.baseDomain + downUrl;
    }
    return downUrl;
  }
}
