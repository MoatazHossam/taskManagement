Organization Task Management Mobile App

Master Product and Demo Implementation Specification for Codex

Document purpose:This file is the single source of truth for building the initial mobile demo of an organization-wide task management application.

Initial deliverable:A polished, fully navigable Flutter demo application that demonstrates every approved business feature using local mock data and local persistence. The demo must not connect to a real backend, cloud service, production identity provider, or external AI model.

Target audience:Codex, mobile developers, UI/UX developers, business analysts, testers, and reviewers.

Document status:Approved baseline for the demo implementation.

1. Product Vision

Build a mobile-first task management application for all employees inside an organization.

The application must allow managers to create, assign, reassign, monitor, and evaluate work while allowing employees to manage assigned tasks and create personal tasks assigned only to themselves.

The application must demonstrate:

Clear accountability.

Single-user, multi-user, and team assignment.

Offline-first behavior.

Arabic-first user experience.

English support.

Management dashboards.

Employee performance reporting.

Configurable approval behavior.

Task collaboration.

Task evidence and audit history.

A local AI feature demonstration.

Mobile-only administration.

A future-ready architecture that can later connect to an on-premises backend and an internally developed organizational system.

The demo must look and behave like a real enterprise application even though all data is local.

2. Demo Scope and Technical Boundary

2.1 Demo Objective

The demo is intended to validate:

Product concept.

Navigation.

User roles.

Task workflows.

User experience.

Arabic and English layouts.

Management reporting.

Offline behavior.

Assignment models.

Approval behavior.

Administrative configuration.

AI-assisted interactions.

It is not intended to validate:

Production backend integration.

Real network synchronization.

Enterprise authentication.

Real push notifications.

Real AI inference.

Production security infrastructure.

Real-time multi-device collaboration.

Production database performance.

2.2 Mandatory Demo Constraints

The demo must:

Be implemented in Flutter.

Run without a backend.

Use local mock repositories and services.

Persist demo data locally.

support Arabic from the first screen.

Support English.

Support right-to-left and left-to-right layouts.

Include role switching for demonstration.

Include seeded realistic organizational data.

Include simulated offline and online modes.

Include simulated synchronization.

Include simulated synchronization conflicts.

Include simulated notifications.

Include simulated AI responses.

Include all approved feature areas.

Remain modular so mock services can later be replaced by API implementations.

Avoid project-management concepts entirely.

Avoid any real external API call.

Avoid Firebase, cloud databases, cloud AI, and cloud authentication.

Be suitable for phones and usable on tablets.

2.3 Explicitly Prohibited in the Demo

Do not implement:

A real backend.

A real web administration portal.

Microsoft Entra ID.

Microsoft 365 integration.

Outlook integration.

Microsoft Teams integration.

Google services.

Firebase.

Real push notifications.

Real email delivery.

Real SMS.

Real AI API calls.

Real cloud storage.

Projects.

Project portfolios.

Milestones.

Gantt charts.

Project budgets.

Payroll integration.

HR disciplinary scoring.

Public customer access.

Direct integration with the future internal system.

Real biometric authentication unless implemented only as an optional local UI demonstration.

3. Product Principles

The implementation must follow these principles:

Accountability first: every operational task must have a clear accountable owner or a clearly defined assignment model.

Managers control organizational work: managers create, assign, and reassign organizational tasks.

Employees control only their personal tasks: employees may create tasks only for themselves.

No ambiguous multi-assignee behavior: each multi-user task must use a defined assignment mode.

Offline-first design: the mobile app must remain useful without connectivity.

Arabic-first design: Arabic usability must be treated as a core requirement, not a later translation.

Human confirmation for AI: AI generates suggestions only.

Meaningful reporting: reports must explain context and not rely only on raw task counts.

Auditability: important actions must appear in the activity history.

Future backend readiness: presentation and business logic must not be tightly coupled to mock storage.

No overengineering: use a modular mobile architecture, not unnecessary distributed patterns.

Demo completeness: every approved capability must have at least one visible and testable scenario.

4. Target Platforms

4.1 Required

Android.

iOS.

Responsive phone layouts.

Reasonable tablet layouts.

4.2 Optional During the Demo

Flutter desktop or web may be used only for developer convenience, but they are not part of the approved product scope.

5. Technology and Architecture Direction

5.1 Flutter

Use the latest stable Flutter version available in the development environment.

5.2 Recommended Application Layers

Use a clean modular structure:

lib/
  app/
    routing/
    theme/
    localization/
    dependency_injection/
  core/
    constants/
    errors/
    extensions/
    utilities/
    widgets/
    storage/
    mock_services/
  features/
    authentication/
    home/
    tasks/
    notifications/
    calendar/
    reports/
    administration/
    profile/
    ai_assistant/
    sync_center/
  shared/
    models/
    enums/
    repositories/
    services/

Feature folders should use a consistent internal structure:

feature_name/
  data/
    models/
    repositories/
    sources/
  domain/
    entities/
    repositories/
    use_cases/
  presentation/
    controllers/
    pages/
    widgets/

A simplified variation is acceptable if it preserves:

Separation of UI from data access.

Replaceable repositories.

Testable business rules.

Clear feature ownership.

5.3 State Management

Use one consistent state-management approach across the entire project.

Recommended options:

Riverpod.

Bloc/Cubit.

GetX only if the existing team has already standardized on it.

Do not mix multiple state-management frameworks.

5.4 Local Persistence

Use a local database abstraction suitable for replacement later.

Recommended:

Drift with SQLite.

Store:

Users.

Departments.

Teams.

Tasks.

Assignments.

Checklists.

Subtasks.

Comments.

Attachments metadata.

Notifications.

Audit events.

Sync operations.

App settings.

Mock report data.

For a simpler early prototype, seeded JSON may initialize the database, but ongoing demo changes must persist.

5.5 Repository Pattern

All screens must consume repository interfaces.

Example:

