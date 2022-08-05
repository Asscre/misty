import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misty/misty_method_channel.dart';

void main() {
  MethodChannelMisty platform = MethodChannelMisty();
  const MethodChannel channel = MethodChannel('misty');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
