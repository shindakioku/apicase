import 'package:apicase/apicase.dart';
import 'package:test/test.dart';

import 'dart:convert';

void main() {
  group('A group of tests', () {
    Client client;
    var serverUrl;

    setUp(() async {
      client = new Client();
      var channel = spawnHybridUri('hybrid/server.dart');
      serverUrl = Uri.parse(await channel.stream.first);
    });

    test('Make one request', () async {
      var response;
      client.make((Request r) => r.get(serverUrl), 'index');

      await client.makeRequest('index').then((r) {
        response = r;
      });

      expect(response, isNotNull);
    });

    test('Make one request with validateStatus', () async {
      var response;
      client.make(
          (Request r) => r.validateStatus((status) => status == 200).get(serverUrl), 'index');

      await client.makeRequest('index').then((r) {
        response = r;
      });

      expect(response, isNotNull);
    });

    test('Make request exception', () async {
      client.make((Request r) => r.get(serverUrl), 'index');

      try {
        await client.makeRequest('index1').then((_) => 1);
      } on NameIsNotFound catch (e) {
        expect(e.toString(), 'Bad state: Incorrect name index1');
      }
    });

    test('Make many requests', () async {
      client.make((Request r) => r.get(serverUrl, headers: {'SomeHeader': 'Value'}), 'index');
      client.make(
          (Request r) => r.post(serverUrl.toString() + '/index1', body: 'Again value'), 'index1');
      List<Response> responses = [];

      await client.makeRequests(['index', 'index1']).then((res) async {
        for (var k in res) {
          responses.add(await k.then((a) => a));
        }
      });

      expect(responses.length, equals(2));
      expect(JSON.decode(responses.first.body)['headers']['someheader'], equals('Value'));
      expect(JSON.decode(responses[1].body)['body'], equals('Again value'));
    });

    test('Make many requests exception', () async {
      try {
        await client.makeRequests(['index', 'index1']).then((_) => 2);
      } on UrlsIsEmpty catch(e) {
        expect(e.toString(), 'Bad state: Urls cannot be empty');
      }
    });

    test('Make many requests and clean urls', () async {
      client.make((Request r) => r.get(serverUrl, headers: {'SomeHeader': 'Value'}), 'index');
      client.make(
              (Request r) => r.post(serverUrl.toString() + '/index1', body: 'Again value'), 'index1');
      List<Response> responses = [];

      await client.makeRequests(['index', 'index1']).then((res) async {
        for (var k in res) {
          responses.add(await k.then((a) => a));
        }
      });

      expect(responses.length, equals(2));
      expect(JSON.decode(responses.first.body)['headers']['someheader'], equals('Value'));
      expect(JSON.decode(responses[1].body)['body'], equals('Again value'));
      expect(client.urls.length, equals(2));

      client.cleanUrls();

      expect(client.urls, isEmpty);
    });
  });
}