abstract interface class TaskRepository {
  Future<List<Task>> getTasks(TaskFilter filter);
  Future<Task?> getTaskById(String taskId);
  Future<Task> createTask(CreateTaskCommand command);
  Future<Task> updateTask(UpdateTaskCommand command);
  Future<void> addComment(AddCommentCommand command);
  Future<void> synchronize();
}

The initial implementation must use:

LocalMockTaskRepository

A future implementation may use:

ApiTaskRepository

The UI must not know which implementation is active.

6. Demo Personas and Seeded Users

The app must include a role-switching screen accessible from the demo login or profile menu.

6.1 Seeded Personas

Persona A — Employee

Name: Ahmed Hassan

Arabic name: أحمد حسن

Role: Employee

Department: Operations

Team: Field Operations

Manager: Sara Mahmoud

Permissions:

View assigned tasks.

Create tasks for self only.

Update own task progress.

Add comments and attachments.

Report blockers.

Request deadline extensions.

Complete tasks that do not require approval.

Submit tasks that require approval.

View personal statistics.

Persona B — Manager

Name: Sara Mahmoud

Arabic name: سارة محمود

Role: Manager

Department: Operations

Managed teams:

Field Operations

Service Coordination

Permissions:

Create tasks.

Assign tasks to employees.

Assign tasks to teams.

Create multi-user assignments.

Reassign tasks.

Change deadlines and priorities.

Approve or return tasks when required.

View team reports.

View team workload.

Create recurring tasks.

Use task templates.

Persona C — Senior Management

Name: Omar Al Nuaimi

Arabic name: عمر النعيمي

Role: Senior Management

Scope: Organization-wide reports

Permissions:

View executive dashboard.

View department comparisons.

View employee performance within permitted scope.

Drill down into tasks.

View escalations.

Export simulated reports.

No unrestricted task modification by default.

Persona D — Administrator

Name: Laila Youssef

Arabic name: ليلى يوسف

Role: System Administrator

Permissions:

Manage users.

Manage departments and teams.

Configure categories and priorities.

Configure approval and escalation rules.

View synchronization status.

View audit logs.

Configure application settings.

Administrator access does not automatically include employee performance data.

Persona E — Team Queue Member

Name: Khaled Ibrahim

Arabic name: خالد إبراهيم

Role: Employee

Department: IT Support

Team: Technical Support Queue

Demo purpose:

Claim a team task.

Return a task to the queue.

Show team-queue ownership behavior.

6.2 Demo Login

The login screen must provide:

Arabic and English language switch.

Username and password fields for visual completeness.

A “Demo Profiles” section.

One-tap entry as each seeded persona.

A visible note that authentication is simulated.

Optional PIN or biometric demonstration after the first login.

No real authentication service is required.

7. Organization Structure

Seed the following example structure:

Organization
├── Executive Management
├── Operations Department
│   ├── Field Operations Team
│   └── Service Coordination Team
├── Finance Department
│   ├── Accounts Payable Team
│   └── Reporting Team
├── Human Resources Department
│   ├── Recruitment Team
│   └── Employee Services Team
└── Information Technology Department
    ├── Technical Support Queue
    └── Application Support Team

The demo must support:

Departments.

Teams.

Direct manager relationships.

Employees belonging to one primary department.

Employees belonging to one or more teams when needed.

Manager scope.

Cross-department assignment permission as a configurable setting.

8. Roles and Permissions

8.1 Employee Permissions

An employee can:

View assigned tasks.

View tasks where they are a contributor.

View tasks where they are a follower.

Create a task assigned only to themselves.

Edit a self-created task according to business rules.

Acknowledge a manager-assigned task.

Start a task.

Pause a task.

Resume a task.

Report a blocker.

Update progress.

Add comments.

Add attachments.

Add voice-note metadata and simulated playback.

Complete a task without approval.

Submit a task for approval.

Request an extension.

View their own dashboard.

View their own performance indicators.

An employee cannot:

Assign tasks to another person.

Reassign organizational tasks.

Change the manager-selected assignment mode.

Change organizational task priority without permission.

View unauthorized employee reports.

Configure system settings.

8.2 Manager Permissions

A manager can:

Create organizational tasks.

Assign to a single employee.

Assign to a lead owner with contributors.

Generate individual copies for multiple employees.

Assign to a team queue.

Assign to self.

Reassign.

Change priority.

Change due dates.

Add followers.

Approve completion when required.

Return for correction.

Cancel.

Reopen.

View managed employees.

View team workload.

View team performance.

Create task templates.

Create recurring tasks.

Configure selected task-level escalation behavior.

8.3 Senior Management Permissions

Senior management can:

View executive dashboards.

Compare departments.

See overdue and critical tasks.

Review blocker patterns.

Review workload distribution.

View permitted employee performance.

Drill into task details.

View audit history.

Export a simulated report.

Avoid operational modification unless a separate permission is enabled.

8.4 Administrator Permissions

Administrator can:

Manage local demo users.

Activate and deactivate users.

Manage departments.

Manage teams.

Manage reporting lines.

Manage roles.

Manage permissions.

Manage task categories.

Manage task priorities.

Manage confidentiality levels.

Manage approval rules.

Manage escalation rules.

Manage notification templates.

Manage sync settings.

View audit logs.

Reset demo data.

9. Assignment Models

The task creation flow must require one of the following assignment modes.

9.1 Single Owner

One employee is accountable.

Required fields:

Assignee.

Due date.

Priority.

Approval required or not.

Completion behavior:

Assignee completes directly when approval is not required.

Assignee submits for approval when approval is required.

9.2 Lead Owner with Contributors

One employee remains accountable.

Required fields:

Lead owner.

One or more contributors.

Rules:

Only the lead owner can complete or submit the parent task.

Contributors can add updates, comments, and complete assigned subtasks.

Reports attribute accountability to the lead owner.

Contributor activity appears separately.

9.3 Individual Copies

The manager selects multiple employees and creates independent task instances.

Rules:

Each employee receives a unique task record.

Each record has independent status.

Each record may have independent evidence and comments.

The manager can view aggregate completion.

The demo must include a bulk compliance or training example.

9.4 Team Queue

The task is assigned to a team.

