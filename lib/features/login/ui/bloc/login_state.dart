import 'package:moviles_auth/features/auth/domain/entities/user_account.dart';

/// Los cuatro momentos del inicio de sesión.
enum LoginStatus { initial, loading, success, failure }

/// Estado único del login, con la misma forma que RegisterState.
class LoginState {
  final LoginStatus status;
  final UserAccount? account;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.account,
    this.errorMessage,
  });

  bool get isLoading => status == LoginStatus.loading;

  LoginState copyWith({
    LoginStatus? status,
    UserAccount? account,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      account: account ?? this.account,
      // El mensaje no se arrastra: si no llega uno nuevo, se limpia.
      errorMessage: errorMessage,
    );
  }
}
