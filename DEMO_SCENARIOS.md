# Approved Seeded Demo Scenarios

This catalog structures the scenarios approved in section 31 of the master specification. It is a future seed and acceptance contract only: **none of these scenarios is implemented in Phase 00**. Exact dates and record identifiers will be chosen with Phase 02 seed design while preserving each starting state and rule.

## SCN-01 — Normal task without approval

- **Acting role:** Ahmed Hassan (Employee)
- **Starting state:** A normal-priority task assigned to Ahmed is In Progress, has a partially completed checklist, and does not require approval.
- **Steps:** Open the task; finish mandatory checklist items; choose direct completion; confirm.
- **Expected result:** The task completes directly, progress becomes 100, and activity/audit history records the action.
- **Business rules demonstrated:** BR-007 mandatory checklist; BR-010 progress range; BR-011 completion progress; no-approval lifecycle.
- **Future implementation phase:** Phase 08 (supported by Phases 02, 05, and 09)
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-02 — Task requiring approval

- **Acting role:** Ahmed Hassan (Employee), then Sara Mahmoud (Manager)
- **Starting state:** Sara assigned Ahmed a task that requires approval and completion evidence.
- **Steps:** Ahmed adds required evidence and submits completion; Sara opens the approval inbox, reviews evidence, and approves.
- **Expected result:** Submission enters Completion Requested; approval completes the task; evidence and both actions remain in history.
- **Business rules demonstrated:** BR-005 optional approval; BR-006 completion evidence; BR-011 completion progress; approval lifecycle.
- **Future implementation phase:** Phase 10 (supported by Phases 08–09)
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-03 — Returned for correction

- **Acting role:** Sara Mahmoud (Manager), then Ahmed Hassan (Employee)
- **Starting state:** Ahmed's completion is awaiting Sara's review.
- **Steps:** Sara returns it with a mandatory reason; Ahmed corrects the work and resubmits.
- **Expected result:** Status moves through Returned for Correction, In Progress, and Completion Requested; reason and resubmission are audited.
- **Business rules demonstrated:** Return flow; mandatory transition reason; auditable status changes.
- **Future implementation phase:** Phase 10
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-04 — Blocked task

- **Acting role:** Assigned Finance employee
- **Starting state:** A Finance task is blocked because an external document is missing, with responsibility identified.
- **Steps:** Review blocker details and duration; later record resolution and resume work.
- **Expected result:** Blocker duration/responsibility are visible; resolution returns the task to In Progress and is audited.
- **Business rules demonstrated:** BR-009 blocker reason/responsibility; blocked lifecycle; meaningful external-dependency context.
- **Future implementation phase:** Phase 08
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-05 — Lead owner with contributors

- **Acting role:** Ahmed Hassan (Lead owner), Finance/HR contributors
- **Starting state:** Ahmed leads a task with contributors from Finance and HR and visible contributor updates.
- **Steps:** Contributors add updates and finish assigned subtasks; Ahmed reviews and completes/submits the parent.
- **Expected result:** Contributor activity is attributed separately while Ahmed remains accountable and is the only user who completes/submits the parent.
- **Business rules demonstrated:** Lead-owner accountability; contributor permissions; mandatory-subtask completion where configured.
- **Future implementation phase:** Phase 07 (execution/collaboration completed in Phases 08–09)
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-06 — Individual copies

- **Acting role:** Sara Mahmoud (Manager)
- **Starting state:** Annual policy acknowledgement is assigned independently to 12 employees with mixed completion states.
- **Steps:** Open aggregate progress; drill into multiple employee copies and their histories.
- **Expected result:** Aggregate completion is shown while every copy retains independent status, evidence/comments, and audit history.
- **Business rules demonstrated:** BR-018 independent copies; bulk compliance/training assignment; individual accountability.
- **Future implementation phase:** Phase 07
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-07 — Team queue

- **Acting role:** Khaled Ibrahim (Technical Support Queue member), plus simulated second member
- **Starting state:** An IT support task is waiting unclaimed in the Technical Support Queue.
- **Steps:** Khaled claims the task; simulate a near-concurrent second claim.
- **Expected result:** Khaled's accepted claim records user/time; the second claim loses with an explanatory conflict; queue and execution timing remain distinct.
- **Business rules demonstrated:** BR-016 active-team membership; BR-017 first accepted claim wins; queue ownership behavior.
- **Future implementation phase:** Phase 07 (conflict UI in Phase 12)
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-08 — Reassignment