Rules:

Initially no individual owner is required.

An authorized team member may claim the task.

A team leader may assign the task to a team member.

A claimed task records the claiming user and time.

An authorized user may return the task to the queue with a reason.

Reports show queue waiting time and claimed execution time separately.

9.5 Shared Completion

Shared completion may be demonstrated as an advanced assignment mode.

Supported completion policies:

All assignees must confirm.

Any assignee may complete.

Manager confirms overall completion.

This mode must be clearly labeled as potentially reducing individual accountability.

10. Task Lifecycle

10.1 Core Statuses

Draft.

Assigned.

Acknowledged.

In Progress.

Paused.

Blocked.

Completion Requested.

Returned for Correction.

Completed.

Declined.

Cancelled.

Reopened.

Expired.

10.2 Standard Flow Without Approval

Draft
→ Assigned
→ Acknowledged
→ In Progress
→ Completed

10.3 Standard Flow With Approval

Draft
→ Assigned
→ Acknowledged
→ In Progress
→ Completion Requested
→ Completed

10.4 Return Flow

Completion Requested
→ Returned for Correction
→ In Progress
→ Completion Requested

10.5 Blocked Flow

In Progress
→ Blocked
→ In Progress

10.6 Reopening Flow

Completed
→ Reopened
→ In Progress

10.7 Required Transition Reasons

A reason is mandatory for:

Decline.

Reassignment.

Block.

Deadline-extension request.

Deadline-extension rejection.

Return for correction.

Cancellation.

Reopening.

Administrative override.

Return to team queue.

10.8 Transition Permissions

Every task-status action must be validated through a business-rule service.

Do not enable status changes merely because a button is visible.

11. Task Data Model

11.1 Task Entity

Required fields:

id
taskNumber
titleAr
titleEn
descriptionAr
descriptionEn
creatorId
creatorRole
assignmentMode
leadOwnerId
assignedTeamId
priorityId
categoryId
status
confidentialityLevel
plannedStartDate
dueDate
dueTime
estimatedEffortMinutes
progressPercentage
approvalRequired
approverId
approvalStatus
isRecurring
recurrenceRuleId
createdAt
updatedAt
lastSyncedAt
localVersion
serverVersion
isLocallyModified
isDeleted

11.2 Assignment Entity

id
taskId
userId
assignmentRole
assignmentStatus
assignedAt
acknowledgedAt
completedAt
contributionPercentage

Assignment roles:

Owner.

Lead owner.

Contributor.

Shared assignee.

Follower.

Queue claimant.

Approver.

11.3 Checklist Item Entity

id
taskId
titleAr
titleEn
isMandatory
isCompleted
completedBy
completedAt
sortOrder

11.4 Subtask Entity

A subtask may use the same Task entity with:

parentTaskId
isSubtask

Rules:

No project relationship.

Subtask may have its own assignee.

Mandatory subtasks may prevent parent completion.

Subtask depth should be limited to one level in the demo.

11.5 Comment Entity

id
taskId
authorId
body
createdAt
updatedAt
isEdited
replyToCommentId
mentionUserIds
isDeleted
syncStatus

11.6 Attachment Entity

id
taskId
commentId
fileName
fileType
localPath
mockRemotePath
sizeBytes
attachmentCategory
uploadedBy
createdAt
syncStatus

Attachment categories:

Document.

Image.

Voice note.

Completion evidence.

Reference.

Other.

11.7 Blocker Entity

id
taskId
reportedBy
blockerType
description
responsibleParty
startedAt
resolvedAt
resolutionNote
status

11.8 Extension Request Entity

id
taskId
requestedBy
currentDueDate
requestedDueDate
reason
status
reviewedBy
reviewedAt
reviewNote

11.9 Approval Entity

id
taskId
approverId
status
submittedAt
reviewedAt
reviewComment

11.10 Audit Event Entity

id
taskId
eventType
performedBy
performedAt
oldValue
newValue
reason
deviceId
isOfflineEvent
syncStatus

11.11 Notification Entity

id
recipientId
type
titleAr
titleEn
messageAr
messageEn
taskId
createdAt
readAt
isRead
deliveryChannel
deliveryStatus

11.12 Synchronization Operation Entity

id
entityType
entityId
operationType
payload
createdAt
retryCount
status
errorMessage
conflictType

12. Task Business Rules

BR-001 — Employee Self-Assignment

An employee may create a task only when the assignee is the same employee.

BR-002 — Manager Assignment Scope

A manager may assign tasks only within their authorized organizational scope unless cross-department permission is enabled.

BR-003 — Reassignment Permission

Only an authorized manager may reassign an organizational task.

BR-004 — Reassignment Reason

Reassignment requires a mandatory reason and an audit record.

BR-005 — Completion Approval

Approval is optional and configured per task or task category.

BR-006 — Completion Evidence

Selected task categories may require at least one completion-evidence attachment.

BR-007 — Mandatory Checklist

A task cannot complete while mandatory checklist items remain incomplete.

BR-008 — Mandatory Subtasks

A parent task cannot complete while mandatory subtasks remain incomplete.

BR-009 — Blocked Task

A blocked task requires a blocker reason and may require a responsible party.

BR-010 — Progress Validation

Progress must be between 0 and 100.

BR-011 — Completion Progress

Completing or submitting a task sets progress to 100 unless the workflow explicitly permits otherwise.

BR-012 — Declining Assignment

An employee may decline only when the task category or configuration allows it.

BR-013 — Self-Created Task Visibility

Self-created personal tasks are visible to the employee and may optionally be visible to the manager according to configuration.

BR-014 — Confidentiality

Users may view a task only when role, organizational scope, and confidentiality permission permit access.

BR-015 — Completed Task Editing

Completed tasks are read-only except for reopening by an authorized user.

BR-016 — Team Queue Claim

Only active members of the assigned team may claim a team-queue task.

BR-017 — Queue Claim Conflict

When two users claim the same task, only the first accepted claim succeeds; the demo must simulate the losing conflict.

BR-018 — Individual Copies

