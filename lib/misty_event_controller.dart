class MistyEventController {
  static MistyEventController? _instance;
  factory MistyEventController() => _instance ??= MistyEventController._();

  MistyEventController._();

  /// 所有的监听事件
  late Function _pushServeListener;

  /// 消息通知
  /// [message] 传递的参数
  void onEventMessage(dynamic event) {
    _pushServeListener.call(event);
  }

  /// 事件监听
  void addEventListener(Function listener) {
    _pushServeListener = listener;
  }

  /// 移除监听
  void removeEventListener(String eventName, Function? listener) {
    _pushServeListener = () {};
  }
}
