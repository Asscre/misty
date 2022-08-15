import 'package:flutter/material.dart';

class BasisScaffold extends StatelessWidget {
  const BasisScaffold({Key? key, this.title, this.leading, this.body})
      : super(key: key);
  final String? title;
  final Widget? leading;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(context),
      body: body,
    );
  }

  PreferredSizeWidget _appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      leading: leading ?? const BackButton(),
      title: Text(
        title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      actions: [
        _tabMakeWidget(context),
        const SizedBox(width: 12),
      ],
    );
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
            _closePage(context),
          ],
        ),
      ),
    );
  }

  Widget _closePage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 返回到首页
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const SizedBox(),
          ),
          (route) => route.isFirst,
        );
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
