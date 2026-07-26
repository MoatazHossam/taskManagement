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
