import 'package:flutter/material.dart';
import 'package:misty/model/misty_view_model.dart';

class BasisScaffold extends StatelessWidget {
  const BasisScaffold({
    Key? key,
    required this.title,
    required this.mistyViewParams,
    required this.body,
  }) : super(key: key);
  final String title;
  final MistyViewModel mistyViewParams;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mistyViewParams.showBar ? _appBarWidget(context) : null,
      body: body,
      bottomNavigationBar: mistyViewParams.bottomNav,
    );
  }

  PreferredSizeWidget? _appBarWidget(BuildContext context) {
    return mistyViewParams.showBar
        ? AppBar(
            backgroundColor: Colors.blue,
            elevation: 0,
            leading: const SizedBox(),
            title: Text(
              mistyViewParams.showTitle ? mistyViewParams.title ?? title : '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              _tabMakeWidget(context),
              const SizedBox(width: 12),
            ],
          )
        : null;
  }

  Widget _tabMakeWidget(BuildContext context) {
    return Center(
      child: Container(
        height: 32,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _moreWidget(),
            mistyViewParams.showMoreBtn
                ? Container(
                    height: 15,
                    width: 1,
                    color: Colors.white38,
                  )
                : const SizedBox(),
            _closePage(context),
          ],
        ),
      ),
    );
  }

  Widget _moreWidget() {
    return mistyViewParams.showMoreBtn
        ? GestureDetector(
            onTap: () {
              mistyViewParams.moreFunc?.call();
            },
            child: Container(
              width: 38,
              height: 38,
              color: Colors.transparent,
              child: const Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: 24,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _closePage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 返回到首页
        mistyViewParams.closeFunc?.call();
        Navigator.pop(context);
      },
      child: Container(
        width: 38,
        height: 38,
        color: Colors.transparent,
        child: const Icon(
          Icons.radio_button_checked,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
