# Task Foundation

Phase 05 is a read-only task projection over the existing deterministic repositories.

## Query and visibility

`TaskQuery` provides typed search, quick views, filters, and sorting. The query service
checks every task with `AuthorizationService` and an `AccessTarget` before any title,
number, or metadata reaches search/filter code. Direct assignments support own access;
team, department, and organization access require the corresponding permission.
Confidential requires direct ownership or `task.view_confidential`; restricted requires
`task.view_restricted`. Administrators receive no implied operational access.

## Quick views and filters

Today uses the local calendar day; This Week is Monday through Sunday; Overdue excludes
completed, cancelled, declined, and expired; Blocked includes active blockers; Awaiting
Approval includes pending approval/completion-requested; Queue, Completed, and Drafts
use their typed modes/statuses. Advanced filters cover status, priority, dates, people,
team, department, category, assignment, approval, confidentiality, blocker, recurrence,
local modification, and pending synchronization. Multiple filters use AND semantics.

## Sorting

Due date, priority, creation, update, progress, effort, and task number support both
directions. Null values remain last when ascending and task number breaks every tie.

## Saved filters

Filters are user-specific and runtime-only. Names are required. Saving the same
case-insensitive name replaces that user's previous filter. Defaults are user-specific.
Restarting the demo clears them; this is not persistent storage.

## Details and timeline

Details resolve creator, lead, team, assignments, configuration labels, checklist,
subtasks, blockers, approval, comments, attachments, and authorization. Missing optional
references display safely. Unauthorized or missing records return no aggregate. Timeline
entries are sanitized, immutable, and newest-first; no payloads, credentials, or stack
traces are shown.

## Demo limitations

There is no task mutation, real synchronization, persistence, backend, networking,
cloud service, reporting, or administration CRUD. Synchronization states are display-only.

## Phase 05B presentation refinement

Task presentation now uses role-specific page contexts, authorization-aware manager scopes, and a compound senior-management critical view. The list keeps authorization before filtering and adds compact search, quick views, advanced runtime filters, sorting, and saved-filter controls. Cards use a dense number/status/title/metadata/progress/footer hierarchy and switch to two columns on tablet widths. Task details are read-only grouped surfaces with labeled assignments and localized newest-first timeline entries.
