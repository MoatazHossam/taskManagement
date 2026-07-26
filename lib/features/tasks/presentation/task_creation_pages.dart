import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/localization_extensions.dart';
import '../../../app/dependency_injection/app_providers.dart';
import '../../../core/domain/entities.dart';
import '../domain/task_creation_models.dart';
import 'task_creation_providers.dart';

class TaskCreationPage extends ConsumerStatefulWidget {
  const TaskCreationPage({super.key, this.draftId, this.initialStep = 0});
  final String? draftId;
  final int initialStep;
  @override ConsumerState<TaskCreationPage> createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends ConsumerState<TaskCreationPage> {
  @override void initState() { super.initState(); Future.microtask(() async { await ref.read(taskCreationControllerProvider.notifier).initialize(draftId: widget.draftId); if (mounted) ref.read(taskCreationControllerProvider.notifier).goTo(widget.initialStep); }); }
  @override Widget build(BuildContext context) {
    final state = ref.watch(taskCreationControllerProvider), draft = state.draft;
    if (draft == null) return Scaffold(appBar: AppBar(title: Text(context.l10n.createTask)), body: Center(child: state.result == null ? const CircularProgressIndicator() : Text(context.l10n.permissionDenied)));
    final titles = [context.l10n.basicInformation, context.l10n.classificationPlanning, context.l10n.assignment, context.l10n.reviewSubmit];
    return Scaffold(appBar: AppBar(title: Text(context.l10n.createTask), leading: BackButton(onPressed: () => context.go('/tasks'))), body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: Row(children: List.generate(4, (i) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: LinearProgressIndicator(value: i <= state.step ? 1 : 0))))),),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: AlignmentDirectional.centerStart, child: Text(titles[state.step], style: Theme.of(context).textTheme.titleLarge))),
      Expanded(child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), child: switch (state.step) { 0 => _Basic(draft), 1 => _Planning(draft, state.options), 2 => _Assignment(draft, state.options), _ => _Review(draft, state) })),
    ])), bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [if (state.step > 0) OutlinedButton(onPressed: state.loading ? null : () => ref.read(taskCreationControllerProvider.notifier).goTo(state.step - 1), child: Text(context.l10n.back)), const Spacer(), if (state.step < 3) FilledButton(onPressed: () => ref.read(taskCreationControllerProvider.notifier).goTo(state.step + 1), child: Text(context.l10n.next)) else FilledButton(onPressed: state.loading ? null : _confirm, child: state.loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(context.l10n.submitTask))]))));
  }
  Future<void> _confirm() async { final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text(context.l10n.confirmSubmission), content: _Review(ref.read(taskCreationControllerProvider).draft!, ref.read(taskCreationControllerProvider), compact: true), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.returnReview)), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.submitTask))])); if (ok != true || !mounted) return; final result = await ref.read(taskCreationControllerProvider.notifier).submit(); if (result?.isSuccess == true && mounted) context.go('/tasks/create/success/${result!.task!.id}'); }
}

class _Basic extends ConsumerWidget { const _Basic(this.draft); final TaskDraft draft;
  @override Widget build(BuildContext context, WidgetRef ref) { final c = ref.read(taskCreationControllerProvider.notifier); return Column(children: [
    _Field(label: context.l10n.arabicTitle, value: draft.titleAr, maxLength: 150, rtl: true, onChanged: (v) => c.update((d) => d.copyWith(titleAr: v))),
    _Field(label: context.l10n.englishTitle, value: draft.titleEn, maxLength: 150, onChanged: (v) => c.update((d) => d.copyWith(titleEn: v))),
    _Field(label: context.l10n.arabicDescription, value: draft.descriptionAr, maxLength: 4000, maxLines: 4, rtl: true, onChanged: (v) => c.update((d) => d.copyWith(descriptionAr: v))),
    _Field(label: context.l10n.englishDescription, value: draft.descriptionEn, maxLength: 4000, maxLines: 4, onChanged: (v) => c.update((d) => d.copyWith(descriptionEn: v))),
    SwitchListTile(value: draft.isPersonal, title: Text(context.l10n.personalTask), onChanged: (v) => c.update((d) => d.copyWith(isPersonal: v))),
    if (ref.watch(taskTemplatesProvider).isNotEmpty) DropdownButtonFormField<TaskTemplate>(decoration: InputDecoration(labelText: context.l10n.selectTemplate), items: ref.watch(taskTemplatesProvider).map<DropdownMenuItem<TaskTemplate>>((t) => DropdownMenuItem(value: t, child: Text(t.titleEn ?? t.titleAr))).toList(), onChanged: (template) async { if (template == null) return; final replace = draft.titleAr.trim().isEmpty && draft.titleEn.trim().isEmpty || await showDialog<bool>(context: context, builder: (context) => AlertDialog(content: Text(context.l10n.templateOverwritePrompt), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.confirm))])) == true; if (replace) c.update((d) => d.applyTemplate(template, DateTime.now().toUtc())); }),
  ]); }}

