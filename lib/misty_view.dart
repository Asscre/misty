import 'package:flutter/material.dart';

class MistyView extends StatefulWidget {
  const MistyView({Key? key, required this.assetsUrl}) : super(key: key);
  final String assetsUrl;

  @override
  State<MistyView> createState() => _MistyViewState();
}

class _MistyViewState extends State<MistyView> {
  /// resources are ready
  bool isAssetsReady = false;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  /// First: Check local file is exist and file is need update?
  /// Is exist, get assets url md5 string to open misty;

  /// Is no exist, download file to local and open misty;

  /// Is need update, download file to local and open misty;

  /// Second: In first step, open loading view;

  /// Third: Listen for user interaction with WebView;
}
