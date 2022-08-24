library misty;

import 'package:flutter/material.dart';
import 'package:misty/misty_handler.dart';

import 'common/misty_view.dart';
import 'model/misty_start_model.dart';
import 'model/misty_view_model.dart';

export 'package:misty/misty_event_controller.dart';
export 'package:misty/model/misty_start_model.dart';

class Misty {
  /// Misty start in Flutter init
  static void start(MistyStartModel params) {
    MistyHandler().initSetting(params);
  }

  /// open misty app
  static void openMisty(BuildContext context, MistyViewModel params) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MistyView(params: params);
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
