import 'dart:io' show HttpRequest, InternetAddress;

import 'package:jetlog/global_logger.dart' as log;
import 'package:httputil/helpers.dart' show ListenAndServeHttpHandler;

void handler(HttpRequest req) => req.response
  ..write('Hello world!')
  ..close();

Future<void> main() async {
  await handler.listenAndServe(InternetAddress.loopbackIPv4, port: 3000);

  log.info('Running an HTTP server on http://localhost:3000/');
}
