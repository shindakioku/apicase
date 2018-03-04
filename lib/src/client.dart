import 'request.dart';
import 'url_storage.dart';
import 'client_exception.dart';

import 'dart:mirrors';
import 'dart:async';

import 'package:http/src/response.dart';

// Class with storage for your urls. See examples.
abstract class Client implements UrlStorage {
  factory Client() => new _Client();

  List<Url> get urls;

  Future<Response> makeRequest(String name);

  Future<List<Future<Response>>> makeRequests(List<String> names);
}

class _Client implements Client {
  Request _request;
  UrlStorage _storage;

  Request get request => _request;

  List<Url> get urls => _storage.urls;

  _Client() {
    _request = new Request();
    _storage = new UrlStorage();
  }

  Future<Response> makeRequest(String name) {
    var clientUrl;

    try {
      clientUrl = _storage.urls.firstWhere((u) => u.name == name);
    } catch (e) {
      throw new NameIsNotFound('Incorrect name ${name}');
    }

    if (null == clientUrl) {
      throw new NameIsNotFound('Incorrect name ${name}');
    }

    return clientUrl.closure(_request);
  }

  Future<List<Future<Response>>> makeRequests(List<String> names) async {
    if (_storage.urls.isEmpty) {
      throw new UrlsIsEmpty('Urls cannot be empty');
    }

    List<Future<Response>> responses = [];

    await _storage.urls.forEach((u) async {
      responses.add(u.closure(_request));
    });

    return responses;
  }

  @override
  noSuchMethod(Invocation invocation) {
    try {
      return reflect(_storage)
          .invoke(invocation.memberName, invocation.positionalArguments, invocation.namedArguments)
          .reflectee;
    } catch (e) {
      return e.noSuchMethod(invocation);
    }
  }
}
