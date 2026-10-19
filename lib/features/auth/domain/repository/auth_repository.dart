import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';

/// Contrato de autenticación: qué se le puede pedir a Auth,
/// sin decir quién lo cumple.
abstract class AuthRepository {
  /// Crea la cuenta y devuelve el [AuthUser] con su id.
  Future<AuthUser> signUp({required String email, required String password});

  /// Inicia sesión con correo y contraseña y devuelve la cuenta.
  Future<AuthUser> signIn({required String email, required String password});

  /// Cierra la sesión abierta en el servicio de autenticación.
  Future<void> signOut();
}
