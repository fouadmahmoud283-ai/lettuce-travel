import 'dart:async';

/// An in-memory collection that behaves like a live Firestore query, for the
/// `data/repositories/fake_*_repository.dart` implementations used until a
/// real backend is wired up (see AGENTS.md section 9).
///
/// [watch] and [watchOne] replay the current snapshot to every new listener
/// and then continue emitting on every mutation, the same shape a
/// `Stream<List<T>>` from Firestore would have.
class MockCollection<T> {
  final List<T> _items = <T>[];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  List<T> get items => List<T>.unmodifiable(_items);

  void seed(Iterable<T> items) => _items.addAll(items);

  void add(T item) {
    _items.add(item);
    _changes.add(null);
  }

  /// Replaces the first item matching [matches], or appends [item] if none do.
  void upsert(T item, bool Function(T existing) matches) {
    final int index = _items.indexWhere(matches);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    _changes.add(null);
  }

  void removeWhere(bool Function(T item) test) {
    _items.removeWhere(test);
    _changes.add(null);
  }

  Stream<List<T>> watch([bool Function(T item)? where]) async* {
    List<T> snapshot() =>
        where == null ? List<T>.unmodifiable(_items) : _items.where(where).toList();
    yield snapshot();
    await for (final void _ in _changes.stream) {
      yield snapshot();
    }
  }

  Stream<T?> watchOne(bool Function(T item) match) async* {
    T? find() {
      for (final T item in _items) {
        if (match(item)) return item;
      }
      return null;
    }

    yield find();
    await for (final void _ in _changes.stream) {
      yield find();
    }
  }

  void dispose() => unawaited(_changes.close());
}