Each generated copy must maintain independent status and audit history.

BR-019 — AI Confirmation

AI-generated content must not be saved without explicit user confirmation.

BR-020 — Offline Actions

Offline actions must be stored in the synchronization queue and visibly marked as pending.

BR-021 — Server-Controlled Conflict Fields

In the future real system, assignment, permissions, cancellation, and official deadline changes are server-controlled fields. The demo conflict simulator must reflect this rule.

BR-022 — Audit Immutability

Audit events cannot be edited or deleted through the normal UI.

13. Task Priorities

Seed the following priorities:

Low.

Normal.

High.

Urgent.

Critical.

Each priority must include:

Arabic label.

English label.

Icon or visual indicator.

Default reminder policy.

Default escalation policy.

Sort order.

Do not rely only on color. Use text and icons for accessibility.

14. Task Categories

Seed the following categories:

General Administrative.

Operations.

Finance.

Human Resources.

Information Technology.

Compliance.

Maintenance.

Report Preparation.

Review and Approval.

Training and Acknowledgement.

Each category may define:

Default approval requirement.

Default completion-evidence requirement.

Default priority.

Allowed decline behavior.

Default checklist template.

Default estimated effort.

Escalation rule.

15. Confidentiality Levels

Seed:

Public Internal.

Internal.

Confidential.

Restricted.

The demo must visibly show:

A confidentiality badge.

Access-denied scenarios.

Redacted task preview for unauthorized users.

Audit entry for attempted access where appropriate.

16. Main Navigation

Navigation must change based on the active role.

16.1 Employee Navigation

Home.

My Tasks.

Calendar.

Notifications.

Profile.

A floating or prominent action may allow “Create Personal Task.”

16.2 Manager Navigation

Home.

Team Tasks.

Create Task.

Approvals.

Reports.

Profile.

16.3 Senior Management Navigation

Executive Dashboard.

Departments.

Critical Tasks.

Reports.

Profile.

16.4 Administrator Navigation

Administration Home.

Users.

Organization.

Configuration.

Sync Center.

Audit.

Settings.

Use responsive navigation:

Bottom navigation on phones.

Navigation rail on tablets where appropriate.

17. Screen Inventory

Every screen listed below must exist in the demo.

17.1 Startup and Authentication

Splash screen.

Language selection.

Demo login.

Demo profile selection.

Simulated PIN or biometric screen.

Offline-access warning.

Session-expiry demonstration.

17.2 Employee Screens

Employee home dashboard.

My Tasks.

Task list.

Task Kanban view.

Task calendar view.

Task filter sheet.

Saved filters.

Task details.

Task activity timeline.

Create personal task.

Edit personal task.

Acknowledge task.

Start task.

Update progress.

Pause task.

Report blocker.

Resolve blocker.

Request deadline extension.

Complete task.

Submit for approval.

Add comment.

Reply to comment.

Mention user.

Add simulated photo.

Add simulated document.

Record simulated voice note.

Checklist interaction.

Subtask list.

Create permitted subtask.

Notifications center.

Personal calendar.

Personal performance.

Profile.

Language and appearance settings.

Offline and synchronization status.

17.3 Manager Screens

Manager home dashboard.

Create organizational task.

Select assignment mode.

Assign single owner.

Assign lead owner and contributors.

Generate individual task copies.

Assign to team queue.

Shared-completion configuration.

Add checklist.

Add subtasks.

Set approval requirement.

Set completion-evidence requirement.

Set recurrence.

Set reminder and escalation.

Team task list.

Team Kanban.

Team workload.

Unassigned or queue tasks.

Reassign task.

Change due date.

Change priority.

Approvals inbox.

Review completion evidence.

Approve completion.

Return for correction.

Approve or reject extension.

Cancel task.

Reopen task.

Task templates.

Recurring task rules.

Team performance reports.

Employee detail report.

Export-report simulation.

17.4 Senior Management Screens

Executive summary.

Department comparison.

Overdue analysis.

Critical-task list.

Blocker analysis.

Reassignment and reopening analysis.

Employee-performance overview.

Meaning-layer insight cards.

Department drill-down.

Task drill-down.

Export simulation.

17.5 Administrator Screens

Administration dashboard.

User list.

User details.

Add or edit mock user.

Activate or deactivate user.

Department list.

Team list.

Organization hierarchy.

Manager relationship editor.

Role list.

Permission matrix.

Task categories.

Priority configuration.

Confidentiality configuration.

Approval rules.

Escalation rules.

Notification templates.

Sync settings.

Sync queue.

Conflict list.

Audit log.

Application settings.

Reset demo data.

17.6 AI Demonstration Screens

AI task-description assistant.

AI checklist generator.

AI task summary.

AI management summary.

Arabic-English rewriting assistant.

AI disclaimer and confirmation dialog.

AI-unavailable fallback state.

18. Home Dashboards

18.1 Employee Dashboard

Show:

Tasks due today.

Overdue tasks.

Tasks in progress.

Blocked tasks.

Tasks awaiting approval.

Recently assigned tasks.

Upcoming deadlines.

Personal completion rate.

Quick actions.

Offline status.

Pending synchronization count.

18.2 Manager Dashboard

Show:

Active team tasks.

Overdue team tasks.

Critical tasks.

Blocked tasks.

Tasks waiting for approval.

Team queue waiting tasks.

Employees with high workload.

Employees with no active tasks.

Upcoming recurring tasks.

Meaning-layer insight card.

Quick task creation.

18.3 Senior Management Dashboard

Show:

Organization task status.

On-time completion rate.

Overdue rate.

Critical overdue count.

Blocker concentration.

Reopening rate.

Reassignment rate.

Department comparison.

Management insight narrative.

Risks requiring attention.

18.4 Administrator Dashboard

Show:

Active users.

Inactive users.

Departments.

Teams.

Pending sync operations.

Sync conflicts.

Unresolved configuration warnings.

Recent audit events.

Demo database status.

19. Task List and Filtering

19.1 Views

Support:

List.

Kanban.

Calendar.

Today.

This week.

