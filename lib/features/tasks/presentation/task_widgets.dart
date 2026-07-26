import 'package:flutter/material.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';
import '../domain/task_query_models.dart';

String statusLabel(TaskStatus value, bool ar) => switch (value) {
  TaskStatus.draft => ar ? 'مسودة' : 'Draft', TaskStatus.assigned => ar ? 'معينة' : 'Assigned',
  TaskStatus.acknowledged => ar ? 'تم الاستلام' : 'Acknowledged', TaskStatus.inProgress => ar ? 'قيد التنفيذ' : 'In progress',
  TaskStatus.paused => ar ? 'متوقفة مؤقتاً' : 'Paused', TaskStatus.blocked => ar ? 'متعطلة' : 'Blocked',
  TaskStatus.completionRequested => ar ? 'طلب إكمال' : 'Completion requested',
  TaskStatus.returnedForCorrection => ar ? 'معادة للتصحيح' : 'Returned for correction',
  TaskStatus.completed => ar ? 'مكتملة' : 'Completed', TaskStatus.declined => ar ? 'مرفوضة' : 'Declined',
  TaskStatus.cancelled => ar ? 'ملغاة' : 'Cancelled', TaskStatus.reopened => ar ? 'أعيد فتحها' : 'Reopened',
  TaskStatus.expired => ar ? 'منتهية' : 'Expired', TaskStatus.upcoming => ar ? 'قادمة' : 'Upcoming',
  TaskStatus.unknown => ar ? 'غير معروفة' : 'Unknown' };

class TaskStatusBadge extends StatelessWidget { const TaskStatusBadge(this.status,{super.key}); final TaskStatus status;
  @override Widget build(BuildContext context) { final ar=Localizations.localeOf(context).languageCode=='ar';
    final attention={TaskStatus.blocked,TaskStatus.returnedForCorrection,TaskStatus.expired}.contains(status);
    return Semantics(label: statusLabel(status,ar), child: Chip(avatar: Icon(attention?Icons.warning_amber:Icons.task_alt,size:16),label: Text(statusLabel(status,ar)))); }}
class TaskPriorityBadge extends StatelessWidget { const TaskPriorityBadge(this.priority,{super.key}); final TaskPriority? priority;
  @override Widget build(BuildContext context) { final label=(Localizations.localeOf(context).languageCode=='ar'?priority?.labelAr:priority?.labelEn)??priority?.code??'—';
    return Chip(avatar: const Icon(Icons.flag_outlined,size:16),label: Text(label)); }}
class TaskConfidentialityBadge extends StatelessWidget { const TaskConfidentialityBadge(this.code,{super.key}); final String? code;
  @override Widget build(BuildContext context) => Chip(avatar: const Icon(Icons.lock_outline,size:16),label: Text(code??'—')); }
class TaskSyncBadge extends StatelessWidget { const TaskSyncBadge(this.state,{super.key}); final LocalEntitySyncState state;
  @override Widget build(BuildContext context)=>Tooltip(message: state.code,child: Chip(avatar:const Icon(Icons.sync,size:16),label:Text(state.code))); }
class TaskProgressIndicator extends StatelessWidget { const TaskProgressIndicator(this.value,{super.key}); final int value;
  @override Widget build(BuildContext context){final safe=value.clamp(0,100);return Semantics(value:'$safe%',child:Row(children:[Expanded(child:LinearProgressIndicator(value:safe/100)),const SizedBox(width:8),Text('$safe%')]));}}

class TaskCard extends StatelessWidget { const TaskCard({super.key,required this.item,required this.onTap}); final TaskListItem item; final VoidCallback onTap;
  @override Widget build(BuildContext context){final ar=Localizations.localeOf(context).languageCode=='ar';final t=item.task;
    return Card(child:InkWell(onTap:onTap,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(t.taskNumber,style:Theme.of(context).textTheme.labelMedium),const SizedBox(height:4),Text(ar?t.titleAr:(t.titleEn??t.titleAr),maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.titleMedium),
      const SizedBox(height:8),Wrap(spacing:6,runSpacing:6,children:[TaskStatusBadge(t.status),TaskPriorityBadge(item.priority),if(item.confidentiality?.code=='confidential'||item.confidentiality?.code=='restricted')TaskConfidentialityBadge(item.confidentiality?.code),TaskSyncBadge(t.syncState)]),
      const SizedBox(height:8),Row(children:[const Icon(Icons.event,size:18),const SizedBox(width:6),Text(MaterialLocalizations.of(context).formatMediumDate(t.dueDate)),const Spacer(),if(item.hasActiveBlocker)const Icon(Icons.report_problem_outlined)]),
      const SizedBox(height:8),TaskProgressIndicator(item.progressPercentage)])))); }}
