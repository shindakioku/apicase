import 'package:apicase/apicase.dart';

class MiddlewareWithoutError extends Middleware {
  bool execute(Request request, Response response) {
    return true;
  }

  String error(Response response) {
    return 'Error from Middleware1 middleware';
  }
}

class MiddlewareWithStringError extends Middleware {
  bool execute(Request request, Response response) {
    return false;
  }

  String error(Response response) {
    return 'Middleware with string error, bzzz...';
  }
}

class MiddlewareWithException extends Middleware {
  bool execute(Request request, Response response) {
    throw new MiddlewareException('Exception by MiddlewareException from apicase');

    return false;
  }

  String error(Response response) {
    return 'Middleware with string error, bzzz...';
  }
}
