import 'package:flutter/material.dart';
import 'package:misty/misty.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Misty.start(
      MistyStartModel(
        compress: '/local-server/common.zip',
        version: '20220503',
        key: 'test-one',
        baseHost: 'https://jomin-web.web.app',
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Misty app'),
            centerTitle: true,
          ),
          body: Center(
            child: _openMistyView(context),
          ),
        );
      }),
    );
  }

  Widget _openMistyView(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Misty().openMisty(
        context,
        'https://jomin-web.web.app/test-one/index.html',
      ),
      child: const Text('打开小程序'),
    );
  }
}
