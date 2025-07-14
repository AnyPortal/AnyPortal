class BlockDeque {
  final int blockSize;
  final List<List<double>> _blocks = [];
  final List<double> _blockSums = [];

  BlockDeque({this.blockSize = 32});

  int get length => _blocks.fold(0, (sum, b) => sum + b.length);

  void _ensureFrontBlock() {
    if (_blocks.isEmpty || _blocks.first.length >= blockSize) {
      _blocks.insert(0, []);
      _blockSums.insert(0, 0);
    }
  }

  void _ensureBackBlock() {
    if (_blocks.isEmpty || _blocks.last.length >= blockSize) {
      _blocks.add([]);
      _blockSums.add(0);
    }
  }

  void addFirst(double value) {
    _ensureFrontBlock();
    _blocks.first.insert(0, value);
    _blockSums[0] += value;
  }

  void addLast(double value) {
    _ensureBackBlock();
    _blocks.last.add(value);
    _blockSums[_blockSums.length - 1] += value;
  }

  /// Add multiple to the end.
  void addAllLast(Iterable<double> items) {
    for (var item in items) {
      addLast(item);
    }
  }

  /// Add multiple to the start.
  void addAllFirst(Iterable<double> items) {
    final list =
        items is List<double> ? items.reversed : items.toList().reversed;
    for (var item in list) {
      addFirst(item);
    }
  }

  double removeFront() {
    if (_blocks.isEmpty) throw StateError("Empty");
    final val = _blocks.first.removeAt(0);
    _blockSums[0] -= val;
    if (_blocks.first.isEmpty) {
      _blocks.removeAt(0);
      _blockSums.removeAt(0);
    }
    return val;
  }

  double removeLast() {
    if (_blocks.isEmpty) throw StateError("Empty");
    final val = _blocks.last.removeLast();
    _blockSums[_blockSums.length - 1] -= val;
    if (_blocks.last.isEmpty) {
      _blocks.removeLast();
      _blockSums.removeLast();
    }
    return val;
  }

  /// Get prefix sum [0..index]
  double prefixSum(int index) {
    if (index == -1) return 0;
    if (index < 0 || index >= length) {
      throw RangeError.range(index, 0, length - 1);
    }
    double sum = 0;
    int i = index;
    for (int b = 0; b < _blocks.length; b++) {
      final block = _blocks[b];
      if (i < block.length) {
        for (int j = 0; j <= i; j++) {
          sum += block[j];
        }
        break;
      } else {
        sum += _blockSums[b];
        i -= block.length;
      }
    }
    return sum;
  }

  /// Read by index
  double operator [](int index) {
    if (index < 0 || index >= length) {
      throw RangeError.range(index, 0, length - 1);
    }
    int i = index;
    for (final block in _blocks) {
      if (i < block.length) return block[i];
      i -= block.length;
    }
    throw StateError('Should not reach');
  }

  /// Write by index
  void operator []=(int index, double value) {
    if (index < 0 || index >= length) {
      throw RangeError.range(index, 0, length - 1);
    }
    int i = index;
    for (int b = 0; b < _blocks.length; b++) {
      final block = _blocks[b];
      if (i < block.length) {
        final old = block[i];
        block[i] = value;
        _blockSums[b] += (value - old);
        return;
      }
      i -= block.length;
    }
  }

  void clear() {
    _blocks.clear();
    _blockSums.clear();
  }

  @override
  String toString() => _blocks.expand((b) => b).toList().toString();
}
