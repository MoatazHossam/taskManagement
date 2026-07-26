import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/authentication_pages.dart';
import '../../features/profile/presentation/foundation_gallery_page.dart';
import '../../shared/enums/app_enums.dart';
import '../dependency_injection/app_providers.dart';
import 'role_shell_page.dart';

abstract final class AppRoutes { static const splash='/splash', language='/language', login='/login', app='/app', gallery='/gallery'; }
String roleRoot(DemoUserRole role)=>switch(role){DemoUserRole.employee=>'/app/employee/home',DemoUserRole.manager=>'/app/manager/home',DemoUserRole.seniorManagement=>'/app/senior/executive',DemoUserRole.administrator=>'/app/admin/home'};
bool canAccessRolePath(DemoUserRole role,String path)=>path.startsWith(roleRoot(role).split('/').take(3).join('/'));

final routerProvider=Provider<GoRouter>((ref){final session=ref.watch(sessionProvider); return GoRouter(initialLocation:AppRoutes.splash,redirect:(context,state){final path=state.matchedLocation; if(path==AppRoutes.splash)return session.status==AuthenticationStatus.unauthenticated?AppRoutes.language:AppRoutes.login; if(session.status==AuthenticationStatus.unauthenticated&&path!=AppRoutes.language)return AppRoutes.language; if(session.status==AuthenticationStatus.selectingProfile||session.status==AuthenticationStatus.expired){if(path!=AppRoutes.login)return AppRoutes.login;} if(session.status==AuthenticationStatus.authenticated){final profile=session.profile!; if(path==AppRoutes.login||path==AppRoutes.language||path==AppRoutes.splash)return roleRoot(profile.role); if(path.startsWith('/app/')&&!canAccessRolePath(profile.role,path))return roleRoot(profile.role);} return null;},routes:[GoRoute(path:AppRoutes.splash,builder:(c,s)=>const SplashPage()),GoRoute(path:AppRoutes.language,builder:(c,s)=>const LanguageSelectionPage()),GoRoute(path:AppRoutes.login,builder:(c,s)=>const DemoLoginPage()),GoRoute(path:'/app/:role/:section',builder:(c,s)=>RoleShellPage(section:s.pathParameters['section']!)),GoRoute(path:AppRoutes.gallery,builder:(c,s)=>const FoundationGalleryPage())]);});
