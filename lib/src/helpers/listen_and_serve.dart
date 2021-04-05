import 'dart:io' show HttpServer, SecurityContext;
import 'dart:isolate' show Isolate;

import 'package:httputil/httputil.dart' show HttpHandler;

class _ServerOptions {
  const _ServerOptions(
      this.address, this.port, this.securityContext, this.shared, this.handler);

  final dynamic address;
  final int port;
  final SecurityContext? securityContext;
  final bool shared;
  final HttpHandler handler;
}

Future<HttpServer> _listenAndServe(_ServerOptions options) async {
  final server = options.securityContext != null
      ? await HttpServer.bindSecure(
          options.address, options.port, options.securityContext!,
          shared: options.shared)
      : await HttpServer.bind(options.address, options.port,
          shared: options.shared);

  server.listen(options.handler);

  return server;
}

/// [ListenAndServeHttpHandler] adds functionality to run HTTP server
/// right from the [HttpHandler].
extension ListenAndServeHttpHandler on HttpHandler {
  /// [listenAndServe] starts an HTTP server bind to [addr]:[port] address
  /// and calls the handler on each incoming request.
  ///
  /// If [securityContext] is provided an HTTP over TLS server will
  /// be established.
  ///
  /// Optional [concurrency] parameter can be passed to enable multi-threading
  /// with isolates. `concurrency-1` of additional isolates will be created and
  /// the underlying HTTP server is shared across them.
  ///
  /// Returned callback can be called to cancel the instantiated TCP
  /// network subscription.
  Future<Future<void> Function({bool force})> listenAndServe(
      dynamic /* InternetAddress | string */ address,
      {int port = 8080,
      SecurityContext? securityContext,
      int concurrency = 1}) async {
    ArgumentError.value(concurrency >= 1, 'concurrency');

    final options =
        _ServerOptions(address, port, securityContext, concurrency > 0, this);
    final server = await _listenAndServe(options);

    Iterable<Isolate>? isolates;
    if (concurrency > 1) {
      isolates = await Future.wait(List.generate(
          concurrency - 1, (_) => Isolate.spawn(_listenAndServe, options),
          growable: false));
    }

    return ({bool force = false}) {
      // Kill spawned isolates.
      isolates?.map((isolate) => isolate.kill());
      return server.close(force: force);
    };
  }
}
