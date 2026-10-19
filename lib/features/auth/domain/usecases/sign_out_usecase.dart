import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';

/// Cierra la sesión en Auth. Sin esto, la sesión seguiría abierta
/// en Supabase aunque la app muestre el login.
class SignOutUseCase {
  final AuthRepository _auth;

  SignOutUseCase(this._auth);

  Future<void> call() => _auth.signOut();
}
