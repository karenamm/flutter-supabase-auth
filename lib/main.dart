import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_profile_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/entities/user_account.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';
import 'package:moviles_auth/theme/app_theme.dart';

// Project Settings → API Keys en el dashboard de Supabase.
const _supabaseUrl = 'https://ulvohcubommngllcjvle.supabase.co';
const _supabasePublishableKey = 'sb_publishable_ABmYtOlztXjdbZKhYv-0Ig_Ary6Qodw';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );
  runApp(const App());
}

/// Root widget that declares the theme and the named routes.
///
/// Es la raíz de composición: el único lugar que conoce las clases
/// concretas de la capa de datos. Los repositorios se crean una sola vez
/// y se comparten entre registro e inicio de sesión.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final AuthRepository authRepository = AuthRepositoryImpl(
      SupabaseAuthDataSource(client),
    );
    final ProfileRepository profileRepository = ProfileRepositoryImpl(
      SupabaseProfileDataSource(client),
    );

    return MaterialApp(
      title: 'Moviles Auth',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => BlocProvider(
          create: (_) =>
              LoginBloc(SignInUseCase(authRepository, profileRepository)),
          child: const LoginScreen(),
        ),
        '/register': (_) => BlocProvider(
          create: (_) =>
              RegisterBloc(SignUpUseCase(authRepository, profileRepository)),
          child: const RegisterScreen(),
        ),
        '/home': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments;
          // Desde el login llega la cuenta completa, con el correo real.
          if (arguments is UserAccount) {
            return HomeScreen(
              username: arguments.username,
              fullName: arguments.fullName,
              email: arguments.email,
            );
          }
          // Desde el registro llega el Profile.
          if (arguments is Profile) {
            return HomeScreen(
              username: arguments.username,
              fullName: arguments.fullName,
            );
          }
          return const HomeScreen();
        },
      },
    );
  }
}
