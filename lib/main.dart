import 'apicase.dart';

import 'dart:async';

void main() async {
  var request = new Request();

//  await request
//      .fluent((Request r) => r.get('http://ip.jsontest.com'))
//      .fluent((Request r) => r.get('https://jsonplaceholder.typicode.com/posts/1'))
//      .makeClosure((List<Response> responses) => test = responses.first);
//
//      .make(test);

//    request
//      .validateStatus((request) => request == 500)
//      .get('http://ip.jsontest.com')
//      .then((r) => print('response: ${r}'))
//      .catchError((e) => print('error: ${e}'));

  //  http.validateStatus((status) => status < 500).get('/url', headers: {'userId': 1}).then();
//
//  http.post('/url', params: {}).then();
//
//  http.put('/url');
//
//  var resource = new Resource('http://site.ru/user');
//  // name: index, method: get, action: null,
//
//  /*
//    basic  - name: index, method: get
//    name: create, method: post, action: null
//   */
//
//  resource.settings(
//      name: 'index', newName: 'someName', method: 'POST', action: new ResourceController());
//
//  resource.settings(name: 'create', method: 'POST', action: new ResourceController());
//
//  resource.settings(name: 'update', url: '/someurl');
//
//  resource.request('index').then((res) => print(res));
//
//  resource.validateStatus((status) => status < 500).request('index'); // new ResourceController()
//  // .index(Response)
//
//  resource.request('index', method: 'POST');
//
//  resource.requestMany(['index', 'update']).then((resIndex, resUpdate) => {});
//
//  var client = new Client(basePath: 'http://site.ru');
//  client.make(url: '/some-url', method: 'GET', callback: (res) => print(res));
//  client.make(url: '/some-url', method: 'GET', handler: new SomeController(), action: 'someMethod');
//
//  client
//      .makeGet(
//          name: 'nameOfRequest',
//          url: '/some-url1',
//          handler: new SomeController(),
//          action: 'someMethod')
//      .makePut(url: '/some-url2', method: 'PUT', callback: (res) => _handler(res));
//
//  client.request(name: 'nameOfRequest');
//  client.request(url: '/some-url');
}
