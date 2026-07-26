# Organization Task Management Mobile Demo

## Purpose and status

This repository will contain a mobile-first organization task-management demo for Android and iOS, with responsive tablet layouts. Its purpose is to validate product concepts, role-aware workflows, navigation, Arabic/English user experience, management reporting, assignment and approval behavior, and local offline demonstrations before an on-premises backend exists.

**Current status:** Phase 02 is completed and was locally generated, analyzed, tested, and run successfully by the project owner. Phase 03 local demo authentication is implemented and awaiting SDK-equipped validation in this container. Phase 04 has not started.

The authoritative product and business-rules source is [`TASK_MANAGEMENT_DEMO_MASTER_SPEC.md`](TASK_MANAGEMENT_DEMO_MASTER_SPEC.md). Changes must be delivered one explicit phase at a time; no later phase should begin automatically.

## Approved demo scope

The eventual demo will:

- be a Flutter mobile application for Android and iOS, usable on phones and tablets;
- use local mock data and local persistence;
- provide Arabic as a first-class language and full English coverage, including RTL and LTR layouts;
- demonstrate profile/role switching and permission-aware behavior;
- simulate online, offline, unstable, pending, failed, and conflicting synchronization states locally;
- simulate notifications and deterministic AI suggestions locally, always requiring human confirmation; and
- use replaceable repository and service boundaries for later connection to an on-premises API.

These capabilities are planned, not currently implemented.

## Explicitly excluded

The demo must not include a real backend, web portal, production identity provider, real synchronization, external API calls, Firebase, cloud databases/storage/AI/authentication, external push/email/SMS, analytics that transmit data, advertising, social login, or unapproved integrations. Projects, portfolios, milestones, Gantt charts, budgets, payroll, disciplinary scoring, and other project-management concepts are out of scope. Flutter web and desktop are not approved product deliverables.

## Development prerequisites

Phase 01 should pin/document versions after initialization. Developers will need:

- the latest stable Flutter SDK available to the project;
- the Dart SDK supplied by Flutter;
- Android Studio/Android SDK for Android development;
- Xcode and CocoaPods on macOS for iOS development; and
- an Android emulator/device or iOS simulator/device.

Flutter initialization is still required. After Phase 01, the standard workflow will be:

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

The repository contains the Android/iOS Flutter foundation, ARB catalogs, and widget tests. The current execution container does not expose Flutter or Dart on `PATH`; run the commands below in an SDK-equipped environment before marking Phase 01.5B complete.

## Planned repository structure

```text
lib/
  app/                 # Routing, theme, localization, and dependency composition
  core/                # Cross-cutting primitives, storage, mock-service support, and widgets
  features/            # Independently owned product feature modules
  shared/              # Stable models, enums, repository contracts, and service contracts
```

Feature modules will adopt `data/`, `domain/`, and `presentation/` subtrees when the relevant phase implements them. Phase 00 preserves the approved top-level structure with `.gitkeep` files only; it does not pre-create fake implementations. See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the full map and dependency rules.

## Implementation approach

Work proceeds through Phases 00–16 in [`IMPLEMENTATION_PROGRESS.md`](IMPLEMENTATION_PROGRESS.md). Each phase must preserve scope boundaries, update documentation, add relevant tests, pass applicable quality checks, and stop before the next phase without an explicit request.

## Localization, offline, AI, and backend boundaries

- Flutter ARB files will provide Arabic and English strings from Phase 01. User-visible widget strings may not be hardcoded. Layout and tests must cover RTL and LTR.
- Offline and synchronization behavior is a local state-machine simulation only. No network synchronizer will be added to the demo.
- AI behavior is deterministic, local, optional, failure-tolerant, and confirmation-gated. It never communicates with a cloud model.
- Presentation depends on domain/repository contracts, not storage. Later API implementations may replace local repositories without rewriting screens; the intended backend is on premises.

## Coding standards

- Follow Effective Dart and use descriptive, domain-specific names.
- Prefer immutable models and typed enums over mutable state or magic strings.
- Keep business rules in domain services/use cases, never in widgets.
- Keep files cohesive; avoid unrelated responsibilities and excessively large widgets.
- Extract a reusable component only when it is genuinely reusable.
- Access data through repository abstractions; widgets must not access SQLite, files, seed JSON, or mock services.
- Centralize localization and theme tokens; do not hardcode user-visible strings or visual constants in features.
- Handle loading, empty, error, and offline states explicitly and accessibly.
- Document non-obvious business rules and add tests for rules and every defect fix.
- Do not suppress analyzer warnings without a documented, narrowly scoped justification.
- Do not retain commented-out production code or unexplained TODOs.
- Do not introduce cloud SDKs or any dependency outside the approved demo boundary.

## Package governance

No packages are added in Phase 00. Candidate packages must be reviewed in the phase that needs them for maintenance, licensing, platform support, offline operation, data behavior, and scope fit.

