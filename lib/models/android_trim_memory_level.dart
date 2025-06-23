enum AndroidTrimMemoryLevel {
  runningModerate(5),
  runningLow(10),
  runningCritical(15),
  uiHidden(20),
  background(40),
  moderate(60),
  complete(80);

  final int value;
  const AndroidTrimMemoryLevel(this.value);

  static AndroidTrimMemoryLevel fromValue(int value) {
    return AndroidTrimMemoryLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AndroidTrimMemoryLevel.runningModerate,
    );
  }
}
