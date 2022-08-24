import 'package:misty/model/local_server_client_config.dart';
import 'package:misty/model/misty_start_model.dart';
import 'package:misty/tools/local_server_binder.dart';
import 'package:misty/tools/local_server_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MistyHandler extends LocalServerManager {
  factory MistyHandler() => _instance ??= MistyHandler._internal();
  static MistyHandler? _instance;
  MistyHandler._internal();

  WebViewController? _webViewController;

  void initSetting(MistyStartModel params) {
    init();
    LocalServerCacheBinderSetting().setBaseHost(params.baseHost);
    Map<String, dynamic> assets = {};
    params.assets
        .map(
      (e) => {
        e.keys.first: {'compress': e.values.first},
      },
    )
        .forEach((j) {
      assets.addAll(j);
    });
    LocalServerClientConfig localServerClientConfig =
        LocalServerClientConfig.fromJson({
      'option': params.options.map((e) => e.toJson()).toList(),
      'assets': assets,
      'basics': params.basics.toJson(),
    });
    prepareManager(localServerClientConfig);
    startLocalServer();
  }

  void setWebViewController(WebViewController webViewController) {
    _webViewController = webViewController;
  }

  void callJs(dynamic params) {
    _webViewController?.runJavascript("flutterCallJs('${params.toString()}')");
  }
}
