import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_machine/core/services/cache_service_impl.dart';
import 'package:pos_machine/features/seller/data/repositories/seller_repository_impl.dart';
import 'package:pos_machine/features/seller/domain/entities/seller.dart';

class MockDio extends Mock implements Dio {}

class MockCacheService extends Mock implements CacheServiceImpl {}

class MockResponse<T> extends Mock implements Response<T> {
  @override
  final T data;
  @override
  final int statusCode;

  MockResponse(this.data, {this.statusCode = 200});
}

void main() {
  late SellerRepositoryImpl repository;
  late MockDio mockDio;
  late MockCacheService mockCacheService;

  setUp(() {
    mockDio = MockDio();
    mockCacheService = MockCacheService();
    repository = SellerRepositoryImpl(mockDio, mockCacheService);
  });

  group('SellerRepositoryImpl', () {
    final testSeller = {
      'id': 1,
      'name': {'firstname': 'João', 'lastname': 'Silva'},
      'email': 'joao.silva@example.com',
      'phone': '(11) 98765-4321',
      'address': {'street': 'Rua das Flores, 123'},
    };

    final testSellers = [
      testSeller,
      {
        'id': 2,
        'name': {'firstname': 'Maria', 'lastname': 'Santos'},
        'email': 'maria.santos@example.com',
        'phone': '(11) 91234-5678',
        'address': {'street': 'Avenida Paulista, 1000'},
      },
    ];

    final seller = Seller(
      id: 1,
      name: 'João Silva',
      email: 'joao.silva@example.com',
      phone: '(11) 98765-4321',
      address: 'Rua das Flores, 123',
    );

    test('getSellers retorna lista de vendedores com sucesso', () async {
      // Arrange
      when(
        () => mockDio.get('/users'),
      ).thenAnswer((_) async => MockResponse(testSellers));

      // Act
      final result = await repository.getSellers();

      // Assert
      expect(result, isA<List<Seller>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].name, 'João Silva');
      expect(result[1].id, 2);
      expect(result[1].name, 'Maria Santos');
      verify(() => mockDio.get('/users')).called(1);
    });

    test('getSellers lança exceção quando API retorna erro', () async {
      // Arrange
      when(() => mockDio.get('/users')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users'),
          error: 'Erro de conexão',
        ),
      );

      // Act & Assert
      expect(
        () => repository.getSellers(),
        throwsA(
          predicate(
            (e) => e.toString().contains(
              'Erro ao carregar vendedores: Erro de conexão',
            ),
          ),
        ),
      );
      verify(() => mockDio.get('/users')).called(1);
    });

    test('saveSelectedSeller salva vendedor no cache', () async {
      // Arrange
      when(
        () => mockCacheService.save('selected_seller', any(), expiration: null),
      ).thenAnswer((_) async {});

      // Act
      await repository.saveSelectedSeller(seller);

      // Assert
      verify(
        () => mockCacheService.save('selected_seller', any(), expiration: null),
      ).called(1);
    });

    test(
      'getSelectedSeller retorna vendedor do cache quando disponível',
      () async {
        // Arrange
        when(
          () => mockCacheService.get('selected_seller'),
        ).thenAnswer((_) async => seller.toJson());

        // Act
        final result = await repository.getSelectedSeller();

        // Assert
        expect(result, isA<Seller>());
        expect(result!.id, 1);
        expect(result.name, 'João Silva');
        verify(() => mockCacheService.get('selected_seller')).called(1);
      },
    );

    test(
      'getSelectedSeller retorna null quando cache não está disponível',
      () async {
        // Arrange
        when(
          () => mockCacheService.get('selected_seller'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getSelectedSeller();

        // Assert
        expect(result, isNull);
        verify(() => mockCacheService.get('selected_seller')).called(1);
      },
    );

    test('clearSelectedSeller limpa o cache do vendedor selecionado', () async {
      // Arrange
      when(
        () => mockCacheService.remove('selected_seller'),
      ).thenAnswer((_) async {});

      // Act
      await repository.clearSelectedSeller();

      // Assert
      verify(() => mockCacheService.remove('selected_seller')).called(1);
    });
  });
}
