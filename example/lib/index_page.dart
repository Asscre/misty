import 'package:flutter/material.dart';
import 'package:misty/misty.dart';
import 'package:misty/misty_handler.dart';
import 'package:misty/model/misty_view_model.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  void initState() {
    /// 监听来自Web的消息
    MistyEventController().addEventListener((event) {
      if (event == 'getDataFormFlutter') {
        _getDataFormFlutter();
      } else {
        _openDialog(event);
      }
    });
    super.initState();
  }

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
            _openMistyView(
              context,
              'https://mistyapp.oss-cn-hangzhou.aliyuncs.com/misty-app-three/index.html#/article/12',
              '打开小程序three',
            ),
            // SizedBox(
            //   height: 300,
            //   width: MediaQuery.of(context).size.width,
            //   child: const WebView(
            //     initialUrl: 'www.baidu.com',
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _openMistyView(BuildContext context, String url, String name) {
    return ElevatedButton(
      onPressed: () => Misty.openMisty(
        context,
        MistyViewModel(
          url: url,
          showBar: true,
          showTitle: true,
          moreFunc: () {
            print('more Function');
          },
          closeFunc: () {
            print('close Function');
          },
          // logo: Container(
          //   height: 110,
          //   width: 110,
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(90),
          //     boxShadow: const [
          //       BoxShadow(
          //         color: Colors.black12,
          //         blurRadius: 0.1,
          //         spreadRadius: 0.2,
          //         offset: Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: const Text(
          //     'Misty',
          //     style: TextStyle(
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
        ),
      ),
      child: Text(name),
    );
  }

  void _openDialog(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(msg),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确认'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _getDataFormFlutter() {
    MistyHandler().callJs('欢迎使用Misty！${DateTime.now().toLocal()}');
  }
}
