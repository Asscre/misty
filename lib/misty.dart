import 'package:flutter/material.dart';
import 'package:misty/misty_view.dart';

import 'misty_platform_interface.dart';

class Misty {
  Future<String?> getPlatformVersion() {
    return MistyPlatform.instance.getPlatformVersion();
  }

  /// open misty app
  void openMisty(BuildContext context, String assetsUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MistyView(assetsUrl: assetsUrl)),
    );
  }
}
