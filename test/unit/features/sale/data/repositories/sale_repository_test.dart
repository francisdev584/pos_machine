import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';

class MockDio extends Mock implements Dio {}

class MockResponse<T> extends Mock implements Response<T> {
  @override
  final T data;
  @override
  final int statusCode;

  MockResponse(this.data, {this.statusCode = 200});
}

void main() {
  late SaleRepositoryImpl repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = SaleRepositoryImpl(mockDio);
  });

  group('SaleRepositoryImpl', () {
    final testProducts = [
      const Product(
        id: 1,
        title: 'Produto 1',
        description: 'Descrição do produto 1',
        price: 10.0,
        image: 'imagem1.jpg',
        category: 'categoria1',
        rating: 4.5,
        ratingCount: 10,
      ),
      const Product(
        id: 2,
        title: 'Produto 2',
        description: 'Descrição do produto 2',
        price: 20.0,
        image: 'imagem2.jpg',
        category: 'categoria2',
        rating: 4.0,
        ratingCount: 15,
      ),
    ];

    final testSales = [
      {
        'id': 1,
        'userId': 1,
        'products': [
          {
            'productId': 1,
            'title': 'Produto 1',
            'price': 10.0,
            'description': 'Descrição do produto 1',
            'category': 'categoria1',
            'image': 'imagem1.jpg',
          },
          {
            'productId': 2,
            'title': 'Produto 2',
            'price': 20.0,
            'description': 'Descrição do produto 2',
            'category': 'categoria2',
            'image': 'imagem2.jpg',
          },
        ],
      },
      {
        'id': 2,
        'userId': 2,
        'products': [
          {
            'productId': 1,
            'title': 'Produto 1',
            'price': 10.0,
            'description': 'Descrição do produto 1',
            'category': 'categoria1',
            'image': 'imagem1.jpg',
          },
        ],
      },
    ];

    test('createSale envia dados para API com sucesso', () async {
      // Arrange
      when(
        () => mockDio.post('/carts', data: any(named: 'data')),
      ).thenAnswer((_) async => MockResponse({'id': 1}, statusCode: 200));

      // Act
      await repository.createSale(1, testProducts);

      // Assert
      verify(() => mockDio.post('/carts', data: any(named: 'data'))).called(1);
    });

    test('createSale lança exceção quando API retorna erro', () async {
      // Arrange
      when(() => mockDio.post('/carts', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/carts'),
          error: 'Erro de conexão',
        ),
      );

      // Act & Assert
      expect(
        () => repository.createSale(1, testProducts),
        throwsA(
          predicate(
            (e) =>
                e.toString().contains('Erro ao criar venda: Erro de conexão'),
          ),
        ),
      );
      verify(() => mockDio.post('/carts', data: any(named: 'data'))).called(1);
    });

    test(
      'createSale lança exceção quando API retorna status diferente de 200',
      () async {
        // Arrange
        when(() => mockDio.post('/carts', data: any(named: 'data'))).thenAnswer(
          (_) async => MockResponse({'error': 'Erro interno'}, statusCode: 500),
        );

        // Act & Assert
        expect(
          () => repository.createSale(1, testProducts),
          throwsA(
            predicate(
              (e) => e.toString().contains('Falha ao criar venda: código 500'),
            ),
          ),
        );
        verify(
          () => mockDio.post('/carts', data: any(named: 'data')),
        ).called(1);
      },
    );

    test('cancelSale envia requisição para API com sucesso', () async {
      // Arrange
      when(() => mockDio.delete('/carts/1')).thenAnswer(
        (_) async => MockResponse({'status': 'success'}, statusCode: 200),
      );

      // Act
      await repository.cancelSale(1);

      // Assert
      verify(() => mockDio.delete('/carts/1')).called(1);
    });

    test('cancelSale lança exceção quando API retorna erro', () async {
      // Arrange
      when(() => mockDio.delete('/carts/1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/carts/1'),
          error: 'Erro de conexão',
        ),
      );

      // Act & Assert
      expect(
        () => repository.cancelSale(1),
        throwsA(
          predicate(
            (e) => e.toString().contains(
              'Erro ao cancelar venda: Erro de conexão',
            ),
          ),
        ),
      );
      verify(() => mockDio.delete('/carts/1')).called(1);
    });

    test(
      'cancelSale lança exceção quando API retorna status diferente de 200',
      () async {
        // Arrange
        when(() => mockDio.delete('/carts/1')).thenAnswer(
          (_) async => MockResponse({'error': 'Erro interno'}, statusCode: 500),
        );

        // Act & Assert
        expect(
          () => repository.cancelSale(1),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains('Falha ao cancelar venda: código 500'),
            ),
          ),
        );
        verify(() => mockDio.delete('/carts/1')).called(1);
      },
    );

    test('getSales retorna lista de vendas com sucesso', () async {
      // Arrange
      when(
        () => mockDio.get('/carts'),
      ).thenAnswer((_) async => MockResponse(testSales));

      // Act
      final result = await repository.getSales();

      // Assert
      expect(result, isA<List<Sale>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].userId, 1);
      expect(result[0].products.length, 2);
      expect(result[1].id, 2);
      expect(result[1].userId, 2);
      expect(result[1].products.length, 1);
      verify(() => mockDio.get('/carts')).called(1);
    });

    test('getSales lança exceção quando API retorna erro', () async {
      // Arrange
      when(() => mockDio.get('/carts')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/carts'),
          error: 'Erro de conexão',
        ),
      );

      // Act & Assert
      expect(
        () => repository.getSales(),
        throwsA(
          predicate(
            (e) => e.toString().contains(
              'Erro ao carregar vendas: Erro de conexão',
            ),
          ),
        ),
      );
      verify(() => mockDio.get('/carts')).called(1);
    });

    test(
      'getSales lança exceção quando API retorna status diferente de 200',
      () async {
        // Arrange
        when(() => mockDio.get('/carts')).thenAnswer(
          (_) async => MockResponse({'error': 'Erro interno'}, statusCode: 500),
        );

        // Act & Assert
        expect(
          () => repository.getSales(),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains('Falha ao carregar vendas: código 500'),
            ),
          ),
        );
        verify(() => mockDio.get('/carts')).called(1);
      },
    );
  });
}
