import 'dart:io' show HttpServer, HttpClient, InternetAddress;
import 'package:httputil/httputil.dart' show HttpHandler;
import 'package:httputil/helpers.dart' show redirect;
import 'package:test/test.dart';

class Test {
  Test(this.handler);

  final HttpHandler handler;

  Future<void> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0)
      ..listen(handler);
    final client = HttpClient();
    final response =
        await (await client.open('GET', server.address.host, server.port, '/')
              ..followRedirects = false)
            .close();

    expect(response.isRedirect, isTrue);
  }
}

void main() {
  group('redirect', () {
    test('it should redirect', () async {
      await Test((req) async {
        if (req.uri.path == '/') {
          return await redirect(
              req, Uri.parse('${req.requestedUri.origin}/domain'));
        }

        return (req.response..write('hello world')).close();
      }).start();
    });
  });
}
