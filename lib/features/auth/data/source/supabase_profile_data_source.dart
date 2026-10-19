import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// El único archivo que conoce la tabla `profiles` y sus columnas.
/// En Dart el campo es `fullName`; en la tabla, la columna es `full_name`.
class SupabaseProfileDataSource {
  static const _table = 'profiles';

  final SupabaseClient _client;

  SupabaseProfileDataSource(this._client);

  Future<void> createProfile(Profile profile) async {
    // Funciona porque después de signUp ya hay sesión y el grant
    // de la tabla permite insertar al rol `authenticated`.
    await _client.from(_table).insert({
      'id': profile.id,
      'username': profile.username,
      'full_name': profile.fullName,
    });
  }
}
