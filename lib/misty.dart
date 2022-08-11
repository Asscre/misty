library misty;

import 'package:flutter/material.dart';
import 'package:misty/misty_view.dart';

import 'misty_platform_interface.dart';

export 'package:misty/src/model/download_service_item.dart';
export 'package:misty/src/model/download_service_total_asset_item.dart';
export 'package:misty/src/model/local_server_client_config.dart';
export 'package:misty/src/model/local_server_client_config_item.dart';
export 'package:misty/src/services/local_server_configuration.dart';
export 'package:misty/src/services/local_server_service.dart';
export 'package:misty/tools/local_server_binder.dart';
export 'package:misty/tools/local_server_config_cache.dart';
export 'package:misty/tools/local_server_downloader.dart';
export 'package:misty/tools/local_server_manager.dart';
export 'package:misty/tools/local_server_status_handler.dart';

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
