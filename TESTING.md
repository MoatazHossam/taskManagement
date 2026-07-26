# Testing and Quality Policy

## Principles

Tests are part of each implementation phase, not a final cleanup activity. Business rules are tested below the UI; presentation tests prove user-visible behavior in both languages and directions; deterministic local services keep suites repeatable and free of external dependencies. Defect fixes require a regression test at the lowest effective level.

Phase 00 has no initialized Flutter project, Dart code, or executable tests. Its validation is structural and documentary. Phase 01 must establish the executable test harness.

## Unit tests

Use unit tests for:

- business rules and validation;
- permission, organizational-scope, and confidentiality checks;
- task status transitions and mandatory reasons;
- repository logic and mappings;
- synchronization queue and conflict rules; and
- report calculations and meaning-layer inputs.

Tests should be pure where possible. Drift repositories should use an isolated in-memory database. Riverpod dependencies should be replaced through provider overrides rather than global mutation.

## Widget tests

Use widget tests for:

- role-based navigation and guarded destinations;
- forms and validation messages;
- localization coverage and language switching;
- Arabic RTL and English LTR layouts;
- offline banners and sync indicators;
- status actions and confirmation/reason dialogs; and
- loading, empty, error, and accessible non-color states.

Exercise representative phone and tablet sizes. Assert semantics where controls, statuses, or validation require accessible announcements.

## Integration tests

Use integration tests for complete demonstration workflows using seeded local data, including normal completion, approval and correction, individual copies, team-queue claims, offline synchronization, conflict resolution, selective AI application, and demo-data reset. Tests must reset/reseed deterministically and never require an external service.

## Quality commands

Once Phase 01 initializes Flutter, run from the repository root:

```bash
dart format .
flutter analyze
flutter test
```

Run targeted tests during development, followed by the full suite before phase completion. Generated Drift/serialization sources may later be narrowly excluded from analyzer diagnostics; handwritten source, tests, ARB catalogs, and seeds must not be blanket-excluded.

## Completion gate

A phase cannot be considered complete when:

- analysis has errors;
- required tests fail;
- approved business rules are bypassed, including reliance on UI visibility for authorization;
- Arabic strings are missing or required RTL behavior is unverified; or
- documentation, decisions, scenario status, or progress tracking is outdated.

Environment limitations must be reported as warnings, never represented as passing commands. Failures caused by a change must be fixed before completion.

## Phase 01 executable suites

Run `flutter pub get`, `flutter gen-l10n`, `dart format .`, `flutter analyze`, and `flutter test`. Unit tests live under `test/unit`; widget/navigation tests live under `test/widget`. Provider containers exercise in-memory state transitions without persistence. Locale tests inspect `Directionality` rather than relying on English text. Router policy is tested as a pure role/path decision, while widget tests enter shells through overridden session state. Test both Arabic and English and include a large `TextScaler` on primary foundation layouts.
