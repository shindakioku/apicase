import 'package:apicase/apicase.dart';
import 'package:test/test.dart';

import 'dart:convert';
import 'middleware.dart';

void main() {
  group('A group of tests', () {
    UrlStorage storage;

    setUp(() async {
      storage = new UrlStorage();
    });

    test('Urls is empty', () async {
      expect(storage.urls, isEmpty);
    });

    test('Add a one url to storage', () async {
      storage.make((Request r) => r.get('localhost'), 'index');
      var first = storage.urls.first;

      expect('index', equals(first.name));
    });

    test('Add a two urls to storage', () async {
      storage.make((Request r) => r.get('localhost'), 'index');
      storage.make((Request r) => r.get('site.ru'), 'siteru');
      var first = storage.urls.first;
      var second = storage.urls[1];

      expect('index', equals(first.name));
      expect('siteru', equals(second.name));
    });

    test('Clean urls', () async {
      expect(storage.urls, isEmpty);

      storage.make((Request r) => r.get('localhost'), 'index');

      expect(storage.urls, isNotEmpty);

      storage.cleanUrls();

      expect(storage.urls, isEmpty);
    });

    test('Build url', () async {
      var urlStorage = storage.build((_) => 0, 'name');

      expect(urlStorage is Url, isTrue);
      expect('name', urlStorage.name);
    });

    test('Exception when try to build url', () async {
      try {
        storage.build((_) => 0, null);
      } on UrlStorageBuild catch (e) {
        expect(e.toString(), 'Bad state: Name cannot be null');
      }
    });

    test('Update name', () async {
      storage.make((Request r) => r.get('localhost'), 'index');

      expect(storage.urls.first.name, 'index');

      storage.update('index', newName: 'newIndex');

      expect(storage.urls.first.name, 'newIndex');
    });

    test('Exception when try to update name', () async {
      storage.make((Request r) => r.get('localhost'), 'noName');

      try {
        storage.update('index', newName: 'newIndex');
      } on IncorrectNameUpdate catch (e) {
        expect(e.toString(), 'Bad state: Incorrect name: index for update.');
      }
    });
  });
}
