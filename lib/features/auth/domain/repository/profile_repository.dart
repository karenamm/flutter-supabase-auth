import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// Contrato del perfil: cómo se guarda un [Profile].
abstract class ProfileRepository {
  Future<void> createProfile(Profile profile);
}
