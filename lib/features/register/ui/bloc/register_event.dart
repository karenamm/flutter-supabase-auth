/// Eventos que la pantalla de registro le envía al [RegisterBloc].
abstract class RegisterEvent {}

/// Se lanza cuando el usuario pulsa "Registrarme" y el formulario
/// ya pasó las validaciones locales (campos vacíos y contraseñas iguales).
class RegisterSubmitted extends RegisterEvent {
  final String username;
  final String fullName;
  final String email;
  final String password;

  RegisterSubmitted({
    required this.username,
    required this.fullName,
    required this.email,
    required this.password,
  });
}
