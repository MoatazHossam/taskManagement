import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'connectivity_status_banner.dart';

class AppNavigationDestination {
  const AppNavigationDestination({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class AppResponsiveShell extends StatelessWidget {
  const AppResponsiveShell({super.key, required this.destinations, required this.selectedIndex, required this.onSelected, required this.child});
  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final tablet = constraints.maxWidth >= AppBreakpoints.tablet;
        final content = Column(children: [
          const ConnectivityStatusBanner(),
          Expanded(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: AppSizes.pageMax), child: child))),
        ]);
        if (tablet) {
          return Scaffold(body: SafeArea(child: Row(children: [
            SizedBox(width: AppSizes.navigationRail, child: Column(children: [
              Padding(padding: const EdgeInsets.all(AppSpacing.large), child: Row(children: [
                Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(AppRadii.medium)), child: Icon(Icons.fact_check_outlined, color: Theme.of(context).colorScheme.onPrimary)),
                const SizedBox(width: AppSpacing.small),
                Expanded(child: Text('TaskFlow', style: Theme.of(context).textTheme.titleLarge)),
              ])),
              Expanded(child: NavigationRail(
                extended: true,
                minExtendedWidth: AppSizes.navigationRail,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                destinations: [for (final destination in destinations) NavigationRailDestination(icon: Icon(destination.icon), selectedIcon: Icon(destination.icon, fill: 1), label: Text(destination.label))],
              )),
              Padding(padding: const EdgeInsets.all(AppSpacing.medium), child: Text('Enterprise demo • 1.0', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ])),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ])));
        }
        return Scaffold(
          appBar: AppBar(title: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(AppRadii.small)), child: Icon(Icons.fact_check_outlined, size: 20, color: Theme.of(context).colorScheme.onPrimary)), const SizedBox(width: AppSpacing.small), const Text('TaskFlow')]), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded))]),
          body: SafeArea(top: false, child: content),
          bottomNavigationBar: NavigationBar(selectedIndex: selectedIndex, onDestinationSelected: onSelected, destinations: [for (final destination in destinations) NavigationDestination(icon: Icon(destination.icon), selectedIcon: Icon(destination.icon, fill: 1), label: destination.label)]),
        );
      });
}
