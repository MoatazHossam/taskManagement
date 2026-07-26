abstract interface class TaskIdentityService {
  String nextTaskId();
  String nextTaskNumber();
}

final class InMemoryTaskIdentityService implements TaskIdentityService {
  InMemoryTaskIdentityService({required Iterable<String> existingIds, required Iterable<String> existingNumbers, required int year}) : _ids = existingIds.toSet(), _numbers = existingNumbers.toSet(), _year = year;
  final Set<String> _ids, _numbers;
  final int _year;
  int _idSequence = 0, _numberSequence = 0;
  @override String nextTaskId() { String value; do { value = 'task-created-${(++_idSequence).toString().padLeft(3, '0')}'; } while (_ids.contains(value)); _ids.add(value); return value; }
  @override String nextTaskNumber() { String value; do { value = 'TASK-$_year-${(++_numberSequence).toString().padLeft(4, '0')}'; } while (_numbers.contains(value)); _numbers.add(value); return value; }
}
