import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/entities/user_account.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';

/// Auth en memoria: cumple el contrato sin hablar con Supabase.
class FakeAuthRepository implements AuthRepository {
  final Map<String, String> _passwords = {'ana@icesi.edu.co': '123456'};
  bool signedOut = false;

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    if (_passwords.containsKey(email)) {
      throw const AuthFailure('User already registered');
    }
    _passwords[email] = password;
    return AuthUser(id: 'id-$email', email: email);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (_passwords[email] != password) {
      throw const AuthFailure('Invalid login credentials');
    }
    return AuthUser(id: 'id-$email', email: email);
  }

  @override
  Future<void> signOut() async => signedOut = true;
}

/// Tabla profiles en memoria.
class FakeProfileRepository implements ProfileRepository {
  final Map<String, Profile> _rows = {
    'id-ana@icesi.edu.co': const Profile(
      id: 'id-ana@icesi.edu.co',
      username: 'ana',
      fullName: 'Ana Gómez',
    ),
  };

  @override
  Future<void> createProfile(Profile profile) async {
    _rows[profile.id] = profile;
  }

  @override
  Future<Profile> getProfile(String id) async => _rows[id]!;
}

/// Las mismas rutas de App, pero armadas con los repositorios falsos.
/// Así se prueba la UI y los Blocs sin inicializar Supabase.
Widget buildTestApp(AuthRepository auth, ProfileRepository profiles) {
  return MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (_) => BlocProvider(
        create: (_) => LoginBloc(SignInUseCase(auth, profiles)),
        child: const LoginScreen(),
      ),
      '/register': (_) => BlocProvider(
        create: (_) => RegisterBloc(SignUpUseCase(auth, profiles)),
        child: const RegisterScreen(),
      ),
      '/home': (context) {
        final account =
            ModalRoute.of(context)!.settings.arguments as UserAccount;
        return HomeScreen(
          username: account.username,
          fullName: account.fullName,
          email: account.email,
          signOut: SignOutUseCase(auth),
        );
      },
    },
  );
}

Future<void> tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;

  setUp(() {
    auth = FakeAuthRepository();
    profiles = FakeProfileRepository();
  });

  testWidgets('login con campos vacíos muestra la validación local', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(auth, profiles));

    await tapButton(tester, 'Iniciar sesión');

    expect(find.text('Escribe tu correo y tu contraseña'), findsOneWidget);
  });

  testWidgets('login con contraseña incorrecta muestra el error de Auth', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(auth, profiles));

    await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), 'malaclave');
    await tapButton(tester, 'Iniciar sesión');

    expect(find.text('Invalid login credentials'), findsOneWidget);
  });

  testWidgets('login correcto muestra el perfil y cerrar sesión vuelve', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(auth, profiles));

    await tester.enterText(find.byType(TextField).at(0), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tapButton(tester, 'Iniciar sesión');

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Ana Gómez'), findsWidgets);
    expect(find.text('ana@icesi.edu.co'), findsOneWidget);

    await tapButton(tester, 'Cerrar sesión');

    expect(auth.signedOut, isTrue);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('registro rechaza contraseñas distintas y luego registra', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(auth, profiles));
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'luis');
    await tester.enterText(find.byType(TextField).at(1), 'Luis Pérez');
    await tester.enterText(find.byType(TextField).at(2), 'luis@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(3), '123456');
    await tester.enterText(find.byType(TextField).at(4), '654321');
    await tapButton(tester, 'Registrarme');
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(4), '123456');
    await tapButton(tester, 'Registrarme');

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('@luis'), findsOneWidget);
    expect(find.text('luis@icesi.edu.co'), findsOneWidget);
  });

  testWidgets('registro con correo existente muestra el error de Auth', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(auth, profiles));
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'ana2');
    await tester.enterText(find.byType(TextField).at(1), 'Ana Gómez');
    await tester.enterText(find.byType(TextField).at(2), 'ana@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(3), '123456');
    await tester.enterText(find.byType(TextField).at(4), '123456');
    await tapButton(tester, 'Registrarme');

    expect(find.text('User already registered'), findsOneWidget);
  });
}
