import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';

/// Error de autenticación con un mensaje listo para mostrar.
class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

/// El único archivo que usa el SDK de Auth de Supabase.
/// Convierte las respuestas de Supabase en entidades del dominio.
class SupabaseAuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return _toAuthUser(response.user);
    } on AuthException catch (error) {
      // Ej.: "User already registered", contraseña muy corta, etc.
      throw AuthFailure(error.message);
    }
  }

  /// response.user puede ser null: se valida antes de usarlo
  /// para no caer en "Null check operator used on a null value".
  AuthUser _toAuthUser(User? user) {
    if (user == null) {
      throw const AuthFailure('No se pudo crear la cuenta. Intenta de nuevo.');
    }
    return AuthUser(id: user.id, email: user.email ?? '');
  }
}
