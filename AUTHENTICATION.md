# Local Demo Authentication

Phase 03 uses `AuthenticationService` as a replaceable port. The Flutter UI delegates
to a Riverpod session controller; `LocalDemoAuthenticationService` alone coordinates
the seeded `UserRepository`, `SettingsRepository`, and `AuditRepository`. Drift rows
never enter the authentication domain model or presentation layer.

## Demo identities and credentials

One-tap profiles map exactly to the five stable seeded users. The database user status
and role relationship are authoritative and must agree with profile presentation
metadata. The deterministic, **non-production** credential pairs are `employee`,
`manager`, `executive`, `admin`, or `support`, each with password `demo123`.
Passwords are neither persisted nor audited.

## Session lifecycle and unlock simulation

Successful online authentication creates a 12-hour local session and a seven-day
offline-access window. Only safe identifiers, timestamps, status, and unlock method
are stored through `SettingsRepository`. Logout removes active-session metadata while
retaining language/theme settings and the optional last profile.

PIN unlock is a workflow simulation using the centralized constant `1234`, a
three-attempt threshold, and no persisted PIN. Simulated biometrics use explicit
success/failure controls and do not use `local_auth`, platform biometric APIs, or
biometric data.

Offline mode never permits a new credential/profile login. A previously authenticated,
unexpired session can be resolved against the same active seeded user and restored;
the global connectivity banner remains the visible offline indicator. Expired sessions
and offline windows are denied and audited.

## Replacement strategy

A future internal identity implementation can replace `AuthenticationService` in the
composition root. Router authorization consumes session state and the database-derived
role, not credential maps or the concrete local service. No external integration is
implemented in this phase.

## Phase 03B validation hardening

`SessionController` is the single authoritative runtime authentication state. Its
session, database user, database-derived role, presentation profile, and safe failure
code move together. Initialization begins in `initializing`, is gated by database
seeding, and is memoized per controller so rebuilds cannot repeat restoration. Locale
and theme state remain independent of authentication failures and logout.

Restoration requires every active-session field, validates the persisted role against
the active database user, parses timestamps as UTC, and fails closed for missing or
malformed values. Normal and offline expiry use exclusive boundaries. Invalid restore
clears only active authentication keys; language, theme, and the non-sensitive last
profile are preserved. Audit writes use workflow codes and are isolated from UI errors.
