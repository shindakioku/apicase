import 'request.dart';
import 'package:http/src/response.dart';

class MiddlewareException extends StateError {
  MiddlewareException(String msg) : super(msg);
}

abstract class Middleware {
  bool execute(Request request, Response response);

  String error(Response response);
}