Overdue.

Blocked.

Awaiting approval.

Team queue.

19.2 Filters

Support:

Status.

Priority.

Due-date range.

Creation-date range.

Creator.

Owner.

Contributor.

Team.

Department.

Category.

Assignment mode.

Approval status.

Confidentiality.

Blocked state.

Recurring state.

Locally modified state.

Pending synchronization state.

19.3 Sorting

Support:

Due date.

Priority.

Creation date.

Last update.

Progress.

Estimated effort.

Task number.

19.4 Saved Filters

Users may:

Save a named filter.

Set a default filter.

Delete a saved filter.

Demonstrate local persistence.

20. Task Creation Flow

Use a multi-step form.

Step 1 — Basic Information

Arabic title.

English title, optional.

Arabic description.

English description, optional.

Category.

Priority.

Confidentiality.

Step 2 — Assignment

Manager selects:

Single owner.

Lead owner with contributors.

Individual copies.

Team queue.

Shared completion.

Employee creation must automatically select:

Single owner.

Current employee.

Step 3 — Schedule

Planned start.

Due date.

Due time.

Estimated effort.

Recurrence.

Reminder policy.

Step 4 — Execution Requirements

Checklist.

Subtasks.

Completion evidence requirement.

Approval requirement.

Approver.

Decline allowed.

Extension allowed.

Step 5 — Attachments

Simulated image.

Simulated document.

Simulated voice note.

Link.

Step 6 — Review

Show a complete review before creation.

The user must explicitly confirm.

21. Collaboration Features

21.1 Comments

Support:

Add comment.

Reply.

Edit own comment.

Show edited indicator.

Mention users.

Delete own comment only when permitted.

Offline comment indicator.

Pending-sync indicator.

21.2 Attachments

The demo must support simulated local selection using bundled assets or generated placeholder files.

Show:

File name.

File type.

File size.

Uploader.

Upload date.

Sync state.

Preview for demo images.

Simulated audio player for voice notes.

21.3 Activity Timeline

Display:

Creation.

Assignment.

Acknowledgement.

Status changes.

Progress changes.

Comments.

Attachment additions.

Reassignment.

Deadline changes.

Priority changes.

Approval actions.

Blocker actions.

Sync events.

Conflict resolutions.

22. Recurring Tasks

Support recurrence patterns:

Daily.

Weekly.

Monthly.

Quarterly.

Annually.

Custom weekdays.

Last working day of the month.

Demo behavior:

Store a recurrence rule.

Generate several example occurrences locally.

Show each occurrence as an independent task.

Show recurrence source.

Allow a manager to pause a recurrence rule.

Allow editing future occurrences in a simulated way.

No backend scheduler is required.

23. Notifications

23.1 Simulated Notification Types

New assignment.

Task acknowledged.

Due soon.

Overdue.

Critical escalation.

New comment.

Mention.

Reassignment.

Extension request.

Extension decision.

Completion submitted.

Completion approved.

Completion returned.

Queue task available.

Queue task claimed.

Sync completed.

Sync failed.

Conflict detected.

23.2 Notification Center

Support:

All.

Unread.

Task notifications.

Approval notifications.

Escalations.

Synchronization notifications.

Mark as read.

Mark all as read.

Open linked task.

23.3 Local Reminder Simulation

Allow users to schedule a local reminder visually.

No real external push service is required.

24. Offline-First Demonstration

24.1 Connectivity Simulator

Add a developer/demo control that can toggle:

Online.

Offline.

Unstable connection.

The active state must be visible in the UI.

24.2 Offline Actions

While offline, users must be able to:

View cached tasks.

Create personal tasks.

Update progress.

Add comments.

Complete checklist items.

Add attachments.

Report blockers.

Request completion.

Save manager-created task drafts.

Queue permitted actions.

24.3 Pending Synchronization

Show:

Pending operation count.

Entity type.

Operation.

Created time.

Retry count.

Status.

Manual retry.

Cancel local operation when safe.

24.4 Synchronization Simulation

When switching online:

Process pending operations.

Show progress.

Mark successful operations.

Simulate selected failures.

Create a conflict scenario.

Show completion summary.

24.5 Conflict Scenarios

The demo must include:

Conflict A — Manager Reassignment

Employee updates progress offline.

Manager version shows the task reassigned.

The app explains that assignment is server-controlled.

Progress note may be retained as an audit/comment.

Ownership follows the simulated server version.

Conflict B — Team Queue Claim

Two users claim the same queue task.

One claim succeeds.

The second receives a conflict message.

Conflict C — Concurrent Description Edit

Local and simulated server descriptions differ.

User can:

Keep server version.

Keep local version.

Merge manually.

Conflict D — Cancelled Task

Employee completes a task offline.

Simulated server version shows the task cancelled.

Cancellation wins.

Offline completion evidence remains visible in audit history.

24.6 Sync Status Indicators

Use consistent indicators:

Synced.

Pending.

Failed.

Conflict.

Local only.

Do not rely only on color.

25. Management Reports

25.1 Core Metrics

Show:

Total assigned tasks.

Active tasks.

Completed tasks.

On-time completion rate.

Overdue rate.

Average completion duration.

Average delay.

Blocked task count.

Total blocker duration.

Reassignment rate.

Reopening rate.

Extension-request rate.

Approval-return rate.

Evidence-compliance rate.

Queue waiting time.

Workload by employee.

Workload by team.

Tasks by category.

Tasks by priority.

25.2 Employee Performance

The report must avoid ranking employees only by completed task count.

Show:

Assigned tasks.

Completed tasks.

On-time completion.

Average estimated effort.

Actual completion duration.

Blocked duration.

Number of external blockers.

Reopening rate.

Return-for-correction rate.

Contribution to shared tasks.

Queue response time.

Workload score.

Context notes.

25.3 Meaning Layer

Every major report screen must include a narrative card that explains:

Why the result matters.

Possible causes.

Whether the result appears positive, negative, or unusual.

Suggested management action.

Additional information needed.

Risk of no action.

Seed examples:

Example A — Overdue Concentration

