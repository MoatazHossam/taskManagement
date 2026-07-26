import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:organization_task_manager/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/app/app.dart';
import 'package:organization_task_manager/app/dependency_injection/app_providers.dart';
import 'package:organization_task_manager/app/theme/app_theme.dart';
import 'package:organization_task_manager/core/widgets/app_design_system.dart';
import 'package:organization_task_manager/core/widgets/connectivity_status_banner.dart';
import 'package:organization_task_manager/core/widgets/feature_placeholder_page.dart';
import 'package:organization_task_manager/features/authentication/presentation/authentication_pages.dart';
import 'package:organization_task_manager/features/home/presentation/home_page.dart';
import 'package:organization_task_manager/features/profile/presentation/profile_page.dart';
import 'package:organization_task_manager/shared/enums/app_enums.dart';
import 'package:organization_task_manager/shared/models/demo_user_profile.dart';

void main(){
 testWidgets('application starts and language direction changes', (tester) async {await tester.pumpWidget(const ProviderScope(child:TaskManagementApp()));await tester.pumpAndSettle();expect(find.byType(LanguageSelectionPage),findsOneWidget);final e=ProviderScope.containerOf(tester.element(find.byType(LanguageSelectionPage)));e.read(localeProvider.notifier).state=const Locale('ar');await tester.pump();expect(Directionality.of(tester.element(find.byType(LanguageSelectionPage))),TextDirection.rtl);e.read(localeProvider.notifier).state=const Locale('en');await tester.pump();expect(Directionality.of(tester.element(find.byType(LanguageSelectionPage))),TextDirection.ltr);});
 for(final entry in <DemoUserRole,String>{DemoUserRole.employee:'employee',DemoUserRole.manager:'manager',DemoUserRole.seniorManagement:'senior',DemoUserRole.administrator:'administrator'}.entries){testWidgets('${entry.key.name} profile opens its navigation',(tester)async{final profile=demoProfiles.firstWhere((p)=>p.id==entry.value);await tester.pumpWidget(ProviderScope(overrides:[sessionProvider.overrideWith((ref){final c=SessionController();c.authenticate(profile);return c;})],child:const TaskManagementApp()));await tester.pumpAndSettle();expect(find.byType(NavigationBar),findsOneWidget);});}
 testWidgets('offline and unstable banners are explicit',(tester)async{final c=ProviderContainer();addTearDown(c.dispose);await tester.pumpWidget(UncontrolledProviderScope(container:c,child:const _LocalizedTestApp(child:Scaffold(body:ConnectivityStatusBanner()))));c.read(connectivityProvider.notifier).state=SimulatedConnectivityStatus.offline;await tester.pump();expect(find.byIcon(Icons.cloud_off_outlined),findsOneWidget);c.read(connectivityProvider.notifier).state=SimulatedConnectivityStatus.unstable;await tester.pump();expect(find.byIcon(Icons.signal_wifi_statusbar_connected_no_internet_4),findsOneWidget);});
 testWidgets('placeholder is honest and survives large text',(tester)async{await tester.pumpWidget(const _LocalizedTestApp(child:MediaQuery(data:MediaQueryData(textScaler:TextScaler.linear(2)),child:FeaturePlaceholderPage(title:'Placeholder',role:'Employee',icon:Icons.task_alt))));expect(tester.takeException(),isNull);});

 testWidgets('employee dashboard is compact at small-phone width',(tester)async{
  tester.view.physicalSize=const Size(320,568); tester.view.devicePixelRatio=1; addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_profileApp(locale:const Locale('ar'),child:const RoleHomePage(title:'Home'))); await tester.pump();
  expect(find.byType(AppMetricCard),findsNWidgets(4)); expect(find.byType(AppTaskPreviewTile),findsWidgets); expect(tester.takeException(),isNull);
 });
 testWidgets('employee dashboard supports large-phone width and large text',(tester)async{
  tester.view.physicalSize=const Size(430,932); tester.view.devicePixelRatio=1; addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_profileApp(locale:const Locale('en'),textScaler:const TextScaler.linear(1.5),child:const RoleHomePage(title:'Home'))); await tester.pump();
  expect(find.byType(AppMetricCard),findsNWidgets(4)); expect(tester.takeException(),isNull);
 });
 for(final locale in const [Locale('ar'),Locale('en')]){
  testWidgets('profile has one identity treatment in ${locale.languageCode}',(tester)async{
   await tester.pumpWidget(_profileApp(locale:locale,child:ProfilePage(openGallery:(){}))); await tester.pump();
   expect(find.byType(AppAvatar),findsOneWidget); expect(find.byType(ConnectivitySelector),findsOneWidget); expect(tester.takeException(),isNull);
  });
 }
 testWidgets('dark mode surfaces and long Arabic connectivity option render',(tester)async{
  await tester.pumpWidget(_profileApp(locale:const Locale('ar'),dark:true,child:ProfilePage(openGallery:(){}))); await tester.pump();
  expect(find.text('اتصال غير مستقر'),findsOneWidget); expect(tester.takeException(),isNull);
 });
 testWidgets('connectivity option selection is exposed',(tester)async{
  var value=SimulatedConnectivityStatus.online;
  await tester.pumpWidget(_LocalizedTestApp(child:StatefulBuilder(builder:(context,setState)=>ConnectivitySelector(value:value,onChanged:(next)=>setState(()=>value=next)))));
  await tester.tap(find.byKey(const ValueKey(SimulatedConnectivityStatus.unstable))); await tester.pump(); expect(value,SimulatedConnectivityStatus.unstable);
 });
 testWidgets('language control changes selection',(tester)async{
  var locale=const Locale('en');
  await tester.pumpWidget(_LocalizedTestApp(child:StatefulBuilder(builder:(context,setState)=>SegmentationLanguageSelector(locale:locale,onChanged:(next)=>setState(()=>locale=next)))));
  await tester.tap(find.text('Arabic')); await tester.pump(); expect(locale.languageCode,'ar');
 });
 testWidgets('primary scroll view reserves phone navigation clearance',(tester)async{
  await tester.pumpWidget(const _LocalizedTestApp(child:AppPrimaryScrollView(children:[SizedBox(height:900)]))); final list=tester.widget<ListView>(find.byKey(const Key('primary-scroll-view'))); final padding=list.padding!.resolve(TextDirection.ltr);
  expect(padding.bottom,greaterThanOrEqualTo(80));
 });
}

