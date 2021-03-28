import 'dart:io' show HttpServer, InternetAddress;

import 'package:httputil/httputil.dart' show HttpChain;
import 'package:jetlog/global_logger.dart' as log;

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 3000);

  final c1 = HttpChain([
    (h) => (req) {
          log.info('Calling handler No. 1');
          h(req
            ..response.headers.set('X-HANDLER-1', 1, preserveHeaderCase: true));
        },
    (h) => (req) {
          log.info('Calling handler No. 2');
          h(req
            ..response.headers.set('X-HANDLER-2', 1, preserveHeaderCase: true));
        },
    (h) => (req) {
          log.info('Calling handler No. 3');
          h(req
            ..response.headers.set('X-HANDLER-3', 1, preserveHeaderCase: true));
        },
  ]);

  final c2 = HttpChain([
    c1,
    (h) => (req) {
          log.info('Calling handler No. 4');
          h(req
            ..response.headers.set('X-HANDLER-4', 1, preserveHeaderCase: true));
        },
  ]);

  server.listen(c2.call((req) => req.response
    ..write('Hello world')
    ..close()));

  log.info('Running an HTTP server on http://localhost:3000/');
}