“Operations has 28% overdue tasks. Most delays are concentrated in tasks waiting for supplier information. Reassignment alone may not solve the problem; management should review the external dependency and due-date assumptions.”

Example B — High Completion, High Reopening

“The team completed 92% of assigned tasks, but 31% were reopened. This may indicate unclear completion criteria or inconsistent review standards.”

Example C — Low Task Count with High Complexity

“Ahmed completed fewer tasks than the team average, but his assigned tasks have the highest estimated effort and longest external-blocker duration. Raw task count should not be interpreted as underperformance.”

25.4 Report Export Simulation

Provide:

Export button.

Format choices:

PDF.

Excel.

Date range.

Scope.

Simulated success message.

Audit event.

A real file export is optional for the first demo, but the interaction must be complete.

26. AI Demonstration

All AI behavior must be implemented through deterministic mock responses.

26.1 AI Task Description Assistant

Input:

Check the monthly stock discrepancies.

Output suggestion:

Improved Arabic and English title.

Detailed task description.

Suggested category.

Suggested priority.

Suggested estimated effort.

Suggested completion evidence.

User actions:

Accept all.

Accept selected fields.

Edit before applying.

Reject.

26.2 AI Checklist Generator

Generate a suggested checklist from the task description.

Example:

Obtain inventory report.

Compare physical and system quantities.

Identify discrepancies.

Classify discrepancy reasons.

Attach reconciliation evidence.

Submit final summary.

26.3 AI Task Summary

Summarize:

Description.

Current status.

Recent comments.

Blocker.

Pending actions.

Due-date risk.

26.4 AI Management Summary

Generate seeded narratives from local report metrics.

26.5 Arabic-English Assistant

Support mock actions:

Improve Arabic wording.

Improve English wording.

Translate Arabic to English.

Translate English to Arabic.

Shorten description.

Make description more formal.

26.6 AI Guardrails

Show:

“AI-generated suggestion” label.

Disclaimer.

Source fields used.

Confirmation before applying.

AI unavailable state.

No automatic task assignment.

No automatic approval.

No automatic performance judgment.

No cloud communication.

27. Mobile Administration Module

27.1 User Management

Support local demonstration of:

View users.

Search users.

Filter by department, team, role, and status.

Add user.

Edit user.

Activate.

Deactivate.

Assign manager.

Assign department.

Assign teams.

Assign role.

View user audit history.

27.2 Organization Management

Support:

Department list.

Team list.

Hierarchy view.

Add and edit department.

Add and edit team.

Assign manager.

Move team between departments.

Validation against circular hierarchy.

27.3 Role and Permission Management

Show:

Role list.

Permission categories.

View.

Create.

Edit.

Assign.

Reassign.

Approve.

Cancel.

Reopen.

View reports.

View sensitive tasks.

Configure system.

View audit.

Changes are local demo changes.

27.4 Task Configuration

Support:

Categories.

Priorities.

Confidentiality levels.

Approval defaults.

Evidence requirements.

Decline permission.

Extension permission.

Escalation rules.

Notification templates.

27.5 Audit Log

Support:

Search.

Filter.

User.

Action.

Entity.

Date range.

Offline action.

Sync result.

Conflict result.

Detail view.

Audit events must be read-only.

28. Localization

28.1 Languages

Required:

Arabic.

English.

28.2 Arabic Requirements

Full RTL layout.

Arabic navigation.

Arabic date formatting where appropriate.

Arabic validation messages.

Arabic seeded content.

Arabic dashboard insight narratives.

Arabic status and priority labels.

28.3 English Requirements

Full LTR layout.

Complete translation coverage.

No hardcoded Arabic strings in widgets.

No hardcoded English strings in widgets.

28.4 Localization Implementation

Use Flutter localization files such as ARB.

Example:

lib/l10n/app_ar.arb
lib/l10n/app_en.arb

All user-visible strings must be localized.

29. Accessibility

The demo must include:

Meaningful semantic labels.

Sufficient text contrast.

Dynamic text support.

Touch targets suitable for mobile.

Icons paired with labels where meaning may be unclear.

Status not represented by color alone.

Support for RTL.

Form validation announced clearly.

Logical focus order.

30. UI and Design Direction

30.1 Visual Style

Use a professional enterprise design:

Clean.

Modern.

Calm.

Information-dense without clutter.

Consistent.

Suitable for government or large organizations.

Strong Arabic typography.

Clear status hierarchy.

30.2 Theme

Provide:

Light mode.

Dark mode.

System mode.

30.3 Core Reusable Components

Create reusable widgets for:

App header.

Metric card.

Task card.

Status badge.

Priority badge.

Confidentiality badge.

User avatar.

Assignment summary.

Filter chip.

Empty state.

Error state.

Offline banner.

Sync status indicator.

Activity timeline item.

Comment item.

Attachment item.

Checklist item.

Report insight card.

Confirmation sheet.

Reason-entry dialog.

Arabic/English field.

User picker.

Team picker.

Date and time picker.

Progress control.

30.4 Empty, Loading, and Error States

Every data screen must have:

Loading skeleton.

Empty state.

Error state.

Retry action where relevant.

Offline state where relevant.

31. Seeded Demo Scenarios

The application must include seeded scenarios covering every major feature.

Scenario 1 — Normal Task Without Approval

Assigned to Ahmed.

Status: In Progress.

Priority: Normal.

Checklist partially complete.

Can complete directly.

Scenario 2 — Task Requiring Approval

Assigned by Sara.

Requires evidence.

Ahmed submits completion.

Sara reviews and approves.

Scenario 3 — Returned for Correction

Completion submitted.

Manager returns with a reason.

Employee corrects and resubmits.

Scenario 4 — Blocked Task

Finance task blocked by missing external document.

Shows blocker duration and responsibility.

Scenario 5 — Lead Owner with Contributors

Lead owner: Ahmed.

Contributors from Finance and HR.

Contributor updates visible.

Lead owner remains accountable.

Scenario 6 — Individual Copies

Annual policy acknowledgement.

