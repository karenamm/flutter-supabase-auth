import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';

/// Contrato de autenticación: qué se le puede pedir a Auth,
/// sin decir quién lo cumple.
abstract class AuthRepository {
  /// Crea la cuenta y devuelve el [AuthUser] con su id.
  Future<AuthUser> signUp({required String email, required String password});
}
