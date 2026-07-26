import 'package:flutter/material.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';
import '../domain/task_query_models.dart';
import 'task_presentation.dart';

class _CompactBadge extends StatelessWidget {
  const _CompactBadge(this.icon, this.label, {this.emphasized = false});
  final IconData icon; final String label; final bool emphasized;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: emphasized ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon,size:14),const SizedBox(width:4),Flexible(child:Text(label,maxLines:1,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.labelSmall))]));
}

class TaskStatusBadge extends StatelessWidget { const TaskStatusBadge(this.status,{super.key}); final TaskStatus status;
  @override Widget build(BuildContext context)=>_CompactBadge(Icons.task_alt,TaskPresentation.status(context,status),emphasized:status==TaskStatus.blocked); }
class TaskPriorityBadge extends StatelessWidget { const TaskPriorityBadge(this.priority,{super.key}); final TaskPriority? priority;
  @override Widget build(BuildContext context)=>_CompactBadge(Icons.flag_outlined,TaskPresentation.priority(context,priority?.code,en:priority?.labelEn,ar:priority?.labelAr),emphasized:priority?.code=='critical'||priority?.code=='urgent'); }
class TaskConfidentialityBadge extends StatelessWidget { const TaskConfidentialityBadge(this.code,{super.key}); final String? code;
  @override Widget build(BuildContext context)=>_CompactBadge(Icons.lock_outline,TaskPresentation.confidentiality(context,code),emphasized:code=='restricted'); }
class TaskSyncBadge extends StatelessWidget { const TaskSyncBadge(this.state,{super.key}); final LocalEntitySyncState state;
  @override Widget build(BuildContext context)=>_CompactBadge(Icons.sync,sizeLabel(context,state));
  String sizeLabel(BuildContext c,LocalEntitySyncState s)=>TaskPresentation.sync(c,s); }

class TaskProgressIndicator extends StatelessWidget {
  const TaskProgressIndicator(this.value,{super.key}); final int value;
  @override Widget build(BuildContext context){final safe=value.clamp(0,100);return Semantics(label:TaskPresentation.text(context,'Task progress','تقدم المهمة'),value:'$safe%',child:Directionality(textDirection:TextDirection.ltr,child:Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(4),child:LinearProgressIndicator(value:safe/100,minHeight:6))),const SizedBox(width:7),SizedBox(width:34,child:Text('$safe%',textAlign:TextAlign.end,style:Theme.of(context).textTheme.labelMedium))])));}
}

String dueDateLabel(BuildContext context, TaskListItem item, DateTime now) {
  final t=item.task; final due=DateTime(t.dueDate.year,t.dueDate.month,t.dueDate.day); final today=DateTime(now.year,now.month,now.day);
  final days=due.difference(today).inDays;
  if (closedTaskStatuses.contains(t.status)) return t.status==TaskStatus.completed && days>=0 ? TaskPresentation.text(context,'Completed on time','أُنجزت في الموعد') : MaterialLocalizations.of(context).formatMediumDate(t.dueDate);
  if(days<0) return TaskPresentation.text(context,'Overdue by ${-days} days','متأخرة ${-days} أيام');
  if(days==0) return TaskPresentation.text(context,'Due today','مستحقة اليوم');
  if(days==1) return TaskPresentation.text(context,'Due tomorrow','مستحقة غداً');
  if(days<=7) return TaskPresentation.text(context,'Due this week','مستحقة هذا الأسبوع');
  return MaterialLocalizations.of(context).formatMediumDate(t.dueDate);
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key,required this.item,required this.onTap,required this.now});
  final TaskListItem item; final VoidCallback onTap; final DateTime now;
  @override Widget build(BuildContext context){final ar=Localizations.localeOf(context).languageCode=='ar';final t=item.task;
    final owner=ar?item.primaryOwner?.nameAr:item.primaryOwner?.nameEn; final team=ar?item.assignedTeam?.nameAr:item.assignedTeam?.nameEn;
    return Card(clipBehavior:Clip.antiAlias,child:InkWell(onTap:onTap,child:Padding(padding:const EdgeInsets.fromLTRB(12,10,12,10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
      Row(children:[Expanded(child:Text(t.taskNumber,style:Theme.of(context).textTheme.labelMedium)),TaskStatusBadge(t.status)]),const SizedBox(height:5),
      Text(ar?t.titleAr:(t.titleEn??t.titleAr),maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:7),
      Row(children:[TaskPriorityBadge(item.priority),const SizedBox(width:6),Icon(item.isOverdue?Icons.event_busy:Icons.event,size:15),const SizedBox(width:3),Expanded(child:Text(dueDateLabel(context,item,now),maxLines:1,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.labelSmall))]),
      if(owner!=null||team!=null)...[const SizedBox(height:5),Row(children:[Icon(team!=null?Icons.groups_outlined:Icons.person_outline,size:15),const SizedBox(width:4),Expanded(child:Text(team??owner!,maxLines:1,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.labelSmall))])],
      const SizedBox(height:7),TaskProgressIndicator(item.progressPercentage),const SizedBox(height:7),
      Row(children:[if(item.hasActiveBlocker)...[const Icon(Icons.report_problem_outlined,size:15),const SizedBox(width:3),Text(TaskPresentation.text(context,'Blocked','متوقفة'),style:Theme.of(context).textTheme.labelSmall)],const Spacer(),
        if(item.confidentiality?.code=='confidential'||item.confidentiality?.code=='restricted')... [Icon(Icons.lock_outline,size:14),const SizedBox(width:3),Text(TaskPresentation.confidentiality(context,item.confidentiality?.code),style:Theme.of(context).textTheme.labelSmall)],const SizedBox(width:7),Icon(Icons.sync,size:13),const SizedBox(width:3),Flexible(child:Text(TaskPresentation.sync(context,t.syncState),overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.labelSmall))])
    ])))); }
}

class TaskAssignmentSummary extends StatelessWidget {
 const TaskAssignmentSummary({super.key,required this.details}); final TaskDetails details;
 @override Widget build(BuildContext context){final ar=Localizations.localeOf(context).languageCode=='ar';final rows=<Widget>[];
   void add(String label,String? name,IconData icon,{String? role}){if(name==null||name.isEmpty)return;rows.add(Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[CircleAvatar(radius:15,child:Icon(icon,size:16)),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:Theme.of(context).textTheme.labelSmall),Text(name,maxLines:2,overflow:TextOverflow.ellipsis),if(role!=null)Text(role,style:Theme.of(context).textTheme.labelSmall)]))])));}
   add(TaskPresentation.text(context,'Created by','أنشأها'),ar?details.creator?.nameAr:details.creator?.nameEn,Icons.person_add_alt);
   add(TaskPresentation.text(context,'Lead owner','المسؤول الرئيسي'),ar?details.leadOwner?.nameAr:details.leadOwner?.nameEn,Icons.person);
   for(final a in details.assignments){if(a.assignmentRole==AssignmentRole.leadOwner)continue;final u=details.assignmentUsers[a.userId];add(TaskPresentation.assignmentRole(context,a.assignmentRole),ar?u?.nameAr:u?.nameEn,Icons.person_outline,role:TaskPresentation.assignmentRole(context,a.assignmentRole));}
   add(TaskPresentation.text(context,'Assigned team','الفريق المكلف'),ar?details.assignedTeam?.nameAr:details.assignedTeam?.nameEn,Icons.groups_outlined);
   return Column(children:rows);
 }
}