Widget _profileApp({required Locale locale,required Widget child,bool dark=false,TextScaler textScaler=TextScaler.noScaling}){
 final profile=demoProfiles.firstWhere((profile)=>profile.id=='employee');
 return ProviderScope(overrides:[sessionProvider.overrideWith((ref){final controller=SessionController();controller.authenticate(profile);return controller;})],child:_LocalizedTestApp(locale:locale,dark:dark,textScaler:textScaler,child:child));
}

class _LocalizedTestApp extends StatelessWidget {
 const _LocalizedTestApp({required this.child,this.locale=const Locale('en'),this.dark=false,this.textScaler=TextScaler.noScaling});
 final Widget child;
 final Locale locale;
 final bool dark;
 final TextScaler textScaler;
 @override
 Widget build(BuildContext context)=>MaterialApp(locale:locale,theme:AppTheme.light(),darkTheme:AppTheme.dark(),themeMode:dark?ThemeMode.dark:ThemeMode.light,supportedLocales:AppLocalizations.supportedLocales,localizationsDelegates:const [AppLocalizations.delegate,GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate,GlobalCupertinoLocalizations.delegate],home:Builder(builder:(context)=>MediaQuery(data:MediaQuery.of(context).copyWith(textScaler:textScaler),child:Scaffold(body:child))));
}
