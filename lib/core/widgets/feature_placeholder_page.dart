import 'package:flutter/material.dart';
import '../../app/localization/localization_extensions.dart';
import '../../app/theme/app_tokens.dart';

class FeaturePlaceholderPage extends StatelessWidget { const FeaturePlaceholderPage({super.key,required this.title,required this.role,required this.icon}); final String title,role; final IconData icon; @override Widget build(BuildContext context)=>Center(child:SingleChildScrollView(padding:const EdgeInsets.all(AppSpacing.large),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:600),child:Column(children:[Icon(icon,size:64,color:Theme.of(context).colorScheme.primary),const SizedBox(height:AppSpacing.medium),Text(title,style:Theme.of(context).textTheme.headlineSmall,textAlign:TextAlign.center),const SizedBox(height:AppSpacing.small),Text(context.l10n.featureLater,textAlign:TextAlign.center),const SizedBox(height:AppSpacing.medium),Chip(avatar:const Icon(Icons.badge_outlined),label:Text('${context.l10n.currentRole}: $role'))])))); }