Assigned independently to 12 employees.

Aggregate completion shown.

Individual status available.

Scenario 7 — Team Queue

IT support task.

Initially waiting in queue.

Khaled claims the task.

Simulate second-user claim conflict.

Scenario 8 — Reassignment

Task reassigned from one employee to another.

Mandatory reason.

Full audit history.

Scenario 9 — Deadline Extension

Employee requests extension.

Manager approves or rejects.

Timeline records decision.

Scenario 10 — Recurring Task

Monthly safety inspection.

Several generated occurrences.

One completed, one active, one upcoming.

Scenario 11 — Confidential Task

Visible to authorized manager.

Redacted for unauthorized employee.

Scenario 12 — Offline Update

Progress updated offline.

Pending sync indicator.

Successful sync on reconnection.

Scenario 13 — Sync Conflict

Offline progress update conflicts with reassignment.

Conflict resolution screen displayed.

Scenario 14 — AI Task Creation

Manager enters short sentence.

Mock AI proposes title, description, checklist, priority, and effort.

Manager selectively applies suggestions.

Scenario 15 — Performance Meaning Layer

Employee has lower task count but higher complexity.

Report explains the context.

32. Mock Services

Create interfaces and local mock implementations.

32.1 Required Services

AuthenticationService
CurrentUserService
TaskRepository
UserRepository
OrganizationRepository
NotificationRepository
ReportRepository
AdministrationRepository
AuditRepository
SyncRepository
ConnectivityService
AttachmentService
AiAssistantService
SettingsRepository
LocalizationService

32.2 Connectivity Service

Expose:

online
offline
unstable

32.3 AI Service

The mock AI service must:

Return deterministic responses.

Simulate loading.

Simulate success.

Simulate failure.

Support Arabic and English.

Never call a real endpoint.

32.4 Sync Service

The mock sync service must:

Process local operations.

Simulate delay.

Simulate success.

Simulate retry.

Simulate failure.

Simulate conflict.

Produce sync audit events.

33. Demo Data Reset

The administration settings must include:

Reset all demo data.

Reseed initial data.

Confirmation dialog.

Optional preservation of language and theme preferences.

Success notification.

This is essential for repeated demonstrations.

34. Search

Support local search over:

Task number.

Arabic title.

English title.

Description.

Employee name.

Department.

Team.

Category.

Comments.

Attachment file name.

Advanced natural-language search is not required. It may be represented as an AI demo only.

35. Calendar

The calendar module must show:

Due tasks.

Planned start dates.

Recurring task occurrences.

Overdue tasks.

Today.

Week.

Month.

No external calendar integration is required.

36. Non-Functional Requirements for the Demo

NFR-001 — Startup

The app should reach the demo login or home screen without noticeable unnecessary delay.

NFR-002 — Navigation

Primary navigation must feel immediate with local data.

NFR-003 — Persistence

User actions must survive application restart unless demo data is reset.

NFR-004 — Localization

All approved screens must work in Arabic and English.

NFR-005 — RTL

All Arabic screens must render correctly in RTL.

NFR-006 — Offline

Core employee actions must function in simulated offline mode.

NFR-007 — Modularity

Mock repositories must be replaceable by API repositories without rewriting the UI.

NFR-008 — Testability

Business rules and repositories must be unit-testable.

NFR-009 — Maintainability

No large monolithic screens. Extract reusable widgets and feature modules.

NFR-010 — Accessibility

Core flows must include semantic labels and accessible controls.

NFR-011 — Auditability

All important business actions must create audit events.

NFR-012 — Reliability

Seeded demo scenarios must work after every reset.

NFR-013 — Security Simulation

Role and confidentiality restrictions must be enforced in the local demo.

NFR-014 — Responsive Layout

The app must support common phone sizes and usable tablet layouts.

NFR-015 — No External Dependency

The demo must run without access to external services after dependencies are installed.

37. Testing Requirements

37.1 Unit Tests

Test:

Employee self-assignment rule.

Manager assignment scope.

Reassignment permission.

Mandatory reason validation.

Approval-required completion.

Checklist completion blocking.

Subtask completion blocking.

Queue claim behavior.

Individual-copy generation.

Confidentiality access.

Offline queue creation.

Conflict resolution.

AI confirmation rule.

37.2 Widget Tests

Test:

Login profile selection.

Language switching.

Task creation validation.

Status transition buttons.

Offline banner.

Sync indicator.

Approval flow.

Report meaning-layer card.

Role-based navigation.

37.3 Integration Tests

Cover:

Employee completes a normal task.

Employee submits a task requiring approval.

Manager returns and employee resubmits.

Manager creates individual copies.

Team member claims queue task.

Offline action synchronizes.

Conflict is resolved.

AI suggestion is selectively applied.

Administrator resets demo data.

37.4 Static Analysis

The project must pass:

flutter analyze

Tests must pass:

flutter test

38. Demo Acceptance Criteria

The demo is accepted when:

The application runs without a backend.

Arabic and English work across all main screens.

Role switching works.

Employee and manager permissions differ correctly.

Employees can create tasks only for themselves.

Managers can create, assign, and reassign tasks.

All assignment modes are demonstrated.

Approval-required and no-approval workflows both work.

Comments, checklists, subtasks, and attachments are visible and interactive.

Blocker and extension workflows work.

Recurring tasks are demonstrated.

Team queue claiming is demonstrated.

Management dashboards are populated.

Employee-performance reports include context.

Administration screens are available.

Offline mode is visible and functional.

Pending synchronization is demonstrated.

At least four conflict scenarios are available.

AI demo features work without external calls.

Audit history records important actions.

Data persists locally.

Demo data can be reset.

The UI is responsive.

Flutter analysis passes.

Automated tests cover critical business rules.

39. Implementation Phases

Codex must implement the application in controlled phases. Do not attempt the entire application in one response or one change set.

Phase 00 — Project Governance

Create:

README.

Architecture decision record.

Coding standards.

Folder structure.

Implementation progress file.

Demo scope guardrails.

Phase 01 — Flutter Foundation

