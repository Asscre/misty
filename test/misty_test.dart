import 'package:flutter_test/flutter_test.dart';
import 'package:misty/services/local_server_service.dart';

void main() {
  test(
      'start local server',
      () => () async {
            var server = await LocalServerService().startServer('127.0.0.1', 0);
            String res = LocalServerService()
                .getLocalServerWebUrl('', '/test/index.html');
            expect(res, 'http://127.0.0.1:${server.port}/test/index.html');
          });

  test('close local server', () {
    LocalServerService().closeServer();
  });
}
