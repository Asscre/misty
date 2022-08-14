import 'misty.dart';

class MistyHandler extends LocalServerClientManager {
  factory MistyHandler() => _instance ??= MistyHandler._internal();
  static MistyHandler? _instance;
  MistyHandler._internal();

  void initSetting(MistyStartModel params) {
    init();
    LocalServerCacheBinderSetting().setBaseHost(params.baseHost);
    Map<String, Map<String, String>> baCache = {
      'common': {
        'compress': params.compress,
        'version': params.version,
      },
    };
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
      'option': [
        {
          'key': params.key,
          'open': params.open,
          'priority': params.priority,
          'version': params.version,
        },
      ],
      'assets': assets,
      'basics': baCache,
    });
    prepareManager(localServerClientConfig);
    startLocalServer();
  }
}
