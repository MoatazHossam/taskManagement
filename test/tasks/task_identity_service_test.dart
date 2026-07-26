import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/features/tasks/domain/task_identity_service.dart';

void main() {
  test('identity generation is deterministic, unique, and collision safe', () {
    final service = InMemoryTaskIdentityService(existingIds: const ['task-created-001'], existingNumbers: const ['TASK-2026-0001'], year: 2026);
    expect(service.nextTaskId(), 'task-created-002');
    expect(service.nextTaskId(), 'task-created-003');
    expect(service.nextTaskNumber(), 'TASK-2026-0002');
    expect(service.nextTaskNumber(), 'TASK-2026-0003');
  });
}
