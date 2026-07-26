import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/dependency_injection/app_providers.dart';
import '../../app/localization/localization_extensions.dart';
import '../../shared/enums/app_enums.dart';

class ConnectivityStatusBanner extends ConsumerWidget {
 const ConnectivityStatusBanner({super.key});
 @override Widget build(BuildContext context,WidgetRef ref){ final status=ref.watch(connectivityProvider); if(status==SimulatedConnectivityStatus.online)return const SizedBox.shrink(); final offline=status==SimulatedConnectivityStatus.offline; final color=offline?Theme.of(context).colorScheme.errorContainer:Theme.of(context).colorScheme.tertiaryContainer; return Semantics(liveRegion:true,child:Material(color:color,child:Padding(padding:const EdgeInsets.all(10),child:Row(children:[Icon(offline?Icons.cloud_off_outlined:Icons.signal_wifi_statusbar_connected_no_internet_4),const SizedBox(width:8),Expanded(child:Text(offline?context.l10n.offlineBanner:context.l10n.unstableBanner))])))); }
}
