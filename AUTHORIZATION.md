# Authorization

## Model and boundaries

Phase 04 uses Flutter-independent `OrganizationHierarchyService` and `AuthorizationService` interfaces. Their repository-backed in-memory implementations depend only on `UserRepository`, `OrganizationRepository`, and `PermissionOverrideRepository`; a future on-premises adapter can implement those boundaries without changing feature widgets. Permission checks are enforced by the service and protected routes as well as by presentation gates.

Permission and scope are separate requirements. `AccessScope` values are `self`, `team`, `department`, `organization`, and `administration`. Administration scope represents configuration authority and is not an executive reporting scope. A target may identify its owner, team, department, organization, personal status, and confidentiality.

## Role matrix

| Capability | Employee | Manager | Senior management | Administrator |
|---|---:|---:|---:|---:|
| Own profile/context/task/report | Yes | Yes | Yes | Profile/context only |
| Team and department task/report access | No | Yes | Yes | No |
| Organization assignment/reassignment | No | Yes | Yes | No |
| Approval | No | Yes | Yes | No |
| Organization report | No | No | Yes | No |
| Safe organization directory | Own context | Full | Full | Full |
| System administration | No | No | No | Yes |

Managers intentionally have organization-wide create, assignment, and reassignment authority. Senior management does not inherit administration. Administrators do not inherit executive reports, employee-performance reports, approval, organization task assignment, confidential task visibility, or restricted task visibility.

## Permission catalogue

Permissions are typed `PermissionCode` values and use stable dotted storage codes:

- Profile and directory: `profile.view_self`, `organization.view_own_context`, `organization.view_team`, `organization.view_department`, `organization.view_all`, `directory.view_users`, `directory.view_reporting_lines`.
- Task foundation: `task.view_own`, `task.view_team`, `task.view_department`, `task.view_all`, `task.create_self`, `task.create_for_others`, all self/team/department/organization assignment and reassignment codes, queue claim/release, approval, extension, recurrence, confidential visibility, and restricted visibility.
- Reports: self, team, department, organization, and employee-performance viewing.
- Administration: view, users, organization, roles, configuration, audit, sync, and settings management.

These codes establish policy only. Phase 04 adds no task, report, approval, or administration CRUD feature.

## Overrides

An override identifies the user, typed permission, allow/deny effect, safe reason, and optional scope. Explicit deny wins over a role grant. Explicit allow adds a permission. Without an explicit override scope, the user's normal scope continues to apply. Overrides are deterministic in-memory demo records and the approved seed contains none.

## Team queues

A current `queueMember` membership dynamically adds queue claim/release capabilities. A decision still requires a target for the same queue and verifies that the team is queue-enabled. Ordinary membership and team leadership do not grant queue claiming. Khaled's Technical Support Queue membership therefore cannot authorize another queue.

## Confidentiality

Public targets require their base permission and scope. Internal targets additionally require the same organization. Confidential targets require `task.view_confidential` unless the target is owned directly by the user (the later direct-assignment exception is intentionally deferred). Restricted targets require `task.view_restricted`; future explicit assignment rules remain deferred. Directory screens contain safe organization fields only.

## Diagnostics and limitations

The access-summary developer section exposes only stable demo user/role identifiers, scope, permission count, and permission codes. It never exposes credentials, PINs, session tokens, or raw exceptions. This deterministic model is not a security backend, policy editor, persistence layer, or substitute for server-side enforcement. Future on-premises APIs must repeat authorization at every protected operation and return safe reason codes.
