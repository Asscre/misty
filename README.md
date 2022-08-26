# Misty - 一个Flutter web项目的本地缓存解决方案.

通过拦截浏览器网络请求，读取本地资源文件，减少网络资源请求来提高网页的开启速度，实现Flutter的原生手势交互的Flutter web preload解决方案。

Misty，如名所示，通过极小的引用实现 SPA web项目在Flutter上面享受到小程序般的体验。

## 使用

### 1. 导入(pubspec.yaml)
```
  dependencies:
    misty: <latest_version>
```
### 2. 启动本地web服务
```dart
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

  Misty.start(mistyStartOption);
```
### 3. 使用

#### 打开程序
```dart
  Misty.openMisty(context, url);
```

#### Flutter 调用 Js
```dart
    MistyHandler().callJs('欢迎使用Misty！');
```

> Js 挂载 事件
```javascript
    function flutterCallJs(param : any) {
        console.log(param);
    }
    
    window.flutterCallJs = flutterCallJs;
```

#### Js 调用 Flutter
```javascript
    window.MistyCallFlutter.postMessage('getDataFormFlutter');
```

```dart
    /// 监听来自Web的消息
    MistyEventController().addEventListener((event) {
      print(event);
    });
```

## 展示
![Screenrecorder-2022-08-24-16-51-42-559 mp4](https://user-images.githubusercontent.com/42698881/186375888-1ea2fafd-dbe7-4b13-b4c9-b2f61e49860e.gif)

Misty’s [官方demo](https://github.com/Asscre/misty-app") 帮助你快速了解如何集成属于你自己的Flutter小程序功能.

- web项目引用： [vite-vue3-template](https://github.com/Asscre/vite-vue3-template)
              [misty-app](https://github.com/Asscre/misty-app)

## 项目设计规划
- ✅ Web 资源管理器 (版本管理，资源下载管理)
- ✅ WebView 资源和网络代理
- ✅️ Flutter 与 Web 项目原生交互
- ☑️ Misty UI框架，帮助快速搭建 Misty 程序


## 持续更新
为了保证正常版本更新和迭代，😁更新迭代的规则如下：
- ⭕️  优先 版本开发 和 修复 BUG
- ⭕️  然后是 需求榜
- ⭕️  其次是 其他定制化

## 支持 Misty
> 如果觉得Misty帮助到您，请支持一杯☕️呗！

<img src="https://user-images.githubusercontent.com/42698881/186375976-b1010cd5-3134-4ca8-b2db-8bc92499718d.jpeg" width="200px">

## MIT License
