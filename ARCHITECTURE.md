# Architecture

## 1. Product architecture overview

The target is a Flutter mobile application for Android and iOS with responsive phone/tablet presentation. It uses feature-based modules and separates presentation, domain, and data responsibilities. Riverpod will coordinate application state and dependency composition, `go_router` will provide structured navigation, and Drift/SQLite will eventually provide local persistence. These are decisions for later phases; Phase 00 contains no application implementation or packages.

## 2. Demo boundary

The demo is entirely local. Seeded data, persistence, connectivity states, synchronization outcomes, notification delivery, attachments, exports, authentication, and AI behavior are demonstrations rather than integrations. There is no backend, Firebase, cloud service, external API, external storage, production identity provider, real push service, or web portal. Project-management concepts (including projects, milestones, portfolios, Gantt charts, and budgets) are prohibited.

## 3. Module structure

`lib/app` owns application-wide routing, theme, localization wiring, and dependency composition. `lib/core` owns narrow technical capabilities shared across features. `lib/shared` owns stable cross-feature types and contracts. `lib/features/<feature>` owns one product capability.

When a feature is implemented, its shape is:

```text
feature_name/
  data/
    models/          # Local/transport representations and mappings
    repositories/    # Concrete local implementations
    sources/         # Drift, seed, or other local sources
  domain/
    entities/        # Business concepts independent of Flutter/storage
    repositories/    # Repository abstractions
    use_cases/       # Business operations and rules
  presentation/
    controllers/     # Riverpod state coordination
    pages/           # Routed screens
    widgets/         # Feature-owned UI components
```

Folders are created only when meaningful implementation arrives. Phase 00 tracks the approved top-level directories using `.gitkeep`; it does not create empty Dart classes.

## 4. Layer responsibilities and dependency direction

- **Presentation:** rendering, input, localized messages, accessibility, and delegation to controllers/use cases. It handles loading, empty, error, and offline views but does not decide business rules.
- **Domain:** entities, permissions, transitions, validation, domain services, and use cases. Important business rules belong here rather than in UI widgets.
- **Repository abstraction:** domain-facing contracts that hide persistence and service implementations.
- **Data:** DTOs/mappings, Drift access, seeded inputs, and concrete local/mock repositories.

The mandatory dependency rule is:

```text
Presentation
    ↓
Domain
    ↓
Repository abstraction
    ↓
Local mock implementation

Presentation must not directly access SQLite, files, seeded JSON, or mock services.
```

Dependencies point inward toward domain policy. Domain code must not import Flutter UI, Drift, file, seed, or router details. Concrete implementations are supplied at the composition root.

## 5. Repository and persistence boundaries

Screens consume use cases/controllers backed by repository interfaces. Local implementations map storage records to domain entities. Drift with SQLite will persist users, organization structures, roles/permissions, tasks and related collaboration records, notifications, audit events, sync operations, and settings. Seed JSON may initialize the database but is not ongoing state. IDs remain string/UUID-compatible and models retain local/server version and synchronization metadata for future compatibility.

Transactions, schema evolution, mappings, and queries remain inside data/storage code. Files and attachment metadata are accessed through replaceable attachment contracts. Audit events are immutable through normal application paths.

## 6. Offline and synchronization simulation

A replaceable connectivity service exposes online, offline, and unstable states. Local writes enqueue explicit operations with pending/failed/conflict metadata. A deterministic local sync simulator processes them, including retry and the approved conflicts. It makes no network call and never pretends that simulated state is authoritative backend synchronization. Assignment, permissions, cancellation, and official deadlines are treated as simulated server-controlled conflict fields.

## 7. Mock AI boundary

A replaceable AI assistant interface returns deterministic Arabic/English fixtures, can simulate latency/failure/unavailability, and never invokes an endpoint. Suggestions are labeled, explain source fields, require explicit selective or complete human confirmation, and cannot assign, approve, or judge performance automatically. Core workflows remain usable when the service is unavailable.

## 8. Localization architecture

Flutter's ARB-based localization generation will be established in Phase 01, with Arabic and English catalogs and Arabic treated as first class. Widgets consume generated localization accessors; no user-visible Arabic or English text is hardcoded. Locale drives RTL/LTR direction and appropriate date/number presentation. Translation completeness, RTL behavior, semantics, dynamic text, and accessible non-color cues are tested.

## 9. Navigation architecture

