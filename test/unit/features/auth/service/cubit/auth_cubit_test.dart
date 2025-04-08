import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';
import 'package:pos_machine/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_cubit.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

// Adicionamos um fallback para AuthCredentials
class FakeAuthCredentials extends Fake implements AuthCredentials {}

void main() {
  late AuthCubit cubit;
  late MockAuthRepository mockRepository;

  setUpAll(() {
    // Registrar fallback para AuthCredentials
    registerFallbackValue(FakeAuthCredentials());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    cubit = AuthCubit(repository: mockRepository);

    // Mock para a verificação inicial no construtor
    when(() => mockRepository.isAuthenticated()).thenAnswer((_) async => false);
    when(() => mockRepository.getToken()).thenAnswer((_) async => null);
  });

  group('AuthCubit', () {
    test(
      'o estado inicial deve ser AuthInitial e checkAuthStatus deve ser chamado',
      () {
        // Estado inicial deve ser AuthInitial
        expect(cubit.state, isA<AuthInitial>());

        // Verificar se checkAuthStatus foi chamado no construtor
        verify(() => mockRepository.isAuthenticated()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuthStatus deve emitir AuthSuccess quando usuário estiver autenticado',
      build: () {
        when(
          () => mockRepository.isAuthenticated(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getToken(),
        ).thenAnswer((_) async => 'test_token');
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthSuccess>()],
      verify: (_) {
        verify(() => mockRepository.isAuthenticated()).called(1);
        verify(() => mockRepository.getToken()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuthStatus deve emitir AuthInitial quando usuário não estiver autenticado',
      build: () {
        when(
          () => mockRepository.isAuthenticated(),
        ).thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthInitial>()],
      verify: (_) {
        verify(() => mockRepository.isAuthenticated()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuthStatus deve emitir AuthInitial quando token não estiver disponível',
      build: () {
        when(
          () => mockRepository.isAuthenticated(),
        ).thenAnswer((_) async => true);
        when(() => mockRepository.getToken()).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthInitial>()],
      verify: (_) {
        verify(() => mockRepository.isAuthenticated()).called(1);
        verify(() => mockRepository.getToken()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuthStatus deve emitir AuthError em caso de exceção',
      build: () {
        when(
          () => mockRepository.isAuthenticated(),
        ).thenThrow(Exception('Erro de teste'));
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthError>()],
      verify: (_) {
        verify(() => mockRepository.isAuthenticated()).called(1);
      },
    );

    final testUsername = 'admin';
    final testPassword = 'password123';

    blocTest<AuthCubit, AuthState>(
      'login deve emitir AuthLoading e depois AuthSuccess quando bem-sucedido',
      build: () {
        when(
          () => mockRepository.login(any()),
        ).thenAnswer((_) async => 'test_token');
        when(
          () => mockRepository.refreshSession(),
        ).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.login(testUsername, testPassword),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
      verify: (_) {
        verify(() => mockRepository.login(any())).called(1);
        verify(() => mockRepository.refreshSession()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'login deve emitir AuthLoading e depois AuthError em caso de falha',
      build: () {
        when(
          () => mockRepository.login(any()),
        ).thenThrow(Exception('Erro de login'));
        return cubit;
      },
      act: (cubit) => cubit.login(testUsername, testPassword),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      verify: (_) {
        verify(() => mockRepository.login(any())).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'logout deve emitir AuthInitial e chamar logout no repositório',
      build: () {
        when(() => mockRepository.logout()).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [isA<AuthInitial>()],
      verify: (_) {
        verify(() => mockRepository.logout()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'logout deve emitir AuthError em caso de exceção',
      build: () {
        when(
          () => mockRepository.logout(),
        ).thenThrow(Exception('Erro de logout'));
        return cubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [isA<AuthError>()],
      verify: (_) {
        verify(() => mockRepository.logout()).called(1);
      },
    );

    test(
      'refreshSession deve chamar o método correspondente no repositório',
      () async {
        // Configurar o estado para ser AuthSuccess
        when(
          () => mockRepository.isAuthenticated(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getToken(),
        ).thenAnswer((_) async => 'test_token');
        await cubit.checkAuthStatus(); // Colocar no estado AuthSuccess

        when(
          () => mockRepository.refreshSession(),
        ).thenAnswer((_) async => true);

        await cubit.refreshSession();

        verify(() => mockRepository.refreshSession()).called(1);
      },
    );

    test(
      'refreshSession não deve fazer nada se o estado não for AuthSuccess',
      () async {
        // Garantir que o estado é AuthInitial
        when(
          () => mockRepository.isAuthenticated(),
        ).thenAnswer((_) async => false);
        await cubit.checkAuthStatus();

        // Configurar mock para refreshSession
        when(
          () => mockRepository.refreshSession(),
        ).thenAnswer((_) async => true);

        // Chamar refreshSession
        await cubit.refreshSession();

        // Verificar que refreshSession não foi chamado
        verifyNever(() => mockRepository.refreshSession());
      },
    );
  });
}
