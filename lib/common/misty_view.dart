import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:misty/misty_event_controller.dart';
import 'package:misty/misty_handler.dart';
import 'package:misty/model/misty_view_model.dart';
import 'package:misty/navigation/navigation_handler.dart';
import 'package:misty/tools/local_server_binder.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'basis_scaffold.dart';

class MistyView extends StatefulWidget {
  const MistyView({Key? key, required this.params}) : super(key: key);
  final MistyViewModel params;

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
  GlobalKey webKey = GlobalKey();

  /// 开始加载时间
  late int startTime;

  JavascriptChannel _javascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'MistyCallFlutter',
      onMessageReceived: (JavascriptMessage msg) {
        MistyEventController().onEventMessage(msg.message);
      },
    );
  }

  @override
  void initState() {
    log('页面开始加载：${DateTime.now()}', name: 'web-time');
    startTime = DateTime.now().millisecondsSinceEpoch;
    _localServerBuilder = LocalServerCacheBinder()..initBinder();
    MistyHandler().registerBuilder(_localServerBuilder);
    _innerUrl =
        _localServerBuilder.convertH5Url2LocalServerUrl(widget.params.url);
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
      mistyViewParams: widget.params,
      body: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    return widget.params.logo == null
        ? _viewWidget()
        : AnimatedCrossFade(
            firstChild: _logoWidget(),
            secondChild: _viewWidget(),
            alignment: Alignment.center,
            crossFadeState:
                pageIsOk ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(
              milliseconds: 150,
            ),
          );
  }

  Widget _logoWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: widget.params.logo,
    );
  }

  Widget _viewWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: WebView(
        key: webKey,
        initialUrl: _innerUrl,
        debuggingEnabled: false,
        zoomEnabled: false,
        onPageStarted: (url) {
          log("onPageStarted($url) ----------------------");
          log('Web开始加载：${DateTime.now()}', name: 'web-time');
        },
        onPageFinished: (url) {
          log("onPageFinished($url) ----------------------");
          log('Web加载完成：${DateTime.now()}', name: 'web-time');
          int endTime = DateTime.now().millisecondsSinceEpoch;
          int c = endTime - startTime;

          /// 当设置logo时，延迟展示
          if (widget.params.logo != null && c < 2000) {
            Future.delayed(Duration(milliseconds: c), () {
              setState(() {
                pageIsOk = true;
              });
            });
          } else {
            setState(() {
              pageIsOk = true;
            });
          }

          webViewController!.getTitle().then((value) {
            if (value != null && _title != value) {
              setState(() {
                _title = value;
              });
            }
          });
        },
        onWebViewCreated: (controller) async {
          MistyHandler().setWebViewController(controller);
          webViewController = controller;
        },
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          NavigationHandler.fwToFlutter(context, request.url);
          return NavigationDecision.navigate;
        },
        javascriptChannels: <JavascriptChannel>{
          _javascriptChannel(context),
        },
      ),
    );
  }
}
