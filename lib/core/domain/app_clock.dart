abstract interface class AppClock {
  DateTime now();
}

final class SystemAppClock implements AppClock {
  const SystemAppClock();
  @override
  DateTime now() => DateTime.now().toUtc();
}

final class FixedAppClock implements AppClock {
  const FixedAppClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value.toUtc();
}
