import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:misty/local_server/tools/local_server_binder.dart';
import 'package:misty/misty_handler.dart';
import 'package:misty/navigation/navigation_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'common/basis_scaffold.dart';

class MistyView extends StatefulWidget {
  const MistyView({Key? key, required this.assetsUrl}) : super(key: key);
  final String assetsUrl;

  @override
  State<MistyView> createState() => _MistyViewState();
}

class _MistyViewState extends State<MistyView> {
  /// resources are ready
  bool isAssetsReady = false;

  // Local server 管理
  late LocalServerCacheBinder _localServerBuilder;
  WebViewController? webViewController;
  String _innerUrl = '';
  String _title = '';
  bool pageIsOk = false;

  @override
  void initState() {
    log('页面开始加载：${DateTime.now()}', name: 'web-time');
    _localServerBuilder = LocalServerCacheBinder()..initBinder();
    MistyHandler().registerBuilder(_localServerBuilder);
    _innerUrl =
        _localServerBuilder.convertH5Url2LocalServerUrl(widget.assetsUrl);
    super.initState();
  }

  @override
  void dispose() {
    MistyHandler().resignBuilder(_localServerBuilder);
    _localServerBuilder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasisScaffold(
      title: _title,
      leading: const SizedBox(),
      body: _bodyWidget(),
    );
  }

  // Widget _loadingWidget() {
  //   return const Center(
  //     child: CircularProgressIndicator(),
  //   );
  // }

  Widget _bodyWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: WebView(
        initialUrl: _innerUrl,
        debuggingEnabled: true,
        onPageStarted: (url) {
          log("onPageStarted($url) ----------------------");
          log('Web开始加载：${DateTime.now()}', name: 'web-time');
        },
        onPageFinished: (url) {
          log("onPageFinished($url) ----------------------");
          log('Web加载完成：${DateTime.now()}', name: 'web-time');
          Future.delayed(const Duration(milliseconds: 30), () {
            setState(() {
              pageIsOk = true;
            });
          });
          webViewController!.getTitle().then((value) {
            if (value != null) {
              setState(() {
                _title = value;
              });
              print('======$value');
            }
          });
        },
        onWebViewCreated: (controller) async {
          webViewController = controller;
        },
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          NavigationHandler.fwToFlutter(context, request.url);
          return NavigationDecision.prevent;
        },
      ),
    );
  }
}
