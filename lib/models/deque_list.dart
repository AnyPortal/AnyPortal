class DequeList<T> {
  List<T?> _buffer;
  int _head = 0;
  int _size = 0;

  /// Create an empty DequeList.
  DequeList([int initialCapacity = 8])
    : _buffer = List<T?>.filled(initialCapacity, null);

  /// Create a DequeList from an Iterable.
  factory DequeList.from(Iterable<T> items) {
    final list = items.toList();
    final deque = DequeList<T>(list.length);
    deque.addAllLast(list);
    return deque;
  }

  /// Current number of elements.
  int get length => _size;

  bool get isEmpty => _size == 0;
  bool get isNotEmpty => _size > 0;

  /// Get item by index.
  T operator [](int index) {
    if (index < 0 || index >= _size) {
      throw RangeError.index(index, this, 'index');
    }
    return _buffer[(_head + index) % _buffer.length]!;
  }

  /// Set item by index.
  void operator []=(int index, T value) {
    if (index < 0 || index >= _size) {
      throw RangeError.index(index, this, 'index');
    }
    _buffer[(_head + index) % _buffer.length] = value;
  }

  /// Clear
  void clear() {
    _size = 0;
  }

  /// Add to the end.
  void addLast(T value) {
    _ensureCapacity(_size + 1);
    _buffer[(_head + _size) % _buffer.length] = value;
    _size++;
  }

  /// Add to the start.
  void addFirst(T value) {
    _ensureCapacity(_size + 1);
    _head = (_head - 1 + _buffer.length) % _buffer.length;
    _buffer[_head] = value;
    _size++;
  }

  /// Add multiple to the end.
  void addAllLast(Iterable<T> items) {
    final list = items is List<T> ? items : items.toList();
    _ensureCapacity(_size + list.length);
    for (var item in list) {
      _buffer[(_head + _size) % _buffer.length] = item;
      _size++;
    }
  }

  /// Add multiple to the start.
  void addAllFirst(Iterable<T> items) {
    final list = items is List<T> ? items : items.toList();
    _ensureCapacity(_size + list.length);
    for (var i = list.length - 1; i >= 0; i--) {
      _head = (_head - 1 + _buffer.length) % _buffer.length;
      _buffer[_head] = list[i];
      _size++;
    }
  }

  /// Remove from the end.
  T removeLast() {
    if (_size == 0) throw StateError('Deque is empty');
    final index = (_head + _size - 1) % _buffer.length;
    final value = _buffer[index];
    _buffer[index] = null;
    _size--;
    return value!;
  }

  /// Remove from the start.
  T removeFirst() {
    if (_size == 0) throw StateError('Deque is empty');
    final value = _buffer[_head];
    _buffer[_head] = null;
    _head = (_head + 1) % _buffer.length;
    _size--;
    return value!;
  }

  /// Ensure the internal buffer is big enough.
  void _ensureCapacity(int minCapacity) {
    if (minCapacity <= _buffer.length) return;
    int newCapacity = _buffer.length * 2;
    while (newCapacity < minCapacity) {
      newCapacity *= 2;
    }
    final newBuffer = List<T?>.filled(newCapacity, null);
    for (var i = 0; i < _size; i++) {
      newBuffer[i] = this[i];
    }
    _buffer = newBuffer;
    _head = 0;
  }

  /// Convert to a List.
  List<T> toList() {
    return List<T>.generate(_size, (i) => this[i]);
  }

  @override
  String toString() => toList().toString();
}