class _Planning extends ConsumerWidget { const _Planning(this.draft, this.options); final TaskDraft draft; final TaskCreationOptions? options;
  @override Widget build(BuildContext context, WidgetRef ref) { final c = ref.read(taskCreationControllerProvider.notifier); return Column(children: [
    _Selector(label: context.l10n.category, value: draft.categoryId, values: options?.categories ?? [], id: (e) => e.id, text: (e) => e.labelEn ?? e.labelAr, onChanged: (v) => c.update((d) => d.copyWith(categoryId: v))),
    _Selector(label: context.l10n.priority, value: draft.priorityId, values: options?.priorities ?? [], id: (e) => e.id, text: (e) => e.labelEn ?? e.labelAr, onChanged: (v) => c.update((d) => d.copyWith(priorityId: v))),
    _Selector(label: context.l10n.confidentiality, value: draft.confidentialityLevelId, values: options?.confidentialityLevels ?? [], id: (e) => e.id, text: (e) => e.labelEn ?? e.labelAr, onChanged: (v) => c.update((d) => d.copyWith(confidentialityLevelId: v))),
    ListTile(title: Text(context.l10n.dueDate), subtitle: Text(draft.dueDate == null ? '—' : MaterialLocalizations.of(context).formatFullDate(draft.dueDate!)), trailing: const Icon(Icons.calendar_today), onTap: () async { final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650))); if (date != null) c.update((d) => d.copyWith(dueDate: date)); }),
    TextFormField(initialValue: draft.estimatedEffortMinutes?.toString(), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: context.l10n.estimatedEffortMinutes), onChanged: (v) => c.update((d) => d.copyWith(estimatedEffortMinutes: int.tryParse(v), clearEffort: v.isEmpty))),
    SwitchListTile(value: draft.approvalRequired, title: Text(context.l10n.approvalRequired), onChanged: (v) => c.update((d) => d.copyWith(approvalRequired: v))),
    SwitchListTile(value: draft.completionEvidenceRequired, title: Text(context.l10n.completionEvidenceRequired), onChanged: (v) => c.update((d) => d.copyWith(completionEvidenceRequired: v))),
    SwitchListTile(value: draft.allowDecline, title: Text(context.l10n.allowDecline), onChanged: (v) => c.update((d) => d.copyWith(allowDecline: v))),
    SwitchListTile(value: draft.allowExtension, title: Text(context.l10n.allowExtension), onChanged: (v) => c.update((d) => d.copyWith(allowExtension: v))),
  ]); }}

class _Assignment extends ConsumerWidget { const _Assignment(this.draft, this.options); final TaskDraft draft; final TaskCreationOptions? options;
  @override Widget build(BuildContext context, WidgetRef ref) { final candidates = options?.ownerCandidates ?? []; return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(context.l10n.singleOwner, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 12), if (options?.ownerLocked ?? true) ListTile(leading: const Icon(Icons.lock), title: Text(_owner(candidates, draft.ownerUserId)?.nameEn ?? _owner(candidates, draft.ownerUserId)?.nameAr ?? context.l10n.currentOwner)) else DropdownButtonFormField<String>(value: draft.ownerUserId, decoration: InputDecoration(labelText: context.l10n.selectOwner, prefixIcon: const Icon(Icons.search)), items: candidates.map((u) => DropdownMenuItem(value: u.id, child: Text('${u.nameEn ?? u.nameAr} · ${u.employeeNumber}'))).toList(), onChanged: (v) => ref.read(taskCreationControllerProvider.notifier).update((d) => d.copyWith(ownerUserId: v))), const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.advancedAssignmentLater)))]); }
  OrganizationUser? _owner(List<OrganizationUser> values, String? id) => values.where((e) => e.id == id).firstOrNull;
}

