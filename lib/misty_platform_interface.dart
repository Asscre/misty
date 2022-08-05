import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'misty_method_channel.dart';

abstract class MistyPlatform extends PlatformInterface {
  /// Constructs a MistyPlatform.
  MistyPlatform() : super(token: _token);

  static final Object _token = Object();

  static MistyPlatform _instance = MethodChannelMisty();

  /// The default instance of [MistyPlatform] to use.
  ///
  /// Defaults to [MethodChannelMisty].
  static MistyPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MistyPlatform] when
  /// they register themselves.
  static set instance(MistyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
