/// Los datos que guardamos en la tabla `profiles`.
/// [id] es el mismo id de la cuenta en Auth.
class Profile {
  final String id;
  final String username;
  final String fullName;

  const Profile({
    required this.id,
    required this.username,
    required this.fullName,
  });
}