- **Acting role:** Sara Mahmoud (authorized Manager)
- **Starting state:** An organizational task belongs to another employee and is eligible for reassignment.
- **Steps:** Select a new authorized assignee; enter the mandatory reason; confirm; inspect history.
- **Expected result:** Ownership changes only after validation, and the old/new assignees, reason, actor, and time appear in immutable audit history.
- **Business rules demonstrated:** BR-002 manager scope; BR-003 permission; BR-004 reason/audit.
- **Future implementation phase:** Phase 08
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-09 — Deadline extension

- **Acting role:** Ahmed Hassan (Employee), then Sara Mahmoud (Manager)
- **Starting state:** Ahmed has an active task whose deadline cannot be changed directly by him.
- **Steps:** Ahmed requests a new deadline with a reason; Sara approves or rejects with the required review information.
- **Expected result:** The decision and resulting due date are visible; request, reason, reviewer, decision, and timeline events are retained.
- **Business rules demonstrated:** Mandatory extension/rejection reasons; manager-controlled official deadline; auditability.
- **Future implementation phase:** Phase 10
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-10 — Recurring task

- **Acting role:** Sara Mahmoud (Manager)
- **Starting state:** A monthly safety-inspection rule has one completed, one active, and one upcoming generated occurrence.
- **Steps:** Inspect the recurrence source and independent occurrences; pause the rule or preview a future edit.
- **Expected result:** Occurrences retain independent status and source linkage; pausing affects future generation rather than completed history.
- **Business rules demonstrated:** Local recurrence generation; independent occurrence history; no backend scheduler.
- **Future implementation phase:** Phase 11
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-11 — Confidential task

- **Acting role:** Authorized manager, then unauthorized employee
- **Starting state:** A confidential task is within the manager's permission but outside the employee's access.
- **Steps:** View full detail as manager; switch profile; attempt the same preview/detail as employee.
- **Expected result:** The manager sees authorized content; the employee sees a redacted preview/access denial; an attempt is audited where appropriate.
- **Business rules demonstrated:** BR-014 role/scope/confidentiality intersection; non-implicit administrator/performance access; auditability.
- **Future implementation phase:** Phase 04 (presentation in Phase 05)
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-12 — Offline update

- **Acting role:** Ahmed Hassan (Employee)
- **Starting state:** A cached active task is available and the simulator is Offline.
- **Steps:** Update progress offline; inspect pending operations; reconnect and synchronize.
- **Expected result:** The update is immediately local and marked pending, queued visibly, then becomes synced after deterministic successful processing.
- **Business rules demonstrated:** BR-020 queued/visible offline action; offline usefulness; explicit sync status.
- **Future implementation phase:** Phase 12
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-13 — Sync conflict

- **Acting role:** Ahmed Hassan (Employee) with simulated manager/server state
- **Starting state:** Ahmed changed progress offline while the simulated authoritative version reassigned the task.
- **Steps:** Reconnect; process the queue; open the conflict explanation; resolve according to field policy.
- **Expected result:** Simulated server ownership wins; Ahmed's progress note can be retained in audit/comment history; the resolution is recorded and status is explicit.
- **Business rules demonstrated:** BR-021 server-controlled assignment; Conflict A; preservation of non-authoritative work evidence.
- **Future implementation phase:** Phase 12
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-14 — AI task creation

- **Acting role:** Sara Mahmoud (Manager)
- **Starting state:** The local deterministic AI assistant is available and Sara enters a short task sentence.
- **Steps:** Request suggestions; review bilingual title/description, checklist, priority, and effort; apply selected fields only; edit and confirm.
- **Expected result:** Only explicitly selected and confirmed suggestions enter the draft; labels/disclaimer remain clear; no call or autonomous assignment occurs.
- **Business rules demonstrated:** BR-019 explicit confirmation; deterministic AI; human control; no cloud communication.
- **Future implementation phase:** Phase 15
- **Current implementation status:** Not implemented — Phase 00 contract only.

## SCN-15 — Performance meaning layer

- **Acting role:** Sara Mahmoud (Manager) or Omar Al Nuaimi (Senior Management)
- **Starting state:** Ahmed has fewer completed tasks than average but the highest estimated effort and longest external-blocker duration.
- **Steps:** Review metrics and the accompanying narrative; drill into supporting context.
- **Expected result:** The report warns against raw-count underperformance conclusions and explains complexity, blockers, additional information, risk, and a suggested management action.
- **Business rules demonstrated:** Contextual performance interpretation; permitted report scope; no automated AI performance judgment.
- **Future implementation phase:** Phase 13
- **Current implementation status:** Not implemented — Phase 00 contract only.
