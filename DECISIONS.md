# Architecture Decision Records

These decisions apply to the initial demo and are revisited only under their stated conditions. No package is installed by Phase 00.

## ADR-001 — Application type

**Context.** The specification targets an organization-wide, mobile-first demo with phone and tablet usability.

**Decision.** Build a Flutter mobile application. Android and iOS are required, including responsive tablet layouts. Flutter web and desktop are not approved product deliverables (developer convenience alone does not expand scope).

**Reason.** One Flutter codebase supports the required mobile platforms, localization, RTL, responsive presentation, and local-first demonstration.

**Alternatives considered.** Separate native Android/iOS apps would duplicate effort; web/desktop-first delivery conflicts with approved scope; a cross-platform framework other than Flutter conflicts with the master specification.

**Consequences.** Platform setup and testing must cover both mobile targets and tablet breakpoints. Web/desktop-specific product work is excluded.

**Reconsider when.** Product governance explicitly changes target platforms or validated platform constraints make Flutter unsuitable.

## ADR-002 — Demo architecture

**Context.** The demo is broad but must remain testable and replace local infrastructure later.

**Decision.** Use feature-based modules with presentation, domain, and data separation. Repository interfaces isolate UI/domain from storage. Initial implementations are local/mock; future API implementations must be replaceable without rewriting screens.

**Reason.** Clear feature ownership and inward dependency direction protect business rules while avoiding a monolith or distributed overengineering.

**Alternatives considered.** Layer-only global folders weaken feature ownership; direct database calls from screens prevent replacement; microservices are irrelevant to an offline mobile demo.

**Consequences.** Features require explicit contracts and mapping boundaries, with modest initial ceremony and strong test seams.

**Reconsider when.** Repeated implementation evidence shows the structure creates disproportionate overhead while the dependency and replacement guarantees can still be preserved.

## ADR-003 — State management: Riverpod

**Context.** One approach must manage role switching, connectivity, synchronization, Drift streams, navigation-relevant session state, and modular tests. No existing application approach exists.

**Decision.** Use Riverpod consistently; do not mix Bloc/Cubit, GetX, or another application state framework.

**Reason.** Provider composition naturally scopes role/current-user state, offline/connectivity state, sync status, and database streams. Provider overrides enable isolated tests, while feature-local providers support modular ownership without a global service locator.

**Alternatives considered.** Bloc/Cubit is viable but adds event/state ceremony for this demo. GetX is allowed only for a consistent existing investment, which is absent. Raw inherited widgets would require bespoke lifecycle and testing infrastructure.

**Consequences.** Phase 01 must select a compatible maintained Riverpod package/version and establish provider ownership/disposal conventions. Navigation listens only to intentional state projections.

**Reconsider when.** Riverpod becomes unsupported/incompatible, or an established codebase/team standard appears before significant implementation and migration cost is justified.

## ADR-004 — Local database: Drift with SQLite

**Context.** Demo changes must survive restarts and later expose streams, transactions, queries, migrations, and synchronization metadata.

**Decision.** Use Drift over SQLite. Later schemas will store users, departments, teams, roles, permissions, tasks, assignments, checklists, subtasks, comments, attachment metadata, notifications, audit events, synchronization operations, and settings.

**Reason.** Drift provides typed reactive SQLite access, migrations, transactions, and testability while keeping persistence local.

**Alternatives considered.** Seed JSON cannot persist ongoing changes; key-value storage is inadequate for relational/query needs; other object databases offer less alignment with the specified relational boundary; cloud databases are prohibited.

**Consequences.** Phase 02 must design schemas/migrations and mapping layers; generated code will be narrowly excluded from analysis and committed according to project policy. Widgets never import Drift.

**Reconsider when.** Platform support, licensing, maintenance, or measured technical constraints make Drift unsuitable and an equivalent local, replaceable solution is documented.

## ADR-005 — Localization

**Context.** Arabic and English are mandatory, with Arabic first class and complete RTL/LTR behavior.

**Decision.** Use Flutter ARB localization files and generated accessors. All user-visible strings are localized; locale controls RTL/LTR and culturally suitable formatting.

**Reason.** Flutter's supported localization pipeline enables catalog validation, tooling, pluralization, and complete translations without widget literals.

**Alternatives considered.** Handwritten maps lack tooling/type safety; hardcoded or runtime-only translations violate coverage and offline requirements; external translation services are prohibited.

