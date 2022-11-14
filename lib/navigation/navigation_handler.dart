import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:misty/misty.dart';
import 'package:misty/navigation/navigation_scheme.dart';

class NavigationHandler {
  static fwToFlutter(BuildContext context, String scheme) {
    log(scheme);
    FWParamModel data = FWParamModel.toJson(scheme);
    switch (data.scheme) {
      case NavigationScheme.openPage:
        _openPage(context, data);
        break;
      case NavigationScheme.openDialog:
        _openDialog(context, data);
        break;
      case NavigationScheme.openMistyPage:
        _openMistyPage(context, data);
        break;
    }
  }

  static _openPage(BuildContext context, FWParamModel param) {
    String txt = param.params.toString();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Scaffold(
          body: Text(txt),
        ),
      ),
    );
  }

  static _openDialog(BuildContext context, FWParamModel param) {}

  static _openMistyPage(BuildContext context, FWParamModel param) {
    Misty.openMisty(context, param.params!['url']);
  }
}

class FWParamModel {
  late String scheme;
  Map<String, dynamic>? params;

  FWParamModel({this.scheme = '', this.params});

  FWParamModel.toJson(String schemeStr) {
    print(schemeStr);
    int schemeIdx = schemeStr.indexOf('?');
    if (schemeIdx == -1) {
      scheme = schemeStr;
    } else {
      params = {};
      scheme = schemeStr.substring(0, schemeIdx);
      List<String> p =
          schemeStr.substring(schemeIdx + 1, schemeStr.length).split('&');
      print(scheme);
      print(p);
      print(p.runtimeType);
      for (String j in p) {
        List<String> d = j.split('=');
        params?.addAll({d[0]: d[1]});
      }
    }
  }
}
