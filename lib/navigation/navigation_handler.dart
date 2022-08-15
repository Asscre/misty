import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:misty/common/basis_scaffold.dart';
import 'package:misty/navigation/navigation_scheme.dart';

class NavigationHandler {
  static fwToFlutter(BuildContext context, String scheme) {
    log(scheme);
    if (scheme.startsWith(NavigationScheme.openPage)) {
      _openPage(context, scheme);
    } else if (scheme.startsWith(NavigationScheme.openPage)) {
      _openDialog(context, scheme);
    }
  }

  static _openPage(BuildContext context, String scheme) {
    print(scheme);
    // Misty.openMisty(
    //   context,
    //   'https://mistyapp.oss-cn-hangzhou.aliyuncs.com/misty-app-one/index.html',
    // );
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const BasisScaffold(
          body: Text('openPage'),
        ),
      ),
    );
  }

  static _openDialog(BuildContext context, String scheme) {
    print(scheme);
  }
}
