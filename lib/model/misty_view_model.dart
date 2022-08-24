import 'package:flutter/material.dart';

class MistyViewModel {
  /// 打开程序地址
  String url;

  /// 是否显示bar
  bool showBar;

  /// 是否显示标题
  bool showTitle;

  /// 标题名称，默认为App title
  String? title;

  /// 是否显示更多按钮
  bool? showMoreBtn;

  /// 更多按钮事件
  Function? moreFunc;

  /// 关闭按钮回调
  Function? closeFunc;

  /// 底部导航Widget，默认为null，不显示
  Widget? bottomNav;

  MistyViewModel({
    required this.url,
    this.showBar = true,
    this.showTitle = true,
    this.title,
    this.showMoreBtn,
    this.moreFunc,
    this.closeFunc,
    this.bottomNav,
  });
}
