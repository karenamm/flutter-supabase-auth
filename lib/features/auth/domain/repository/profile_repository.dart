import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// Contrato del perfil: cómo se guarda un [Profile].
abstract class ProfileRepository {
  Future<void> createProfile(Profile profile);

  /// Trae el perfil cuyo id es el de la cuenta.
  Future<Profile> getProfile(String id);
}
