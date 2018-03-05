import 'package:apicase/apicase.dart';

import 'dart:convert' show JSON;

class UserException extends StateError {
  UserException(String msg) : super(msg);
}

class MiddlewareCommon extends Middleware {
  @override
  bool execute(Request request, Response response) {
    if (null == JSON.decode(response.body)['user']) {
      return false;
    }

    return true;
  }

  @override
  String error(Response response) {
    return 'Incorrect user name';
  }
}

class MiddlewareWithException extends Middleware {
  @override
  bool execute(Request request, Response response) {
    if (null == JSON.decode(response.body)['user']) {
      throw new UserException('Incorrect email');
    }

    return true;
  }

  @override
  String error(Response response) {
    // Empty, because execute throw is exception
    return '';
  }
}

class WorkingMiddleware extends Middleware {
  @override
  bool execute(Request request, Response response) {
    return true;
  }

  @override
  String error(Response response) {
    return '';
  }
}
