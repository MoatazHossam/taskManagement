import 'package:flutter/material.dart';
import '../../app/theme/app_tokens.dart';
import 'connectivity_status_banner.dart';

class AppNavigationDestination { const AppNavigationDestination({required this.label,required this.icon}); final String label; final IconData icon; }
class AppResponsiveShell extends StatelessWidget {
 const AppResponsiveShell({super.key,required this.destinations,required this.selectedIndex,required this.onSelected,required this.child});
 final List<AppNavigationDestination> destinations; final int selectedIndex; final ValueChanged<int> onSelected; final Widget child;
 @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,c){final tablet=c.maxWidth>=AppBreakpoints.tablet; final content=Column(children:[const ConnectivityStatusBanner(),Expanded(child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:AppBreakpoints.readableContent),child:child)))]); if(tablet)return Scaffold(body:SafeArea(child:Row(children:[NavigationRail(selectedIndex:selectedIndex,onDestinationSelected:onSelected,labelType:NavigationRailLabelType.all,destinations:[for(final d in destinations)NavigationRailDestination(icon:Icon(d.icon),label:Text(d.label))]),const VerticalDivider(width:1),Expanded(child:content)]))); return Scaffold(body:SafeArea(child:content),bottomNavigationBar:NavigationBar(selectedIndex:selectedIndex,onDestinationSelected:onSelected,destinations:[for(final d in destinations)NavigationDestination(icon:Icon(d.icon),label:d.label)]));});
}
