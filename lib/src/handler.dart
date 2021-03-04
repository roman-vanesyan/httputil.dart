import 'dart:async' show FutureOr;
import 'dart:io' show HttpRequest;

/// An [HttpHandler] is capable to handle an incoming HTTP request.
///
/// It can receive either "untouched" request, or request that has been
/// proceed by middlewares.
///
/// As [HttpHandler] receives an [HttpRequest] object from the Dart standard
/// library the lifetime of the request/response objects must be handled
/// manually.
///
/// Example:
/// ```dart
/// final HttpHandler handler = (req) {
///   req.response..write('Hello world!')..close();
/// };
/// ```
typedef HttpHandler = FutureOr<void> Function(HttpRequest);

/// An [HttpMiddleware] is function that allows to inject custom functionality
/// to the given [HttpHandler], by wrapping it with a new one.
///
/// It can intercept incoming request and process it before passing
/// it down to the [handler].
///
/// Example
/// ```dart
/// final HttpMiddleware middleware = (HttpHandler next) {
///   return (req) {
///     req.headers.add('X-HELLO-WORLD', '1');
///     next(req);
///   };
/// };
/// ```
///
/// Middleware can finalize response to incoming request earlier without
/// passing it down to [handler] as wrapping handler receives plain
/// [HttpRequest] object.
///
/// Example
/// ```dart
/// final HttpMiddleware authMiddleware = (HttpHandler next) {
///   return (req) {
///     final token = getToken(req.headers.value('Authorization'));
///     if (!isAuthenticated(token)) {
///       req.response
///         ..statusCode = HttpStatus.forbidden
///         ..contentLength = 0
///         ..close();
///
///         return;
///     }
///
///     next(req);
///   };
/// };
/// ```
typedef HttpMiddleware = HttpHandler Function(HttpHandler handler);
