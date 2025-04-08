import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_machine/core/services/interfaces/secure_storage.dart';
import 'package:pos_machine/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';

class MockDio extends Mock implements Dio {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockResponse<T> extends Mock implements Response<T> {
  @override
  final T data;
  @override
  final int statusCode;

  MockResponse(this.data, {this.statusCode = 200});
}

void main() {
  late AuthRepositoryImpl repository;
  late MockDio mockDio;
  late MockSecureStorage mockSecureStorage;
  late SharedPreferences mockSharedPreferences;

  setUp(() async {
    mockDio = MockDio();
    mockSecureStorage = MockSecureStorage();

    // Configurar SharedPreferences.getInstance para nossos testes
    SharedPreferences.setMockInitialValues({});
    mockSharedPreferences = await SharedPreferences.getInstance();

    // Injetar um método para acessar o SharedPreferences diretamente
    repository = MockAuthRepositoryImpl(
      mockSecureStorage,
      mockDio,
      mockSharedPreferences,
    );
  });

  group('AuthRepositoryImpl', () {
    final testCredentials = AuthCredentials(
      username: 'admin',
      password: 'password123',
    );

    final testToken = 'test_auth_token';
    final tokenResponse = {'token': testToken};

    test(
      'login deve retornar token quando a autenticação for bem-sucedida',
      () async {
        // Arrange
        when(
          () => mockDio.post('/auth/login', data: any(named: 'data')),
        ).thenAnswer((_) async => MockResponse(tokenResponse));

        when(
          () => mockSecureStorage.saveToken(
            key: any(named: 'key'),
            value: testToken,
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.login(testCredentials);

        // Assert
        expect(result, equals(testToken));
        verify(
          () => mockDio.post('/auth/login', data: any(named: 'data')),
        ).called(1);
        verify(
          () => mockSecureStorage.saveToken(
            key: any(named: 'key'),
            value: testToken,
          ),
        ).called(1);
      },
    );

    test('login deve lançar exceção quando status não for 200', () async {
      // Arrange
      when(
        () => mockDio.post('/auth/login', data: any(named: 'data')),
      ).thenAnswer((_) async => MockResponse({}, statusCode: 401));

      // Act & Assert
      expect(
        () => repository.login(testCredentials),
        throwsA(
          predicate((e) => e.toString().contains('Falha na autenticação')),
        ),
      );
    });

    test('login deve lançar exceção específica para erro 401', () async {
      // Arrange
      when(
        () => mockDio.post('/auth/login', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => repository.login(testCredentials),
        throwsA(
          predicate((e) => e.toString().contains('Usuário ou senha inválidos')),
        ),
      );
    });

    test('logout deve limpar token e timestamp de expiração', () async {
      // Arrange
      when(
        () => mockSecureStorage.deleteToken(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      // Act
      await repository.logout();

      // Assert
      verify(
        () => mockSecureStorage.deleteToken(key: any(named: 'key')),
      ).called(1);
    });

    test(
      'isAuthenticated deve retornar true quando tem token válido',
      () async {
        // Arrange
        when(
          () => mockSecureStorage.hasToken(key: any(named: 'key')),
        ).thenAnswer((_) async => true);

        // Simular um timestamp de expiração futuro (ainda válido)
        final futureTime =
            DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch;
        await mockSharedPreferences.setInt('admin_token_expiry', futureTime);

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isTrue);
        verify(
          () => mockSecureStorage.hasToken(key: any(named: 'key')),
        ).called(1);
      },
    );

    test('isAuthenticated deve retornar false quando não tem token', () async {
      // Arrange
      when(
        () => mockSecureStorage.hasToken(key: any(named: 'key')),
      ).thenAnswer((_) async => false);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, isFalse);
      verify(
        () => mockSecureStorage.hasToken(key: any(named: 'key')),
      ).called(1);
    });

    test('isAuthenticated deve retornar false quando sessão expirou', () async {
      // Arrange
      when(
        () => mockSecureStorage.hasToken(key: any(named: 'key')),
      ).thenAnswer((_) async => true);

      // Simular um timestamp de expiração passado (já expirado)
      final pastTime =
          DateTime.now().subtract(Duration(minutes: 10)).millisecondsSinceEpoch;
      await mockSharedPreferences.setInt('admin_token_expiry', pastTime);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, isFalse);
      verify(
        () => mockSecureStorage.hasToken(key: any(named: 'key')),
      ).called(1);
    });

    test('getToken deve retornar o token quando sessão é válida', () async {
      // Arrange
      // Simular um timestamp de expiração futuro (ainda válido)
      final futureTime =
          DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch;
      await mockSharedPreferences.setInt('admin_token_expiry', futureTime);

      when(
        () => mockSecureStorage.getToken(key: any(named: 'key')),
      ).thenAnswer((_) async => testToken);

      // Act
      final result = await repository.getToken();

      // Assert
      expect(result, equals(testToken));
      verify(
        () => mockSecureStorage.getToken(key: any(named: 'key')),
      ).called(1);
    });

    test(
      'getToken deve retornar null e fazer logout quando sessão expirou',
      () async {
        // Arrange
        // Simular um timestamp de expiração passado (já expirado)
        final pastTime =
            DateTime.now()
                .subtract(Duration(minutes: 10))
                .millisecondsSinceEpoch;
        await mockSharedPreferences.setInt('admin_token_expiry', pastTime);

        when(
          () => mockSecureStorage.deleteToken(key: any(named: 'key')),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getToken();

        // Assert
        expect(result, isNull);
        verify(
          () => mockSecureStorage.deleteToken(key: any(named: 'key')),
        ).called(1);
      },
    );

    test(
      'refreshSession deve atualizar timestamp e retornar true quando há token',
      () async {
        // Arrange
        when(
          () => mockSecureStorage.hasToken(key: any(named: 'key')),
        ).thenAnswer((_) async => true);

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result, isTrue);
        verify(
          () => mockSecureStorage.hasToken(key: any(named: 'key')),
        ).called(1);

        // Verificar se o timestamp foi atualizado
        final expiryTimestamp = mockSharedPreferences.getInt(
          'admin_token_expiry',
        );
        expect(expiryTimestamp, isNotNull);

        // Timestamp deve ser futuro (maior que o momento atual)
        expect(
          expiryTimestamp! > DateTime.now().millisecondsSinceEpoch,
          isTrue,
        );
      },
    );

    test('refreshSession deve retornar false quando não há token', () async {
      // Arrange
      when(
        () => mockSecureStorage.hasToken(key: any(named: 'key')),
      ).thenAnswer((_) async => false);

      // Act
      final result = await repository.refreshSession();

      // Assert
      expect(result, isFalse);
      verify(
        () => mockSecureStorage.hasToken(key: any(named: 'key')),
      ).called(1);
    });
  });
}

// Classe auxiliar que expõe o SharedPreferences para testes
class MockAuthRepositoryImpl extends AuthRepositoryImpl {
  final SharedPreferences mockSharedPreferences;

  MockAuthRepositoryImpl(
    super.secureStorage,
    super.dio,
    this.mockSharedPreferences,
  );
}
