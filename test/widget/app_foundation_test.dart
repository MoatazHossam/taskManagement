import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:organization_task_manager/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/app/app.dart';
import 'package:organization_task_manager/app/dependency_injection/app_providers.dart';
import 'package:organization_task_manager/core/widgets/connectivity_status_banner.dart';
import 'package:organization_task_manager/core/widgets/feature_placeholder_page.dart';
import 'package:organization_task_manager/features/authentication/presentation/authentication_pages.dart';
import 'package:organization_task_manager/shared/enums/app_enums.dart';
import 'package:organization_task_manager/shared/models/demo_user_profile.dart';

void main(){
 testWidgets('application starts and language direction changes', (tester) async {await tester.pumpWidget(const ProviderScope(child:TaskManagementApp()));await tester.pumpAndSettle();expect(find.byType(LanguageSelectionPage),findsOneWidget);final e=ProviderScope.containerOf(tester.element(find.byType(LanguageSelectionPage)));e.read(localeProvider.notifier).state=const Locale('ar');await tester.pump();expect(Directionality.of(tester.element(find.byType(LanguageSelectionPage))),TextDirection.rtl);e.read(localeProvider.notifier).state=const Locale('en');await tester.pump();expect(Directionality.of(tester.element(find.byType(LanguageSelectionPage))),TextDirection.ltr);});
 for(final entry in <DemoUserRole,String>{DemoUserRole.employee:'employee',DemoUserRole.manager:'manager',DemoUserRole.seniorManagement:'senior',DemoUserRole.administrator:'administrator'}.entries){testWidgets('${entry.key.name} profile opens its navigation',(tester)async{final profile=demoProfiles.firstWhere((p)=>p.id==entry.value);await tester.pumpWidget(ProviderScope(overrides:[sessionProvider.overrideWith((ref){final c=SessionController();c.authenticate(profile);return c;})],child:const TaskManagementApp()));await tester.pumpAndSettle();expect(find.byType(NavigationBar),findsOneWidget);});}
 testWidgets('offline and unstable banners are explicit',(tester)async{final c=ProviderContainer();addTearDown(c.dispose);await tester.pumpWidget(UncontrolledProviderScope(container:c,child:const _LocalizedTestApp(child:Scaffold(body:ConnectivityStatusBanner()))));c.read(connectivityProvider.notifier).state=SimulatedConnectivityStatus.offline;await tester.pump();expect(find.byIcon(Icons.cloud_off_outlined),findsOneWidget);c.read(connectivityProvider.notifier).state=SimulatedConnectivityStatus.unstable;await tester.pump();expect(find.byIcon(Icons.signal_wifi_statusbar_connected_no_internet_4),findsOneWidget);});
 testWidgets('placeholder is honest and survives large text',(tester)async{await tester.pumpWidget(const _LocalizedTestApp(child:MediaQuery(data:MediaQueryData(textScaler:TextScaler.linear(2)),child:FeaturePlaceholderPage(title:'Placeholder',role:'Employee',icon:Icons.task_alt))));expect(tester.takeException(),isNull);});
}

class _LocalizedTestApp extends StatelessWidget {
 const _LocalizedTestApp({required this.child});
 final Widget child;
 @override
 Widget build(BuildContext context)=>MaterialApp(locale:const Locale('en'),supportedLocales:AppLocalizations.supportedLocales,localizationsDelegates:const [AppLocalizations.delegate,GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate,GlobalCupertinoLocalizations.delegate],home:child);
}
