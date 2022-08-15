abstract class LocalServerStatusHandler {
  /// server创建成功
  createServerSuccess(int port,String localAddress);
  /// server创建失败
  createServerFailure(dynamic err);
  /// server将要关闭
  serverWillCancel();
  /// server关闭
  serverDidCancel();
  /// server 请求失败
  requestServerFailure(String path,Object error);
  /// server 获取返回资源
  dynamic fetchRespondsSources(String path);
}