import 'package:flutter/material.dart';
import 'package:misty/misty.dart';
import 'package:misty_example/index_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MistyStartModel mistyStartOption = MistyStartModel(
    baseHost: 'https://mistyapp.oss-cn-hangzhou.aliyuncs.com',
    options: [
      Option(
        key: 'misty-app-one',
        open: 1,
        priority: 0,
        version: '202208161155',
      ),
      Option(
        key: 'misty-app-two',
        open: 1,
        priority: 0,
        version: '202208151527',
      ),
    ],
    basics: Basics(
      common: Common(
        compress: '/common.zip',
        version: '202208151527',
      ),
    ),
    assets: [
      {
        'misty-app-one': '/misty-app-one/misty-app.zip',
      },
      {
        'misty-app-two': '/misty-app-two/misty-app.zip',
      },
    ],
  );

  @override
  void initState() {
    Misty.start(mistyStartOption);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return const IndexPage();
      }),
    );
  }
}
