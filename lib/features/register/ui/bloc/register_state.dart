import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// Los cuatro momentos por los que pasa el registro.
enum RegisterStatus { initial, loading, success, failure }

/// Estado único del registro: el campo [status] dice en qué momento está
/// y [copyWith] cambia solo lo necesario, conservando el resto.
class RegisterState {
  final RegisterStatus status;
  final Profile? profile;
  final String? errorMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.profile,
    this.errorMessage,
  });

  bool get isLoading => status == RegisterStatus.loading;

  RegisterState copyWith({
    RegisterStatus? status,
    Profile? profile,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      // El mensaje no se arrastra: si no llega uno nuevo, se limpia.
      errorMessage: errorMessage,
    );
  }
}
