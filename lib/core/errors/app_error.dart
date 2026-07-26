import '../../l10n/app_localizations.dart';

enum AppErrorType { validation, permission, notFound, localStorage, connectivity, unknown }
class AppError { const AppError(this.type); final AppErrorType type; }
extension AppErrorLocalization on AppError {
  String message(AppLocalizations l10n) => switch(type) {
    AppErrorType.validation => l10n.validationError,
    AppErrorType.permission => l10n.permissionError,
    AppErrorType.notFound => l10n.notFoundError,
    AppErrorType.localStorage => l10n.storageError,
    AppErrorType.connectivity => l10n.connectivityError,
    AppErrorType.unknown => l10n.unknownError,
  };
}

final class DataLayerException implements Exception {
  const DataLayerException([this.error=const AppError(AppErrorType.localStorage)]);
  final AppError error;
  @override String toString()=>'DataLayerException(${error.type.name})';
}
