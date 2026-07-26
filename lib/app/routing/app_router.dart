import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/authentication_pages.dart';
import '../../features/profile/presentation/foundation_gallery_page.dart';
import '../../shared/enums/app_enums.dart';
import '../dependency_injection/app_providers.dart';
import 'role_shell_page.dart';

abstract final class AppRoutes { static const splash='/splash', language='/language', login='/login', unlock='/unlock', app='/app', gallery='/gallery'; }
String roleRoot(DemoUserRole role)=>switch(role){DemoUserRole.employee=>'/app/employee/home',DemoUserRole.manager=>'/app/manager/home',DemoUserRole.seniorManagement=>'/app/senior/executive',DemoUserRole.administrator=>'/app/admin/home'};
bool canAccessRolePath(DemoUserRole role,String path)=>path.startsWith(roleRoot(role).split('/').take(3).join('/'));

final routerProvider=Provider<GoRouter>((ref){final session=ref.watch(sessionProvider); return GoRouter(initialLocation:AppRoutes.splash,redirect:(context,state){final path=state.matchedLocation; if(session.status==AuthenticationStatus.initializing)return path==AppRoutes.splash?null:AppRoutes.splash; if(path==AppRoutes.splash)return ref.read(localeProvider)==null?AppRoutes.language:(session.status==AuthenticationStatus.authenticated?roleRoot(session.profile!.role):session.status==AuthenticationStatus.locked?AppRoutes.unlock:AppRoutes.login); if(session.status==AuthenticationStatus.unauthenticated&&path!=AppRoutes.language&&path!=AppRoutes.login)return ref.read(localeProvider)==null?AppRoutes.language:AppRoutes.login; if(session.status==AuthenticationStatus.locked&&path!=AppRoutes.unlock)return AppRoutes.unlock; if(session.status==AuthenticationStatus.selectingProfile||session.status==AuthenticationStatus.expired||session.status==AuthenticationStatus.failure){if(path!=AppRoutes.login)return AppRoutes.login;} if(session.status==AuthenticationStatus.authenticated){final profile=session.profile!; if(path==AppRoutes.login||path==AppRoutes.language||path==AppRoutes.splash||path==AppRoutes.unlock)return roleRoot(profile.role); if(path.startsWith('/app/')&&!canAccessRolePath(profile.role,path))return roleRoot(profile.role);} return null;},routes:[GoRoute(path:AppRoutes.splash,builder:(c,s)=>const SplashPage()),GoRoute(path:AppRoutes.language,builder:(c,s)=>const LanguageSelectionPage()),GoRoute(path:AppRoutes.login,builder:(c,s)=>const DemoLoginPage()),GoRoute(path:AppRoutes.unlock,builder:(c,s)=>const PinUnlockPage()),GoRoute(path:'/app/:role/:section',builder:(c,s)=>RoleShellPage(section:s.pathParameters['section']!)),GoRoute(path:AppRoutes.gallery,builder:(c,s)=>const FoundationGalleryPage())]);});
