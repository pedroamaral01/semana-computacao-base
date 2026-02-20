class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;

  AuthResult({required this.success, this.errorMessage, this.errorCode});

  factory AuthResult.success() {
    return AuthResult(success: true);
  }

  factory AuthResult.failure({required String message, String? code}) {
    return AuthResult(success: false, errorMessage: message, errorCode: code);
  }
}
