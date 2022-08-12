import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:misty/src/services/local_server_configuration.dart';
import 'package:misty/tools/local_server_binder.dart';
import 'package:misty/tools/local_server_status_handler.dart';
import 'package:path/path.dart';

/// Http Server 服务
/// @author jm
class LocalServerService extends LocalServerServiceHandler {
  factory LocalServerService() => _instance ??= LocalServerService._();

  static LocalServerService? _instance;

  LocalServerService._();

  /// 初始化配置
  /// 目录的加载
  invoke() async {
    await LocalServerConfiguration.getDistDirectory();
  }

  /// 获取对应 [oriUrl] 的 Local Server url（如http://127.0.0.1:12345）
  /// [localServerKey] 是拼接的path和query，如 test/index.html?v=1
  /// 返回的完整url为：http://127.0.0.1:12345/test/index.html?v=1
  String getLocalServerWebUrl(String oriUrl, String localServerKey) {
    return _getLocalServerWebUrl(oriUrl, localServerKey);
  }

  /// 注册状态回调
  /// 详见[LocalServerStatusHandler]
  void registerStatusObserve(LocalServerStatusHandler handler) {
    observe = handler;
  }

  /// 关闭状态回调
  void cancelStatusObserver() {
    observe = null;
  }

  /// 开启http server服务
  /// 见[HttpServer.bind]
  /// [address]若为null，则默认是127.0.0.1
  /// [port] 若为null，则默认是0
  Future<HttpServer> startServer([String? address, int? port]) =>
      _startServer(address, port);

  /// 关闭http server服务, 并且取消状态回调
  /// [force] 为true，立即关闭
  /// 见[HttpServer.close]
  void closeServer({bool force = false}) {
    _closeServer(force: force);
  }

  /// 关闭http server服务
  void cancelServer() => _cancelServer();
}

class LocalServerServiceHandler {
  final String _logKey = 'LocalServer';

  HttpServer? _server;

  int referenceCounter = 0;

  StreamSubscription? serverSub;

  bool isOpenServer = false;

  String? curAddresses;

  int curPort = 0;

  LocalServerStatusHandler? observe;

  /// oriUrl 其实没用，目前设计是统一一个本地地址。
  /// 但也可以考虑设计成不同链接对应不同的本地地址，启动多个服务。用[oriUrl] 来寻找
  String _getLocalServerWebUrl(String oriUrl, String localServerKey) {
    return 'http://${curAddresses ?? InternetAddress.loopbackIPv4.address}:$curPort$localServerKey';
  }

  Future<HttpServer> _startServer([String? address, int? port]) async {
    if (isOpenServer) {
      return Future.value(_server);
    }
    try {
      isOpenServer = true;
      var p = port;
      p ??= curPort;
      // 开启侦听 http 的请求，port为0则系统会自动选取一个临时端口
      _server =
          await HttpServer.bind(address ?? InternetAddress.loopbackIPv4, p);
      curAddresses = _server!.address.address;
      curPort = _server!.port;
      _server!.sessionTimeout = 60;
      // 拦截侦听
      serverSub = _server!
          .listen(_responseWebViewReq, onError: (e) => log(e, name: _logKey));
      if (observe != null) {
        observe!.createServerSuccess(curPort, curAddresses!);
      }
      return _server!;
    } catch (e) {
      isOpenServer = false;
      observe?.createServerFailure(e);
      rethrow;
    }
  }

  /// 还有webpage在使用的时候，不会关闭
  void _closeServer({bool force = false}) {
    if (referenceCounter > 0) {
      return;
    }
    observe?.serverWillCancel();
    isOpenServer = false;
    serverSub?.cancel();
    _server?.close(force: force);
    observe?.serverDidCancel();
  }

  void _cancelServer() {
    isOpenServer = false;
    serverSub?.cancel();
    _server?.close();
  }

  /// 根据拦截的请求（包括html，js，css等），返回对应资源的bytes data即替换
  /// 比如index.html，在获取给到webview后，会继续解析得到各js，css资源的请求，只要不是绝对路径也会被拦截
  void _responseWebViewReq(HttpRequest request) async {
    _getResponseData() async {
      try {
        String name;
        String? mime;
        String path = request.requestedUri.path;
        String component = path.split('/').toList().last;
        // 拿到文件名, [observe.fetchRespondsSources] 是获取对应缓存资源的数据
        var data = observe?.fetchRespondsSources(component);
        if (data == null) {
          // 有可能有 http://127.0.0.1:1234/test 这种形式的链接，所以尝试拿index.html文件来加载
          if (!component.contains('.')) {
            data = observe?.fetchRespondsSources('index.html');
          }
          if (data != null) {
            name = basename('index.html');
            mime = lookupMimeType(name);
          } else {
            // 找不到本地文件，使用网络下载拿到原始数据
            var nowUri = request.requestedUri;
            var baseDomain = LocalServerCacheBinderSetting().baseDomain;
            var baseUri = Uri.parse(baseDomain);
            // 替换为原始url
            nowUri = nowUri.replace(
                scheme: baseUri.scheme, host: baseUri.host, port: baseUri.port);
            // dio请求，responseType 必须是bytes
            var res = await Dio().getUri(nowUri,
                options: Options(responseType: ResponseType.bytes));
            data = res.data;
            name = basename(nowUri.path.split('/').toList().last);
            mime = lookupMimeType(name);
          }
        } else {
          // 根据文件名拿到对应的MimeType
          name = basename(component);
          mime = lookupMimeType(name);
        }
        request.response.headers.add('Content-Type', '$mime; charset=utf-8');
        return data;
      } catch (e) {
        observe?.requestServerFailure(request.requestedUri.toString(), e);
        rethrow;
      }
    }

    try {
      final data = await _getResponseData();
      request.response.add(data);
    } catch (e) {
      request.response.statusCode = 404;
      observe?.requestServerFailure(request.requestedUri.toString(), e);
      log('[local server request] Error${e.toString()}', name: _logKey);
    } finally {
      // 最后要关闭 response
      request.response.close();
    }
  }
}
