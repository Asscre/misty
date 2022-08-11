import 'package:flutter/material.dart';
import 'package:misty/misty.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    LocalServerWebViewManager.instance.initSetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Misty app'),
          centerTitle: true,
        ),
        body: Center(
          child: _openMistyView(),
        ),
      ),
    );
  }

  Widget _openMistyView() {
    return ElevatedButton(
      onPressed: () => Misty()
          .openMisty(context, 'https://jomin-web.web.app/test-one/index.html'),
      child: const Text('打开小程序'),
    );
  }
}

class LocalServerWebViewManager extends LocalServerClientManager {
  factory LocalServerWebViewManager() => _getInstance();

  static LocalServerWebViewManager get instance => _getInstance();
  static LocalServerWebViewManager? _instance;

  static LocalServerWebViewManager _getInstance() {
    _instance ??= LocalServerWebViewManager._internal();
    return _instance!;
  }

  LocalServerWebViewManager._internal();

  /// 测试的配置
  void initSetting() {
    init();
    LocalServerCacheBinderSetting.instance
        .setBaseHost('https://jomin-web.web.app');
    Map<String, dynamic> baCache = {
      'common': {'compress': '/local-server/common.zip', "version": "20220503"}
    };
    LocalServerClientConfig localServerClientConfig =
        LocalServerClientConfig.fromJson({
      'option': [
        {'key': 'test-one', 'open': 1, 'priority': 0, "version": "20220503"}
      ],
      'assets': {
        'test-one': {'compress': '/local-server/test-one.zip'}
      },
      'basics': baCache,
    });
    prepareManager(localServerClientConfig);
    startLocalServer();
  }
}