`go_router` will model typed/structured route definitions, role-specific branches, nested shells, task-detail deep links, and redirects for simulated authentication/demo profile state. Bottom navigation is used on phones and a navigation rail where appropriate on tablets. Route guards improve navigation behavior but are not security enforcement; domain authorization is always rechecked.

## 10. Role and permission enforcement

Current-user/profile state is provided centrally. Presentation hides or disables unauthorized affordances, while domain policies/use cases enforce role, organizational scope, assignment, confidentiality, transition, and reason requirements independently of UI visibility. Repositories also scope reads where appropriate. Sensitive attempts and important actions create audit events. Administrator status does not implicitly grant performance-data access.

## 11. Future backend replacement

Repository/service contracts and DTO mapping boundaries isolate local infrastructure. A later on-premises `Api...Repository` can replace a local implementation through dependency composition without screen rewrites. Authentication, organization data, attachments, synchronization, reporting, notifications, audit retention, and locally hosted AI remain replaceable ports. No future API DTO should leak into domain or presentation.

## 12. Testing strategy

Pure unit tests cover domain rules, repository mappings/logic, report calculations, and synchronization conflict policy. Widget tests cover localized RTL/LTR presentation, role navigation, states, forms, and actions. Integration tests cover complete seeded demo narratives using local implementations. Fakes are supplied through Riverpod provider overrides. See [`TESTING.md`](TESTING.md).

## 13. Prohibited dependencies and patterns

Do not add Firebase, cloud storage/database/AI/authentication, outbound analytics, ads, social login, external notification services, real external APIs, or project-management packages. Also prohibited are direct storage/service access from presentation, multiple state-management frameworks, business logic in widgets, hardcoded user-facing strings, untyped status strings, global mutable service locators, storage models leaking into domain/UI, authorization based only on button visibility, blanket analyzer exclusions, and speculative abstractions without a demonstrated use.

## Phase 01 implementation record

The composition root uses `ProviderScope`; Riverpod providers own locale, theme, connectivity, and the replaceable in-memory session boundary. `go_router` defines public and authenticated role paths, with pure role-access decisions and redirects. `MaterialApp.router` consumes generated-compatible ARB localization, centralized Material 3 light/dark themes, and system theme mode.

`AppResponsiveShell` selects bottom navigation below the tablet breakpoint and a navigation rail on tablets while constraining readable content width. Employee, manager, senior-management, and administrator configurations share this shell. Connectivity is explicitly a deterministic UI simulation: it performs no network checks, queues no work, and has no persistence. Authentication similarly stores no credentials and is designed to be replaced behind providers.

## Phase 01.5B reusable presentation architecture

Foundation screens use `AppPrimaryScrollView` rather than screen-specific bottom padding. On phones it derives its final inset from the centralized navigation height, the device safe-area inset, and standard content spacing; tablet content omits phone-only clearance. Surface roles are centralized in `AppSurfaceColors` as page, standard, elevated/selected, border, and disabled layers for consistent light/dark rendering.

`AppMetricCard`, `AppPanel`, settings selectors, and `AppTaskPreviewTile` remain display-only presentation primitives. The task preview accepts optional visual fields for progress, category, assignee, and offline state, but deliberately has no dependency on a task entity or repository before the approved task phase.

## Phase 02B database architecture

Presentation depends on repository interfaces. Riverpod binds those interfaces to local repositories; local repositories depend on focused DAOs and explicit mapper extensions; DAOs alone compose typed Drift queries. `appDatabaseProvider` owns and closes the database, while `databaseInitializationProvider` gates the one-time, post-schema seed and translates startup failures to `DataLayerException`/`AppError`. Tests can override `appDatabaseProvider` with an in-memory database.

## Phase 03 authentication architecture

Authentication presentation delegates to the Riverpod session controller and replaceable `AuthenticationService`. `LocalDemoAuthenticationService` resolves profile mappings through `UserRepository` and coordinates safe settings and audit events through repository contracts. Seeded status and role are authoritative. The startup gate seeds Drift before restore; active, locked, expired, and unauthenticated states drive guarded routing. Offline restore revalidates the user and expiry locally. A future on-premises adapter can replace the service without changing screens, domain sessions, or router policy.

## Phase 03B router and provider lifecycle

Phase 03B keeps one `GoRouter` instance for each provider scope. A small owned
`ChangeNotifier` bridges Riverpod session and locale changes to `refreshListenable`,
so redirects re-evaluate without reconstructing the router or introducing another
navigation state. Role guards and shells consume the database-derived role held by the
single session controller. Logout, expiry, lock, unlock, and profile replacement
therefore refresh the same router immediately.
