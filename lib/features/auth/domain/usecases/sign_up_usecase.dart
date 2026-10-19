import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Error del registro cuando la cuenta se creó pero el perfil no.
class ProfileNotSavedException implements Exception {
  final String message;
  final Object cause;

  const ProfileNotSavedException(this.message, this.cause);

  @override
  String toString() => message;
}

/// Registrar son dos pasos, en este orden:
/// 1. Crear la cuenta en Auth (devuelve el id).
/// 2. Guardar el perfil en la tabla con ese mismo id.
/// Es la única pieza que conoce los dos contratos.
class SignUpUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SignUpUseCase(this._auth, this._profiles);

  Future<Profile> call({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    // 1.º La cuenta. Si falla (p. ej. correo repetido), la excepción
    // sube tal cual al Bloc y no se intenta guardar el perfil.
    final user = await _auth.signUp(email: email, password: password);

    // 2.º El perfil, con el id que devolvió Auth.
    final profile = Profile(
      id: user.id,
      username: username,
      fullName: fullName,
    );
    try {
      await _profiles.createProfile(profile);
    } catch (error) {
      // La cuenta ya existe pero quedó sin perfil. Lo decide el caso de
      // uso, no el Bloc: se informa con un mensaje claro y se conserva
      // la causa original para depurar.
      throw ProfileNotSavedException(
        'Tu cuenta se creó, pero no pudimos guardar tu perfil. '
        'Intenta de nuevo más tarde.',
        error,
      );
    }
    return profile;
  }
}