class _Review extends ConsumerWidget { const _Review(this.draft, this.state, {this.compact = false}); final TaskDraft draft; final TaskCreationState state; final bool compact;
  @override Widget build(BuildContext context, WidgetRef ref) { final issues = state.validation?.issues ?? const <TaskValidationIssue>[]; return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _ReviewRow(context.l10n.taskNumber, draft.taskNumber ?? '—'), _ReviewRow(context.l10n.arabicTitle, draft.titleAr.isEmpty ? '—' : draft.titleAr), _ReviewRow(context.l10n.englishTitle, draft.titleEn.isEmpty ? '—' : draft.titleEn), _ReviewRow(context.l10n.category, draft.categoryId ?? '—'), _ReviewRow(context.l10n.priority, draft.priorityId ?? '—'), _ReviewRow(context.l10n.confidentiality, draft.confidentialityLevelId ?? '—'), _ReviewRow(context.l10n.currentOwner, draft.ownerUserId ?? '—'),
    if (issues.isNotEmpty) ...issues.map((e) => Padding(padding: const EdgeInsets.only(top: 8), child: Text(_message(context, e.messageKey), style: TextStyle(color: Theme.of(context).colorScheme.error)))),
    if (!compact) ...[const SizedBox(height: 16), OutlinedButton(onPressed: state.loading ? null : () async { final result = await ref.read(taskCreationControllerProvider.notifier).saveDraft(); if (result?.isSuccess == true && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.draftSaved))); }, child: Text(draft.id == null ? context.l10n.saveDraft : context.l10n.updateDraft)), TextButton(onPressed: () => context.go('/tasks'), child: Text(context.l10n.cancel))]
  ]); }
  String _message(BuildContext c, String key) => switch (key) { 'taskTitleRequired' => c.l10n.taskTitleRequired, 'ownerRequired' => c.l10n.ownerRequired, 'dueBeforeStart' => c.l10n.dueBeforeStart, 'dueInPast' => c.l10n.dueInPast, 'effortInvalid' => c.l10n.effortInvalid, 'categoryRequired' => c.l10n.categoryRequired, 'priorityRequired' => c.l10n.priorityRequired, 'confidentialityRequired' => c.l10n.confidentialityRequired, _ => c.l10n.submissionFailed };
}
class _ReviewRow extends StatelessWidget { const _ReviewRow(this.label, this.value); final String label, value; @override Widget build(BuildContext context) => ListTile(dense: true, title: Text(label), subtitle: Text(value)); }
class _Field extends StatelessWidget { const _Field({required this.label, required this.value, required this.onChanged, this.maxLength, this.maxLines = 1, this.rtl = false}); final String label, value; final ValueChanged<String> onChanged; final int? maxLength, maxLines; final bool rtl; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(initialValue: value, onChanged: onChanged, maxLength: maxLength, maxLines: maxLines, textDirection: rtl ? TextDirection.rtl : TextDirection.ltr, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()))); }
class _Selector<T> extends StatelessWidget { const _Selector({required this.label, required this.value, required this.values, required this.id, required this.text, required this.onChanged}); final String label; final String? value; final List<T> values; final String Function(T) id, text; final ValueChanged<String?> onChanged; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), items: values.map((e) => DropdownMenuItem(value: id(e), child: Text(text(e)))).toList(), onChanged: onChanged)); }

class TaskCreationSuccessPage extends ConsumerWidget { const TaskCreationSuccessPage({super.key, required this.taskId}); final String taskId; @override Widget build(BuildContext context, WidgetRef ref) { final task = ref.watch(taskRepositoryProvider).getTaskById(taskId); return FutureBuilder<Task?>(future: task, builder: (context, snapshot) { final value = snapshot.data; return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 80, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 16), Text(context.l10n.taskCreatedSuccessfully, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center), const SizedBox(height: 8), Text('${context.l10n.taskNumber}: ${value?.taskNumber ?? '—'}'), const SizedBox(height: 24), FilledButton(onPressed: value == null ? null : () => context.go('/tasks/${value.id}'), child: Text(context.l10n.openTask)), OutlinedButton(onPressed: () { ref.invalidate(taskCreationControllerProvider); context.go('/tasks/create'); }, child: Text(context.l10n.createAnotherTask)), TextButton(onPressed: () => context.go('/tasks'), child: Text(context.l10n.returnTasks))]))))); }); }}
