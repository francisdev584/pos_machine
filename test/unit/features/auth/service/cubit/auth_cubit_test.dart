import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';
import 'package:pos_machine/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_cubit.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

// Adicionamos um fallback para AuthCredentials
class FakeAuthCredentials extends Fake implements AuthCredentials {}

void main() {
  late MockAuthRepository mockRepository;

  setUpAll(() {
    // Registrar fallback para AuthCredentials
    registerFallbackValue(FakeAuthCredentials());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    // Configurar os mocks para o setup padrão
    when(() => mockRepository.isAuthenticated()).thenAnswer((_) async => false);
    when(() => mockRepository.getToken()).thenAnswer((_) async => null);
  });

  group('AuthCubit', () {
    test('o estado inicial deve ser AuthInitial', () {
      // Iniciar cubit e verificar estado inicial
      final cubit = AuthCubit(repository: mockRepository);
      expect(cubit.state, isA<AuthInitial>());
    });

    // Exemplo usando blocTest para demonstrar a sintaxe
    blocTest<AuthCubit, AuthState>(
      'login emite estados corretos quando bem-sucedido',
      build: () {
        mockRepository = MockAuthRepository();
        when(
          () => mockRepository.isAuthenticated(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.login(any()),
        ).thenAnswer((_) async => 'token_test');
        return AuthCubit(repository: mockRepository);
      },
      seed: () => AuthInitial(),
      act: (cubit) => cubit.login('username', 'password'),
      expect:
          () => [
            isA<AuthLoading>(),
            isA<AuthInitial>(), // AuthInitial é emitido durante o processo
            isA<AuthSuccess>(),
          ],
      verify: (_) {
        verify(() => mockRepository.login(any())).called(1);
      },
    );

    test('checkAuthStatus emite AuthSuccess quando autenticado', () async {
      // Setup
      when(
        () => mockRepository.isAuthenticated(),
      ).thenAnswer((_) async => true);
      when(
        () => mockRepository.getToken(),
      ).thenAnswer((_) async => 'token_test');

      // Create fresh cubit for this test
      final cubit = AuthCubit(repository: mockRepository);

      // Reset mock para ignorar chamadas do construtor
      clearInteractions(mockRepository);

      // Configure mocks again since we cleared interactions
      when(
        () => mockRepository.isAuthenticated(),
      ).thenAnswer((_) async => true);
      when(
        () => mockRepository.getToken(),
      ).thenAnswer((_) async => 'token_test');

      // Before calling the method, set a listener to capture state changes
      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      // Act
      await cubit.checkAuthStatus();

      // Wait for async operations
      await Future.delayed(Duration.zero);

      // Assert
      expect(cubit.state, isA<AuthSuccess>());

      // Clean up
      subscription.cancel();
    });

    test('logout chama o método logout do repositório', () async {
      // Setup
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      final cubit = AuthCubit(repository: mockRepository);
      clearInteractions(mockRepository);

      // Configure mock again after clearing interactions
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      // Act
      await cubit.logout();

      // Assert
      verify(() => mockRepository.logout()).called(1);
    });

    test(
      'refreshSession chama o método correspondente quando estado é AuthSuccess',
      () async {
        // Setup
        when(
          () => mockRepository.refreshSession(),
        ).thenAnswer((_) async => true);

        final cubit = AuthCubit(repository: mockRepository);
        cubit.emit(AuthSuccess('token_test'));

        clearInteractions(mockRepository);
        when(
          () => mockRepository.refreshSession(),
        ).thenAnswer((_) async => true);

        // Act
        await cubit.refreshSession();

        // Assert
        verify(() => mockRepository.refreshSession()).called(1);
      },
    );

    test(
      'refreshSession não faz nada quando estado não é AuthSuccess',
      () async {
        // Setup
        when(
          () => mockRepository.refreshSession(),
        ).thenAnswer((_) async => true);

        final cubit = AuthCubit(repository: mockRepository);
        // Não vamos alterar o estado, ficando em AuthInitial

        clearInteractions(mockRepository);
        when(
          () => mockRepository.refreshSession(),
        ).thenAnswer((_) async => true);

        // Act
        await cubit.refreshSession();

        // Assert
        verifyNever(() => mockRepository.refreshSession());
      },
    );
  });
}
