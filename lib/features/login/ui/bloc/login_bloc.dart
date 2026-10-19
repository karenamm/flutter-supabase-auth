import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_event.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_state.dart';

export 'login_event.dart';
export 'login_state.dart';

/// Recibe [LoginSubmitted] y emite los estados del inicio de sesión.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUseCase _signIn;

  LoginBloc(this._signIn) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final account = await _signIn(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: LoginStatus.success, account: account));
    } catch (error) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