Approved categories are state management (Riverpod), routing (`go_router`), Flutter localization, Drift/SQLite, dependency injection through Riverpod providers, immutable-model/serialization tooling, local secure storage where justified, date formatting, and testing helpers. Phase 01/02 must choose the smallest coherent set rather than adding packages speculatively.

Prohibited categories include Firebase, cloud databases, cloud AI clients, externally transmitting analytics, advertising SDKs, social-login SDKs, external notification services, and packages that introduce projects, milestones, Gantt charts, or other unapproved project-management concepts. External-runtime service dependence is prohibited after dependencies have been installed.

## Related governance

- Architecture: [`ARCHITECTURE.md`](ARCHITECTURE.md)
- Decisions: [`DECISIONS.md`](DECISIONS.md)
- Test policy: [`TESTING.md`](TESTING.md)
- Seed scenario contracts: [`DEMO_SCENARIOS.md`](DEMO_SCENARIOS.md)
- Phase tracking: [`IMPLEMENTATION_PROGRESS.md`](IMPLEMENTATION_PROGRESS.md)

## Phase 01 Flutter foundation

Phase 01 establishes the runnable Android/iOS application foundation. The project was generated with Flutter 3.38.9 and Dart 3.10.8 (the generator-recorded SDK constraint was `^3.10.8`; this repository uses the equivalent explicit constraint `>=3.10.0 <4.0.0`). The current execution container does not expose either SDK command on `PATH`; install Flutter 3.38.9 stable before running validation.

```bash
flutter pub get
flutter gen-l10n
dart format .
flutter analyze
flutter test
flutter run
```

Android needs an Android SDK/device. iOS builds require macOS, Xcode, and CocoaPods. The temporary Android/iOS identifier is `com.example.organizationtaskmanager`; replace it before production signing.

ARB catalogs in `lib/l10n` are the source of truth. Run `flutter gen-l10n` after translation changes and treat any entries in `build/untranslated_messages.json` as failures. Arabic and English switch immediately and drive RTL/LTR direction.

Five in-memory demo profiles are available from the simulated login. Profile/settings can switch language, light/dark/system theme, and online/offline/unstable simulation. No credential is validated or persisted. **Task entities, task workflows, task data, persistence, synchronization, reports, administration behavior, backend integration, and AI are not implemented in Phase 01.**

## Phase 03 demo authentication

Authentication is a local workflow simulation, not production security. The main path is one-tap selection of one of the five database-backed demo profiles. Credential login accepts `employee`, `manager`, `executive`, `admin`, or `support` with demo-only password `demo123`. The password is never stored or audited. PIN unlock uses simulated PIN `1234`; no PIN or biometric data is stored, and no device biometric API is used. See [`AUTHENTICATION.md`](AUTHENTICATION.md).

## Phase 03B validation status

Authentication provider, router, widget, and local integration test structures are now
present, with fail-closed session restoration and reactive router refresh hardening.
Phase 03 remains in progress until an SDK-equipped environment passes generation,
analysis, all tests, debug APK build, and runtime validation. Phase 04 remains not
started.


## Emergency deadline persistence pivot (2026-07-26)

Drift/SQLite, generated database code, DAOs, companions, SQL, database mappers, and build_runner are removed from the active deadline demo. The historical Phase 02 implementation is retained under `archive/drift_phase_02/` outside active compilation.

The active application uses one deterministic, Flutter-independent `DemoDataStore` and typed in-memory repository implementations. Repository interfaces remain the application boundary and are ready to be replaced by future on-premises API adapters without presentation changes. Runtime mutations and the simulated authentication session reset whenever the application restarts; this is demo state, not production persistence. Authentication roles are a repository-authoritative demo identity. No networking, cloud, Firebase, backend, real biometric, or external identity integration was added.

Phase 04 was not started.

## Organization and permission demo (Phase 04)

Use Ahmed to inspect self-level access, Sara for the full directory and manager assignment authority, Omar for executive reporting without administration, Laila for administration and directory access without executive reporting, and Khaled for Technical Support Queue-scoped claim/release diagnostics. Open **Access summary** from Profile. Managers, senior management, and administrators can browse the read-only organization structure; no organization or permission editing is included. See [AUTHORIZATION.md](AUTHORIZATION.md) for the complete matrix and scope rules.

## Phase 05 demo walkthrough

Sign in as Ahmed to browse his read-only tasks, search a deterministic scenario, choose
a quick view, and open details/timeline. Sara receives organization-aware results,
Omar can inspect critical/restricted work granted by permissions, while Laila remains
separated from operational tasks. Saved filters are an in-memory simulation and reset
when the application restarts.

## Phase 05B task experience

The read-only task experience provides role-specific task pages, manager scope selection, senior-management critical triage, compact responsive cards, advanced filters and sorting, session-only saved filters, and localized grouped details. Task progress retains left-to-right mathematical direction in both locales. No task actions, backend, database, cloud, or real synchronization are included; Phase 06 has not started.
