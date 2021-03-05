import 'dart:io' show HttpRequest, HttpStatus;

/// Responds to [req] with redirection to location.
///
/// Optional HTTP [status] code may be specified for redirect,
/// otherwise [HttpStatus.temporaryRedirect] (307) is used by default.
Future<void> redirect(HttpRequest req, Uri uri,
        [int status = HttpStatus.temporaryRedirect]) =>
    req.response.redirect(uri, status: status);
