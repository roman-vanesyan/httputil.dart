import 'package:httputil/src/handler.dart';

// Check compliance of HttpChain with HttpMiddleware.
final HttpMiddleware _ = const HttpChain([]); // ignore: prefer_const_declarations

/// [HttpChain] is an [HttpMiddleware] that provides a convenient way to
/// chain HTTP middlewares.
///
/// Provided middlewares are applied as left-composition to the
/// target handler, e.g.
/// ```dart
/// final chain = HttpChain([m1, m2, m3]);
/// final handler = chain(h);
/// ```
/// is executed as `m1(m2(m3(h)))`, e.g. incoming request will be passed
/// in the following order: m1->m2->m3->h.
///
/// The [HttpChain] can be nested thus giving ability to composite
/// multiple middleware chains together.
/// ```dart
/// final c1 = HttpChain([m1, m2, m3]);
/// final c2 = HttpChain([c1, m4]);
/// final handler = c2(h); // m1->m2->m3->m4->h
/// ```
///
/// Note that middlewares are called on each [call], so several instances
/// of the middlewares may be created, as of this every passed middleware
/// should be side-effect free.
class HttpChain {
  const HttpChain(this._middlewares);

  final List<HttpMiddleware> _middlewares;

  /// Chains the middlewares and returns final request handler.
  HttpHandler call(HttpHandler handler) {
    final middlewares = _middlewares.reversed;
    var newHandler = handler;

    for (final m in middlewares) {
      newHandler = m(newHandler);
    }

    return newHandler;
  }
}