**Consequences.** Every UI change includes Arabic and English entries and localization/RTL tests. Seeded bilingual content remains data, not widget literals.

**Reconsider when.** Flutter replaces its localization mechanism or approved requirements demand capabilities ARB cannot reasonably support.

## ADR-006 — Navigation: go_router

**Context.** Navigation must change by role and support nested shells, task-detail deep links, simulated authentication, and demo-profile guards.

**Decision.** Use `go_router` as the single structured routing solution.

**Reason.** Declarative routes, nested shell support, redirects, URL/deep-link parsing, and Flutter ecosystem support fit the required flows.

**Alternatives considered.** Navigator APIs alone require more bespoke guard/deep-link code; other routers add generation/abstraction without an existing investment; GetX navigation would couple the app to an unselected state framework.

**Consequences.** Central route definitions and redirect tests are required. Guards guide navigation but domain permission checks remain authoritative.

**Reconsider when.** Maintained `go_router` capabilities cannot satisfy validated nested/deep-link requirements or Flutter's supported routing direction materially changes.

## ADR-007 — Dependency injection

**Context.** Repositories and mock services must be swappable and tests must override dependencies consistently.

**Decision.** Use Riverpod providers as dependency injection and application state composition. Construct dependencies in `app/dependency_injection`; avoid a second DI container or global mutable service locator.

**Reason.** This minimizes frameworks and provides lifecycle management, dependency graphs, scoping, and test overrides compatible with ADR-003.

**Alternatives considered.** `get_it` or generated DI can work but duplicates a container; manual globals harm test isolation; constructor wiring alone becomes cumbersome at the composition root.

**Consequences.** Provider declarations must expose abstractions rather than concrete storage where consumers do not need implementation details.

**Reconsider when.** Riverpod DI cannot satisfy lifecycle/platform requirements or a demonstrably simpler solution emerges without mixing state frameworks.

## ADR-008 — Offline-first boundary

**Context.** The demo must visibly exercise offline behavior without a backend.

**Decision.** Simulate online, offline, unstable, pending sync, failed sync, retry, and conflict-resolution states locally. No real network synchronization is implemented in the initial deliverable.

**Reason.** Deterministic local state proves UX/business policy while preserving repeatable, backend-free demonstrations.

**Alternatives considered.** A real sync server violates scope; pretending all local writes are synchronized fails scenario requirements; OS connectivity alone cannot create deterministic demos.

**Consequences.** UI labels simulation state clearly, local operations retain audit/sync metadata, and tests control outcomes. No HTTP client is needed for sync.

**Reconsider when.** A separately approved phase supplies an on-premises backend contract and explicitly authorizes real integration.

## ADR-009 — AI boundary

**Context.** AI interactions are required for demonstration, but cloud/external calls and autonomous decisions are prohibited.

**Decision.** AI responses are deterministic local mock responses. Suggestions require explicit human confirmation; no real endpoint is called; and core functionality works when mock AI is unavailable.

**Reason.** This demonstrates flows repeatably, privately, offline, and without allowing AI to assign, approve, or judge people.

**Alternatives considered.** Cloud AI and external APIs violate scope; embedding a production model adds unjustified complexity; removing AI loses approved demo scenarios.

**Consequences.** Responses need bilingual fixtures, loading/failure modes, source/disclaimer labels, selective application, and confirmation tests.

**Reconsider when.** Product governance explicitly approves an internally hosted on-premises model and its privacy, availability, and human-control contract.

## ADR-010 — Backend boundary

**Context.** The initial demo must operate independently but later connect to an internally developed on-premises system.

**Decision.** No backend, Firebase, cloud database, real identity provider, external storage, or external API is part of the demo. Repository interfaces, service ports, and DTO mapping boundaries prepare for later on-premises implementations.

**Reason.** Ports preserve current offline independence and future replacement without coupling UI or domain rules to transport/storage.

**Alternatives considered.** Backend-as-a-service and Firebase violate explicit constraints; embedding API assumptions prematurely creates coupling; direct database use in UI prevents replacement.

**Consequences.** Local implementations remain authoritative only for the demo. IDs/version/sync metadata are future-compatible, and infrastructure DTOs never leak into presentation.

**Reconsider when.** An approved on-premises API contract and integration phase exist; even then, the abstractions and offline capability remain unless explicitly revised.
