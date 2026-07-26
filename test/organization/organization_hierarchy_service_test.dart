import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/core/demo/demo_data_store.dart';
import 'package:organization_task_manager/core/demo/demo_seed_ids.dart';
import 'package:organization_task_manager/core/demo/in_memory_repositories.dart';
import 'package:organization_task_manager/core/domain/entities.dart';
import 'package:organization_task_manager/features/organization/data/repository_organization_hierarchy_service.dart';

void main() {
  late DemoDataStore store;
  late RepositoryOrganizationHierarchyService service;
  setUp(() { store=DemoDataStore(); service=RepositoryOrganizationHierarchyService(users:InMemoryUserRepository(store),organization:InMemoryOrganizationRepository(store)); });
  test('resolves contexts for all five personas', () async { for(final id in [DemoSeedIds.ahmed,DemoSeedIds.sara,DemoSeedIds.omar,DemoSeedIds.laila,DemoSeedIds.khaled]) { expect((await service.getUserContext(id)).user.id,id); } });
  test('department path and descendants are deterministic', () async { expect((await service.getDepartmentPath(DemoSeedIds.operations)).map((d)=>d.id),[DemoSeedIds.executive,DemoSeedIds.operations]); expect((await service.getDescendantDepartments(DemoSeedIds.executive)).map((d)=>d.code),['FIN','HR','IT','OPS']); });
  test('direct and recursive reports resolve without loops', () async { expect((await service.getDirectReports(DemoSeedIds.sara)).map((u)=>u.employeeNumber),['E001','E003','E004']); expect((await service.getAllReports(DemoSeedIds.omar)).map((u)=>u.id),containsAll([DemoSeedIds.sara,DemoSeedIds.laila,DemoSeedIds.ahmed,DemoSeedIds.khaled])); store.users.add(store.users.first); expect((await service.getAllReports(DemoSeedIds.omar)).length,lessThan(20)); });
  test('team and queue membership resolve', () async { final khaled=await service.getUserContext(DemoSeedIds.khaled); expect(khaled.queueMemberships.single.id,DemoSeedIds.technicalSupportQueue); final sara=await service.getUserContext(DemoSeedIds.sara); expect(sara.ledTeams.single.id,DemoSeedIds.fieldOperations); });
  test('broken and circular departments fail safely', () async { final department=store.departments.firstWhere((d)=>d.id==DemoSeedIds.executive); store.departments[store.departments.indexOf(department)]=Department(id:department.id,code:department.code,nameAr:department.nameAr,parentDepartmentId:DemoSeedIds.operations); expect((await service.getDepartmentPath(DemoSeedIds.operations)).length,2); expect(()=>service.getDepartmentPath('missing'),returnsNormally); });
  test('returned collections cannot be changed', () async { final teams=await service.getUserTeams(DemoSeedIds.ahmed); expect(()=>teams.add(teams.first),throwsUnsupportedError); });
}
