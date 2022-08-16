# Misty - 一个Flutter web项目的本地缓存解决方案.

通过拦截浏览器网络请求，读取本地资源文件，减少网络资源请求来提高网页的开启速度，实现Flutter的原生手势交互的Flutter web preload解决方案。

Misty，如名所示，通过极小的引用实现web项目在Flutter上面享受到小程序的体验。

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
```dart
  Misty.openMisty(context, url);
```

## 展示
![Screenrecorder-2022-08-16-14-44-36-552 mp4](https://user-images.githubusercontent.com/42698881/184816047-2647762e-2389-4b61-963a-ab40190771b4.gif)

 - web项目引用： [vite-vue3-template](https://github.com/Asscre/vite-vue3-template)
               [misty-app](https://github.com/Asscre/misty-app)

## 项目设计规划

- [X] Web assets manager (Version manager, Assets download handle)
- [] WebView assets and web proxy (Assets local server)
- [] Gesture interaction
- [] Miniapp UI

## MIT License

Copyright (c) 2022 Asscre

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
