/// La cuenta que devuelve el servicio de autenticación.
/// La contraseña nunca se guarda aquí: solo viaja hasta Auth.
class AuthUser {
  final String id;
  final String email;

  const AuthUser({required this.id, required this.email});
}
