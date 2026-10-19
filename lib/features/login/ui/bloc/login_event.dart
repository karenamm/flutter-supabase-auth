/// Eventos que la pantalla de inicio de sesión le envía al [LoginBloc].
abstract class LoginEvent {}

/// Se lanza cuando el usuario pulsa "Iniciar sesión" con los campos llenos.
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}
