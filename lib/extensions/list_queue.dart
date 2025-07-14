import 'dart:collection';

extension ListQueueX<T> on ListQueue<T> {
  T operator [](int index) {
    return elementAt(index);
  }

  void addAllFirst(Iterable<T> items) {
    final list = items is List<T> ? items : items.toList();
    for (var i = list.length - 1; i >= 0; i--) {
      addFirst(list[i]);
    }
  }
}
