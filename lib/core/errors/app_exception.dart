class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AppDatabaseException extends AppException {
  const AppDatabaseException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

class DuplicateRecordException extends AppException {
  const DuplicateRecordException(super.message, {super.code, super.details});
}
