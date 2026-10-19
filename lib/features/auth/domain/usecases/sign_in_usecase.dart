import 'package:moviles_auth/features/auth/domain/entities/user_account.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// La sesión se abrió pero no se pudo cargar la fila de `profiles`.
class ProfileNotFoundException implements Exception {
  const ProfileNotFoundException();

  @override
  String toString() =>
      'Iniciaste sesión, pero no pudimos cargar tu perfil. '
      'Intenta de nuevo más tarde.';
}

/// Iniciar sesión también son dos pasos, en este orden:
/// 1. signIn en Auth devuelve el AuthUser.
/// 2. Con su id, getProfile trae el perfil de la tabla.
class SignInUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SignInUseCase(this._auth, this._profiles);

  Future<UserAccount> call({
    required String email,
    required String password,
  }) async {
    final user = await _auth.signIn(email: email, password: password);
    try {
      final profile = await _profiles.getProfile(user.id);
      return UserAccount(user: user, profile: profile);
    } catch (_) {
      // Hay sesión pero no perfil (p. ej. falló el paso 2 del registro).
      // Se cierra la sesión para no dejarla abierta a medias.
      await _auth.signOut();
      throw const ProfileNotFoundException();
    }
  }
}
