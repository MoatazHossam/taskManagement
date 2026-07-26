# Task Creation — Phase 06

## Permissions

All decisions use `AuthorizationService`. `task.create_self` plus `task.assign_self` locks an employee to themselves. `task.create_for_others` and the effective assignment scope allow managers and authorized senior management to choose one active organization user. Administrators require an explicit task permission. Restricted confidentiality requires `task.view_restricted`.

## Draft rules

Drafts may be incomplete, remain private to the creator, and cannot use a different employee owner. First save assigns stable `task-created-NNN` and `TASK-<year>-NNNN` identities and preserves both on update and submit. A submitted task cannot return to draft; repeat submission cannot create a duplicate. Deletion is creator-only, confirmed by presentation, and audited.

## Validation

Submission requires at least one trimmed bilingual title, category, priority, confidentiality, creator, and single owner. Titles are limited to 150 characters and descriptions to 4,000. Effort is optional but positive in minutes. Due date cannot precede planned start or the fixed current demo time. Draft saves enforce identity, permission, assignment-mode, confidentiality, and effort safety while allowing missing submission fields.

## Numbering and templates

The in-memory identity service scans seeded IDs/numbers, uses no random values, and avoids collisions for the runtime. Restart resets its sequence but rescans seed/runtime state. Templates apply only supplied title/category/priority fields after overwrite confirmation and never assign an owner.

## Flow

The responsive four-step flow is Basic Information, Classification and Planning, Assignment, and Review and Submit. Confirmation prevents accidental submission. Success offers task details, another creation, or the task list. Draft editing uses the same authoritative Riverpod draft.

## Persistence, audit, and sync

The service inserts/updates the existing `Task`, creates one owner `TaskAssignment` on submission, appends save/submit/delete audit events, and queues a sanitized pending sync operation. Query providers are invalidated immediately. No keystrokes are audited. New entities remain locally modified and pending; there is no network or retry.

## Demo limitations

All state is process-memory only. There is no backend, database, Drift, SQLite, Firebase, cloud, networking, upload, notification delivery, recurrence editor, execution action, approval action, advanced assignment, reporting, or administration CRUD. Phase 07 remains not started.
