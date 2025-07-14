class CountedCircularBuffer<T> {
  final List<T?> _buffer;
  final Map<T, int> _countMap = {};
  int _start = 0;
  int _length = 0;
  T? _mostFrequent;
  int _mostFrequentCount = 0;

  CountedCircularBuffer(int size) : _buffer = List.filled(size, null);

  int get capacity => _buffer.length;
  int get length => _length;

  T? get mostFrequent => _mostFrequent;
  int get mostFrequentCount => _mostFrequentCount;

  void add(T value) {
    if (_length < capacity) {
      _buffer[(_start + _length) % capacity] = value;
      _length++;
    } else {
      final old = _buffer[_start]!;
      _buffer[_start] = value;
      _start = (_start + 1) % capacity;
      _decrementCount(old);
    }
    _incrementCount(value);
  }

  void _incrementCount(T value) {
    final count = (_countMap[value] ?? 0) + 1;
    _countMap[value] = count;
    if (count > _mostFrequentCount || _mostFrequent == null) {
      _mostFrequent = value;
      _mostFrequentCount = count;
    }
  }

  void _decrementCount(T value) {
    final count = (_countMap[value] ?? 0) - 1;
    if (count <= 0) {
      _countMap.remove(value);
    } else {
      _countMap[value] = count;
    }
    // Recalculate mostFrequent if necessary
    if (value == _mostFrequent && count < _mostFrequentCount) {
      _recalculateMostFrequent();
    }
  }

  void _recalculateMostFrequent() {
    _mostFrequent = null;
    _mostFrequentCount = 0;
    _countMap.forEach((key, count) {
      if (count > _mostFrequentCount) {
        _mostFrequent = key;
        _mostFrequentCount = count;
      }
    });
  }

  List<T> toList() {
    return List.generate(_length, (i) => _buffer[(_start + i) % capacity]!);
  }
}
