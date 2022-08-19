import 'misty.dart';

class MistyHandler extends LocalServerClientManager {
  factory MistyHandler() => _instance ??= MistyHandler._internal();
  static MistyHandler? _instance;
  MistyHandler._internal();

  void initSetting(MistyStartModel params) {
    init();
    LocalServerCacheBinderSetting().setBaseHost(params.baseHost);
    Map<String, dynamic> assets = {};
    params.assets
        .map(
      (e) => {
        e.keys.first: {'compress': e.values.first},
      },
    )
        .forEach((j) {
      assets.addAll(j);
    });
    LocalServerClientConfig localServerClientConfig =
        LocalServerClientConfig.fromJson({
      'option': params.options.map((e) => e.toJson()).toList(),
      'assets': assets,
      'basics': params.basics.toJson(),
    });
    prepareManager(localServerClientConfig);
    startLocalServer();
  }
}
