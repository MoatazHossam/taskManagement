import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/core/domain/app_clock.dart';
import 'package:organization_task_manager/core/domain/domain_enums.dart';
import 'package:organization_task_manager/core/storage/database/seed/demo_seed_ids.dart';
import 'package:organization_task_manager/shared/models/demo_profile_user_mapping.dart';
void main(){ test('all enum codes round trip and unknown values are safe',(){expect(UserStatus.fromCode('active'),UserStatus.active);expect(TaskStatus.fromCode('future'),TaskStatus.unknown);expect(AssignmentMode.fromCode(null),AssignmentMode.unknown);expect(AuditEventType.fromCode('created'),AuditEventType.created);}); test('fixed clock normalizes UTC',(){final c=FixedAppClock(DateTime.parse('2026-01-02T03:00:00+03:00'));expect(c.now(),DateTime.utc(2026,1,2));}); test('seed ids and demo mappings are stable and unique',(){expect(DemoSeedIds.ahmed,'user-ahmed-hassan');expect(validateDemoProfileMappings(),isTrue);expect(demoProfileUserIds.values.toSet(),hasLength(5));}); }
