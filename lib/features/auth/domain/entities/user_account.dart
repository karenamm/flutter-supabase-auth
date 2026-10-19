import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// La cuenta (Auth) y el perfil (tabla) de quien inició sesión.
/// Junta las dos mitades para que la pantalla de inicio tenga el correo
/// real además del username y el nombre.
class UserAccount {
  final AuthUser user;
  final Profile profile;

  const UserAccount({required this.user, required this.profile});

  String get email => user.email;
  String get username => profile.username;
  String get fullName => profile.fullName;
}
