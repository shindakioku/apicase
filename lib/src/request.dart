import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' show Response, IOClient, Client, BaseRequest, StreamedResponse;

import 'validate_status_def.dart';
import 'bad_status.dart';

/**
 * This class use http.dart. You can using a common methods for request like get, post, put, etc.
 * Also you can using getter [ioClient] for using all http library.
 */
abstract class Request implements Client {
  factory Request() => new _Request();

  /**
     * When you using [make] or [makeClosure], library try to make requests and save [Response] in
     * this variable.
     */
  List<Response> get responses;

  IOClient get ioClient;

  /**
     * A callback for the check [Response.statusCode]. Callback will called after request and
        make throw
     * [BadStatusCode] if callback return false.
     *
     *  request
     *    .validateStatus((request) => request == 500)
     *    .get('http://site.com)
     *    .then((r) => print('response: ${r}'))
     *    .catchError((e) => print('error: ${e}'));
     *
     *   In catch you can see error like:
     *   Bad state: Status code is not the same with 200. Url: http://site.com
     */
  Request validateStatus(Status closure);

  /**
     * This method is for making a many requests. When you using [fluent] it's will add your
     * function to [_fluentRequests]. Also this method passing [Request] in your function and
     * return [Request] so, you can using a fluent interface
     *
     *  request
     *    .fluent((Request r) => r.get('http://site.com'))
     *    .fluent((Request r) => r.get('http://site.net'))
     *
     * Of course you can use [validateStatus]
     *
     *   request
     *     .fluent((Request r) => r.validateStatus((code) => 200 == code).get('http://site.com'))
     *     .fluent((Request r) => r.validateStatus((code) => 200 == 400).get('http://site.net'))
     *
     *  But you need to know, if you will have error of an anyone callback, then you will be have
     *  the [BadStatusCode]
     */
  Request fluent(Function closure);

  /**
     * You must call this method after using [fluent]. It's calling the each your callback and add
     * result into [_responses]
     *
     *    void handler(Request r) {
     *       print(r.responses); // Here will be a all results of requests
     *    }
     *
     *  request
     *    .fluent((Request r) => r.get('http://site.ru))
     *    .fluent((Request r) => r.get('http://site.com'))
     *    .make(handler);
     */
  Future<Request> make(Function closure);

  /**
     *    Like [make] this method also calling the each callback, but difference between this method
     *    and [make] is:
     *
     *  request
     *    .fluent((Request r) => r.get('http://site.ru))
     *    .fluent((Request r) => r.get('http://site.com'))
     *    .makeClosure((List<Response> responses) => print(responses));
     */
  Future<Function> makeClosure(Function closure);

  // If is true, then after make all requests, [_fluentClosures] (your callbacks) will be clean
  Request cleanFluent(bool v);

  /// Cleaning [_responses]
  Request cleanResponses();
}

class _Request implements Request {
  IOClient _client;
  Status _validateStatus;
  List<Function> _fluentClosures;
  List<Response> _responses = [];
  bool _cleaningFluent;

  List<Response> get responses => _responses;

  IOClient get ioClient => _client;

  _Request() {
    _client = new IOClient();
    _fluentClosures = [];
    _responses = [];
    _cleaningFluent = false;
  }

  Request cleanFluent(bool v) {
    _cleaningFluent = v;

    return this;
  }

  Request cleanResponses() {
    _responses = [];

    return this;
  }

  Request fluent(Function closure) {
    _fluentClosures.add(closure);

    return this;
  }

  Future<Request> make(Function closure) async {
    if (_fluentClosures.isEmpty) {
      throw new Exception('To first, you must add a urls with fluent');
    }

    await _makeRequests();

    return closure(this);
  }

  Future<Function> makeClosure(Function closure) async {
    await _makeRequests();

    return closure(_responses);
  }

  Future _makeRequests() async {
    for (var f in _fluentClosures) {
      await f(this).then((r) => _responses.add(r));
    }

    if (_cleaningFluent) {
      _fluentClosures = [];
    }
  }

  Request validateStatus(Status closure) {
    _validateStatus = closure;

    return this;
  }

  Future<Response> _check(Future<Response> response) async {
    if (null == _validateStatus) {
      return response;
    }

    await response.then((r) {
      if (!_validateStatus(r.statusCode)) {
        throw new BadStatusCode('Status code is not the same with ${r.statusCode}. Url: ${r
                            .request.url}.');
      }
    });

    return response;
  }

  Future<Response> head(url, {Map<String, String> headers}) {
    return _check(_client.head(url, headers: headers));
  }

  Future<Response> get(url, {Map<String, String> headers}) {
    return _check(_client.get(url, headers: headers));
  }

  Future<Response> post(url, {Map<String, String> headers, body, Encoding encoding}) {
    return _client.post(url, headers: headers, body: body, encoding: encoding);
  }

  Future<Response> put(url, {Map<String, String> headers, body, Encoding encoding}) {
    return _client.put(url, headers: headers, body: body, encoding: encoding);
  }

  Future<Response> patch(url, {Map<String, String> headers, body, Encoding encoding}) {
    return _client.patch(url, headers: headers, body: body, encoding: encoding);
  }

  Future<Response> delete(url, {Map<String, String> headers}) {
    return _client.delete(url, headers: headers);
  }

  Future<String> read(url, {Map<String, String> headers}) {
    return _client.read(url, headers: headers);
  }

  Future<Uint8List> readBytes(url, {Map<String, String> headers}) {
    return _client.readBytes(url, headers: headers);
  }

  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request);
  }

  void close() {
    _client.close();
  }
}
