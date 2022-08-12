import 'package:flutter_test/flutter_test.dart';
import 'package:misty/misty_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMistyPlatform
    with MockPlatformInterfaceMixin
    implements MistyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  // final MistyPlatform initialPlatform = MistyPlatform.instance;
  //
  // test('$MethodChannelMisty is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelMisty>());
  // });
  //
  // test('getPlatformVersion', () async {
  //   Misty mistyPlugin = Misty();
  //   MockMistyPlatform fakePlatform = MockMistyPlatform();
  //   MistyPlatform.instance = fakePlatform;
  //
  //   expect(await mistyPlugin.getPlatformVersion(), '42');
  // });
}
