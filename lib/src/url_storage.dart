import 'url_storage_exception.dart';

// Class is helping to [Client] and [Resource]
// Here's all urls what setUpped.
abstract class UrlStorage {
  factory UrlStorage() => new _UrlStorage();

  List<Url> get urls;

  /**
     * Sets url in the storage.
     *
     *    storage.make((Request r) => r.get('http://site.net'), 'index');
     *    storage.make((Request r) => r.post('http://site.com'), 'index1');
     */
  UrlStorage make(Function closure, String name);

  /**
     * Returns the Url object with your data.
     *
     *    Url url = storage.build((_) => null, 'someName');
     *
     *  It's same with
     *
     *    Url url = new Url((_) => null, 'someName');
     */
  Url build(Function closure, String name);

  UrlStorage cleanUrls();

  bool update(String name, {String newName, Function newClosure});
}

class Url {
  Function closure;
  String name;

  Url(this.closure, this.name);

  Url build() {
    if (null == name) {
      throw new UrlStorageBuild('Name cannot be null');
    }

    if (null == closure) {
      throw new UrlStorageBuild('Closure cannot be null');
    }

    return new Url(closure, name);
  }

  String toString() => 'Name: ${name}';
}

class _UrlStorage implements UrlStorage {
  List<Url> _urls;

  List<Url> get urls => _urls;

  _UrlStorage() {
    _urls = [];
  }

  UrlStorage cleanUrls() {
    _urls = [];

    return this;
  }

  UrlStorage make(Function closure, String name) {
    _urls.add(new Url(closure, name));

    return this;
  }

  Url build(Function closure, String name) {
    return new Url(closure, name).build();
  }

  bool update(String name, {String newName, Function newClosure}) {
    int indexOfUrl;

    if (_urls.isEmpty) {
      return false;
    }

    if (null != name) {
      indexOfUrl = _urls.indexWhere((u) => u.name == name);
    }

    if (-1 == indexOfUrl) {
      throw new IncorrectNameUpdate('Incorrect name: ${name} for update.');
    }

    if (null != newName) {
      _urls[indexOfUrl].name = newName;
    }

    if (null != newClosure) {
      _urls[indexOfUrl].closure = newClosure;
    }

    return true;
  }
}
