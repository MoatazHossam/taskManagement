import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

extension LocalizationContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  Locale get currentLocale => Localizations.localeOf(this);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}
