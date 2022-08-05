import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'misty_platform_interface.dart';

/// An implementation of [MistyPlatform] that uses method channels.
class MethodChannelMisty extends MistyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('misty');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
