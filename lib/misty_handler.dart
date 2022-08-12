import 'package:misty/src/model/misty_start_model.dart';

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
      'assets': {
        params.key: {
          'compress': params.compress,
        },
      },
      'basics': baCache,
    });
    prepareManager(localServerClientConfig);
    startLocalServer();
  }
}
