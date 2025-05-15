class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

class BookException extends AppException {
  BookException(super.message, {super.code});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

class StorageException extends AppException {
  StorageException(super.message, {super.code});
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code});
} 