Implement:

Flutter project setup.

Theme.

Localization.

Routing.

State-management setup.

Dependency injection.

Reusable shell.

Mock profile selection.

Phase 02 — Core Models and Local Database

Implement:

Enums.

Entities.

Drift schema.

Seed data.

Repository interfaces.

Local repositories.

Phase 03 — Authentication and Role Switching

Implement:

Splash.

Language selection.

Demo login.

Demo profile selection.

Current-user context.

Role-based navigation.

Phase 04 — Organization and Permissions

Implement:

Departments.

Teams.

Users.

Reporting lines.

Roles.

Permission checks.

Confidentiality checks.

Phase 05 — Task Foundation

Implement:

Task models.

Task list.

Filters.

Sorting.

Task details.

Status badges.

Priority badges.

Activity timeline.

Phase 06 — Task Creation

Implement:

Employee personal task creation.

Manager organizational task creation.

Multi-step task form.

Validation.

Review and confirmation.

Phase 07 — Assignment Modes

Implement:

Single owner.

Lead owner and contributors.

Individual copies.

Team queue.

Shared completion demonstration.

Phase 08 — Task Execution

Implement:

Acknowledge.

Start.

Pause.

Resume.

Progress.

Block.

Resolve blocker.

Complete.

Submit for approval.

Return for correction.

Reopen.

Cancel.

Phase 09 — Collaboration

Implement:

Comments.

Replies.

Mentions.

Attachments.

Voice-note simulation.

Checklists.

Subtasks.

Completion evidence.

Phase 10 — Approvals and Extensions

Implement:

Approval inbox.

Evidence review.

Approve.

Return.

Extension request.

Extension decision.

Phase 11 — Recurrence and Notifications

Implement:

Recurrence rules.

Generated occurrences.

Notification center.

Simulated reminders.

Escalation examples.

Phase 12 — Offline and Synchronization

Implement:

Connectivity simulator.

Pending operations.

Sync queue.

Retry.

Failure.

Conflict scenarios.

Resolution UI.

Phase 13 — Dashboards and Reports

Implement:

Employee dashboard.

Manager dashboard.

Executive dashboard.

Workload.

Performance.

Meaning layer.

Export simulation.

Phase 14 — Administration

Implement:

Users.

Departments.

Teams.

Roles.

Permissions.

Categories.

Priorities.

Rules.

Audit.

Reset demo data.

Phase 15 — AI Demonstration

Implement:

Mock AI service.

Description assistant.

Checklist generator.

Task summary.

Management summary.

Arabic-English helper.

Guardrails.

Phase 16 — Quality and Polish

Implement:

Responsive tablet layouts.

Accessibility.

Loading states.

Empty states.

Error states.

Dark mode.

Animation refinement.

Test completion.

Documentation.

40. Codex Working Rules

Codex must follow these rules during implementation.

Read this entire file before starting any phase.

Read the current repository before modifying files.

Implement only the requested phase.

Do not create a backend.

Do not call external APIs.

Do not add Firebase.

Do not add project-management features.

Do not replace approved business rules without explicit instruction.

Keep Arabic and English support in every new screen.

Add tests for new business logic.

Run formatting.

Run static analysis.

Run relevant tests.

Fix failures before declaring completion.

Update IMPLEMENTATION_PROGRESS.md.

Document assumptions.

List files added and changed.

Report unresolved issues.

Stop after the requested phase.

Do not automatically continue to the next phase.

41. Required Repository Documents

Codex must maintain:

README.md
TASK_MANAGEMENT_DEMO_MASTER_SPEC.md
ARCHITECTURE.md
IMPLEMENTATION_PROGRESS.md
DECISIONS.md
TESTING.md
DEMO_SCENARIOS.md

IMPLEMENTATION_PROGRESS.md

For each phase, record:

Status.

Date.

Completed items.

Files changed.

Tests added.

Test result.

Analysis result.

Known issues.

Next phase.

42. Definition of Done for Each Phase

A phase is complete only when:

Required functionality is implemented.

UI is navigable.

Arabic and English strings exist.

Business rules are enforced.

Local persistence works where relevant.

Tests are added.

Tests pass.

Static analysis passes.

Progress documentation is updated.

No unapproved backend or cloud dependency is introduced.

43. Future Backend Replacement Readiness

Although no backend is part of the demo, the app must be designed for later integration.

The future backend is expected to be:

Fully on-premises.

Integrated with an internally developed organizational system.

Responsible for authoritative users and organization data.

Responsible for task synchronization.

Responsible for audit retention.

Responsible for notifications.

Responsible for reports.

Responsible for local AI hosting.

To prepare for this:

Use repository interfaces.

Use DTO mapping boundaries.

Keep local IDs as strings or UUID-compatible values.

Track local and simulated server versions.

Keep sync metadata.

Avoid direct database calls from widgets.

Keep business rules in domain services.

Make authentication replaceable.

Make attachment storage replaceable.

Make AI service replaceable.

44. Final Demo Narrative

The completed demo must support the following presentation sequence:

Open the application in Arabic.

Enter as an employee.

Show assigned tasks and personal dashboard.

Create a self-assigned personal task.

Update an assigned task offline.

Add a comment and completion evidence.

Reconnect and synchronize.

Show a synchronization conflict.

Switch to manager.

Create a task using every assignment mode.

Review a completion request.

Return one task and approve another.

Review team workload and performance meaning.

Switch to senior management.

Show executive insights and critical tasks.

Switch to administrator.

Show users, organization, rules, sync queue, and audit logs.

Demonstrate local AI task assistance.

Switch to English.

Reset demo data and confirm repeatability.

45. Final Instruction to Codex

Treat this document as the authoritative product scope for the initial demo.

The first deliverable is a complete, polished, locally functioning Flutter demo that shows all approved features without connecting to a real backend.

Do not reduce the scope silently.Do not add unapproved cloud services.Do not add project-management features.Do not use real AI services.Do not bypass role, audit, offline, or assignment rules for convenience.

Implementation must proceed phase by phase through explicit user prompts.
