import 'package:apicase/apicase.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  group('A group of tests', () {
    Request request;
    var serverUrl;

    setUp(() async {
      request = new Request();
      var channel = spawnHybridUri('hybrid/server.dart');
      serverUrl = Uri.parse(await channel.stream.first);
    });

    test('Responses must be is empty', () {
      expect(request.responses, isEmpty);
    });

    test('Testing fluent with makeClosure, and one request', () async {
      Response response;
      await request.fluent((r) => r.get(serverUrl)).makeClosure((List<Response> responses) async {
        response = await responses.first;
      });

      expect(response.statusCode, equals(200));
    });

    test('Testing fluent with makeClosure, and two requests', () async {
      List<Response> responses;

      await request
          .fluent((r) => r.get(serverUrl))
          .fluent((r) => r.post(serverUrl.toString() + '/two_requests', body: 'request body'))
          .makeClosure((List<Response> r) async {
        responses = await r;
      });

      expect(responses.length, equals(2));

      expect(responses.first.statusCode, equals(200));
      expect(JSON.decode(responses.first.body)['body'], equals(null));

      expect(JSON.decode(responses[1].body)['body'], equals('request body'));
      expect(responses[1].statusCode, equals(200));
    });

    test('Testing fluent with make, and one request', () async {
      void handler(Request r) {
        expect(r.responses, isNotEmpty);
        expect(r.responses.first.statusCode, equals(200));
        expect(JSON.decode(r.responses.first.body)['content-length'], equals(null));

        r.cleanResponses();

        expect(r.responses, isEmpty);
      }

      await request.fluent((r) => r.get(serverUrl)).make(handler);
    });

    test('Testing fluent with make, and two requests', () async {
      void handler(Request r) {
        expect(r.responses, isNotEmpty);
        expect(r.responses.length, equals(2));

        expect(r.responses.first.statusCode, equals(200));
        expect(JSON.decode(r.responses.first.body)['body'], equals(null));

        expect(JSON.decode(r.responses[1].body)['body'], equals('request body'));
        expect(r.responses[1].statusCode, equals(200));
      }

      await request
          .fluent((r) => r.get(serverUrl))
          .fluent((r) => r.post(serverUrl.toString() + '/two_requests', body: 'request body'))
          .make(handler);
    });

    test('Testing validateStatus with common request', () async {
      Response response;

      await request
          .validateStatus((status) => 200 == status)
          .get(serverUrl)
          .then((r) => response = r);

      expect(response.statusCode, equals(200));
    });

    test('Testing validateStatus with fluent one request', () async {
      Response response;

      await request
          .fluent((r) => r.validateStatus((status) => 200 == status).get(serverUrl))
          .makeClosure((r) async {
        response = r.first;
      });

      expect(response.statusCode, equals(200));
    });

    test('Testing validateStatus with fluent two requests', () async {
      List<Response> responses;

      await request
          .fluent((r) => r.validateStatus((status) => 200 == status).get(serverUrl))
          .fluent((r) =>
              r.validateStatus((status) => 200 == status).get(serverUrl.toString() + '/some_data'))
          .makeClosure((r) async {
        responses = r;
      });

      expect(responses.length, equals(2));

      expect(responses.first.statusCode, equals(200));
      expect(responses[1].statusCode, equals(200));
    });

    test('Testing exception validateStatus with fluent and one request', () async {
      var error;

      await request
          .fluent((r) => r.validateStatus((status) => 500 == status).get(serverUrl))
          .makeClosure((_) => null)
          .catchError((e) async {
        error = e;
      });

      expect(error is BadStatusCode, isTrue);
    });

    test('Testing exception on second validateStatus with fluent and two requests', () async {
      var error;

      await request
          .fluent((r) => r.validateStatus((status) => 200 == status).get(serverUrl))
          .fluent((r) =>
              r.validateStatus((status) => 500 == status).get(serverUrl.toString() + '/first_url'))
          .makeClosure((_) => null)
          .catchError((e) async {
        error = e;
      });

      expect(error is BadStatusCode, isTrue);
      expect(
          error.toString(),
          equals('Bad state: Status code is not the same with 200. Url: '
              '${serverUrl.toString(
                    )}/first_url.'));
    });

    test('Testing exception on first validateStatus with fluent and two requests', () async {
      var error;

      await request
          .fluent((r) => r.validateStatus((status) => 500 == status).get(serverUrl))
          .fluent((r) =>
              r.validateStatus((status) => 200 == status).get(serverUrl.toString() + '/first_url'))
          .makeClosure((_) => null)
          .catchError((e) async {
        error = e;
      });

      expect(error is BadStatusCode, isTrue);
      expect(error.toString(),
          equals('Bad state: Status code is not the same with 200. Url: ${serverUrl.toString(
                    )}.'));
    });
  });
}
