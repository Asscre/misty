import 'package:flutter/material.dart';
import 'package:misty/misty.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Misty app'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _openMistyView(
              context,
              'https://mistyapp.oss-cn-hangzhou.aliyuncs.com/misty-app-one/index.html',
              '打开小程序one',
            ),
            _openMistyView(
              context,
              'https://mistyapp.oss-cn-hangzhou.aliyuncs.com/misty-app-two/index.html',
              '打开小程序two',
            ),
          ],
        ),
      ),
    );
  }

  Widget _openMistyView(BuildContext context, String url, String name) {
    return ElevatedButton(
      onPressed: () => Misty.openMisty(
        context,
        url,
      ),
      child: Text(name),
    );
  }
}
