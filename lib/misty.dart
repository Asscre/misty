
import 'misty_platform_interface.dart';

class Misty {
  Future<String?> getPlatformVersion() {
    return MistyPlatform.instance.getPlatformVersion();
  }
}
