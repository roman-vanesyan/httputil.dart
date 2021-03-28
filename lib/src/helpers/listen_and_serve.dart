import 'dart:io' show HttpServer, SecurityContext;

import 'package:httputil/httputil.dart' show HttpHandler;

/// [ListenAndServeHttpHandler] adds functionality to run HTTP server
/// right from the [HttpHandler].
extension ListenAndServeHttpHandler on HttpHandler {
  /// [listenAndServe] starts an HTTP server bind to [addr]:[port] address
  /// and calls the handler on each incoming request.
  ///
  /// If [securityContext] is provided an HTTP over TLS server will
  /// be established.
  ///
  /// Returned callback can be called to cancel the instantiated TCP
  /// network subscription.
  Future<void Function({bool force})> listenAndServe(
      dynamic /* InternetAddress | string */ address,
      {int port = 8080,
      SecurityContext? securityContext}) async {
    final server = securityContext != null
        ? await HttpServer.bindSecure(address, port, securityContext)
        : await HttpServer.bind(address, port);

    server.listen(this);
    return server.close;
  }
}
