import 'package:apicase/apicase.dart';

import 'dart:async';

import 'middleware.dart';

void main() {
  var client = new Client();

  client.make((Request r) => r.get('http://ip.jsontest.com'), 'get_ip');
  client.makeRequest('get_ip').then((Response r) => print(r.body)); // Body

  client.make(
      (Request r) => r.validateStatus((status) => 300 == status).get('http://ip.jsontest.com'),
      'get_ip_error');

  // Bad state: Status code is not the same with 200. Url: http://ip.jsontest.com.
  client.makeRequest('get_ip_error').catchError((e) => print(e));

  client.make((Request r) => r.get('http://ip.jsontest.com'), 'get_ip');
  client.make((Request r) => r.get('https://jsonplaceholder.typicode.com/posts/1'), 'get_posts');

  client.makeRequests(['get_i', 'get_posts']).then((List<Future<Response>> responses) async {
    Response first = await responses.first.then((s) => s);
    Response second = await responses[1].then((s) => s);

    print(first.body); // Ip
    print(second.body); // Posts
  });

  client.make((Request r) => r.get('http://ip.jsontest.com'), 'get_ip');
  client.make(
      (Request r) => r
          .middleware([new MiddlewareCommon()]).get('https://jsonplaceholder.typicode.com/posts/1'),
      'get_posts');

  client.makeRequests(['get_ip', 'get_posts']).then((List<Future<Response>> responses) async {
    responses[0].catchError((e) => print(e)); // Bad state: Incorrect email
    responses[1].catchError((e) => print(e)); // Bad state: Incorrect email
  });
}
