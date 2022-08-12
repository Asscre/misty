import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:misty/misty_handler.dart';
import 'package:misty/tools/local_server_binder.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    return Scaffold(
      appBar: _appBarWidget(),
      body: SizedBox(
        child: AnimatedCrossFade(
          crossFadeState:
              pageIsOk ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _bodyWidget(),
          secondChild: _loadingWidget(),
          duration: const Duration(milliseconds: 100),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      leading: const SizedBox(),
      leadingWidth: 0,
      title: Row(
        children: [
          const SizedBox(width: 160),
          Expanded(
            child: Text(
              _title,
            ),
          ),
          _tabMakeWidget(),
        ],
      ),
    );
  }

  Widget _tabMakeWidget() {
    return Container(
      height: 32,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white38,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Container(
            height: 15,
            width: 1,
            color: Colors.white38,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.radio_button_checked,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

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
        },
        onWebViewCreated: (controller) async {
          webViewController = controller;
          webViewController!.getTitle().then((value) {
            setState(() {
              _title = value ?? '';
            });
          });
        },
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  /// First: Check local file is exist and file is need update?
  /// Is exist, get assets url md5 string to open misty;

  /// Is no exist, download file to local and open misty;

  /// Is need update, download file to local and open misty;

  /// Second: In first step, open loading view;

  /// Third: Listen for user interaction with WebView;
}
