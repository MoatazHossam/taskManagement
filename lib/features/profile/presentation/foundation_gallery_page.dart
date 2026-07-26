import 'package:flutter/material.dart';
import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/connectivity_status_banner.dart';
import '../../../core/widgets/foundation_views.dart';

class FoundationGalleryPage extends StatelessWidget { const FoundationGalleryPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(context.l10n.foundationGallery)),body:ListView(padding:const EdgeInsets.all(AppSpacing.medium),children:[Text(context.l10n.foundationStateExamples),SizedBox(height:160,child:AppLoadingView(label:context.l10n.loading)),SizedBox(height:140,child:AppEmptyView(label:context.l10n.noData)),SizedBox(height:160,child:AppErrorView(label:context.l10n.somethingWentWrong,retryLabel:context.l10n.retry)),const ConnectivityStatusBanner(),Card(child:Padding(padding:const EdgeInsets.all(AppSpacing.medium),child:Text(context.l10n.longTextDemo))),FilledButton(onPressed:()=>showAppConfirmationDialog(context,title:context.l10n.demoMode,question:context.l10n.confirmationQuestion,confirm:context.l10n.confirm,cancel:context.l10n.cancel),child:Text(context.l10n.showDialog))])); }
