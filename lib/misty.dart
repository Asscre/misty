library misty;

import 'package:flutter/material.dart';
import 'package:misty/misty_handler.dart';
import 'package:misty/misty_view.dart';
import 'package:misty/src/model/misty_start_model.dart';

export 'package:misty/src/model/download_service_item.dart';
export 'package:misty/src/model/download_service_total_asset_item.dart';
export 'package:misty/src/model/local_server_client_config.dart';
export 'package:misty/src/model/local_server_client_config_item.dart';
export 'package:misty/src/model/misty_start_model.dart';
export 'package:misty/src/services/local_server_configuration.dart';
export 'package:misty/src/services/local_server_service.dart';
export 'package:misty/tools/local_server_binder.dart';
export 'package:misty/tools/local_server_config_cache.dart';
export 'package:misty/tools/local_server_downloader.dart';
export 'package:misty/tools/local_server_manager.dart';
export 'package:misty/tools/local_server_status_handler.dart';

class Misty {
  /// Misty start in Flutter init
  static void start(MistyStartModel params) {
    MistyHandler().initSetting(params);
  }

  /// open misty app
  void openMisty(BuildContext context, String assetsUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MistyView(assetsUrl: assetsUrl);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(0.0, 1.0);
          const Offset end = Offset.zero;
          const Curve curve = Curves.ease;

          Animatable<Offset> tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
