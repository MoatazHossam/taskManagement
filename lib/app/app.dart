import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'dependency_injection/app_providers.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class TaskManagementApp extends ConsumerWidget { const TaskManagementApp({super.key}); @override Widget build(BuildContext context,WidgetRef ref)=>MaterialApp.router(debugShowCheckedModeBanner:false,onGenerateTitle:(c)=>AppLocalizations.of(c)!.appName,routerConfig:ref.watch(routerProvider),theme:AppTheme.light(),darkTheme:AppTheme.dark(),themeMode:ref.watch(themeModeProvider),locale:ref.watch(localeProvider),supportedLocales:AppLocalizations.supportedLocales,localizationsDelegates:const [AppLocalizations.delegate,GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate,GlobalCupertinoLocalizations.delegate],localeResolutionCallback:(locale,supported)=>supported.firstWhere((l)=>l.languageCode==locale?.languageCode,orElse:()=>const Locale('ar'))); }
