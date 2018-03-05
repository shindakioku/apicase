import 'package:apicase/apicase.dart';

import 'middleware.dart';

void handler(Request request) {
  print(request.responses.length); // 2
}

void main() {
  var request = new Request();

  request.validateStatus((status) => 200 == status).get('http://localhost');

  request
      .validateStatus((status) => 200 == status)
      .post('http://ip.jsontest.com')
      .then((r) => print('Body: ${r.body}'))
      .catchError((e) => print('Error: $e}'));

  request
      .middleware([new MiddlewareCommon()])
      .get('http://localhost')
      .then((_) => null)
      .catchError((e) => print('Error: ${e}')); // Error: Incorrect user name

  request
      .middleware([new MiddlewareWithException()])
      .get('http://localhost')
      .then((_) => null)
      .catchError((e) => print('Error: ${e}')); // Error: Bad state: Incorrect email

  request
      .middleware([new WorkingMiddleware()])
      .validateStatus((status) => status == 300)
      .get('http://localhost')
      .then((_) => null); // Bad state: Status code is not the same with 200. Url: http://localhost

  request
      .middleware([new WorkingMiddleware()])
      .validateStatus((status) => status == 200)
      .get('http://localhost')
      .then((Response r) => print('Body: ${r.body}'));

  request.fluent((Request r) => r.get('http://ip.jsontest.com'));
  request.fluent((Request r) => r.get('http://ip.jsontest.com'));

  request.makeClosure((List<Response> responses) => print(responses.length)); // 2

  request.fluent(
      (Request r) => r.validateStatus((status) => status == 300).get('http://ip.jsontest.com'));
  request.fluent((Request r) => r.get('http://localhost'));

  // Bad state: Status code is not the same with 200. Url: http://ip.jsontest.com.
  request.makeClosure((List<Response> responses) => print(responses.length));

  request
      .fluent((Request r) => r.middleware([new WorkingMiddleware()]).get('http://ip.jsontest.com'));
  request.fluent((Request r) => r.get('http://ip.jsontest.com'));

  request.makeClosure((List<Response> responses) => print(responses.length)); // 2

  request.fluent((Request r) => r
      .middleware([new WorkingMiddleware(), new MiddlewareCommon()]).get('http://ip.jsontest.com'));
  request.fluent((Request r) => r.get('http://ip.jsontest.com'));

  // Error: Incorrect user name
  request.makeClosure((_) => null).catchError((e) => print('Error: ${e}'));

  request.fluent((Request r) => r.get('http://ip.jsontest.com'));
  request.fluent((Request r) => r.get('http://ip.jsontest.com'));

  request.make(handler); // print - 2

  request.fluent(
      (Request r) => r.validateStatus((status) => status == 300).get('http://ip.jsontest.com'));
  request.fluent((Request r) => r.get('http://ip.jsontest.com'));

  // Bad state: Status code is not the same with 200. Url: http://ip.jsontest.com.
  request.make(handler).catchError((e) => print(e));

  request.fluent((Request r) => r.get('http://ip.jsontest.com'));
  request.fluent((Request r) => r.get('http://ip.jsontest.com'));
  request.middleware([new MiddlewareWithException(), new WorkingMiddleware()]);

  request.makeClosure((_) => null).catchError((e) => print(e)); // Bad state: Incorrect email
}
