import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:pos_machine/features/product/data/repositories/product_repository_impl.dart';
import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/core/services/cache_service.dart';

class MockDio extends Mock implements Dio {}

class MockCacheService extends Mock implements CacheService {}

class MockResponse<T> extends Mock implements Response<T> {
  @override
  final T data;
  MockResponse(this.data);
}

void main() {
  late ProductRepositoryImpl repository;
  late MockDio mockDio;
  late MockCacheService mockCacheService;

  setUp(() {
    mockDio = MockDio();
    mockCacheService = MockCacheService();
    repository = ProductRepositoryImpl(mockDio, mockCacheService);
  });

  group('ProductRepositoryImpl', () {
    final testProduct = {
      'id': 1,
      'title': 'Produto de Teste',
      'description': 'Descrição do produto de teste',
      'price': 19.99,
      'image': 'https://example.com/image.jpg',
      'category': 'categoria_teste',
      'rating': {'rate': 4.5, 'count': 10},
    };

    final List<Map<String, dynamic>> testProducts = [
      testProduct,
      {
        'id': 2,
        'title': 'Produto de Teste 2',
        'description': 'Descrição do produto de teste 2',
        'price': 29.99,
        'image': 'https://example.com/image2.jpg',
        'category': 'categoria_teste2',
        'rating': {'rate': 4.2, 'count': 15},
      },
    ];

    test('getProductById retorna produto do cache quando disponível', () async {
      // Arrange
      when(
        () => mockCacheService.get('product_1'),
      ).thenAnswer((_) async => testProduct);

      // Act
      final result = await repository.getProductById(1);

      // Assert
      expect(result, isA<Product>());
      expect(result.id, 1);
      expect(result.title, 'Produto de Teste');
      verify(() => mockCacheService.get('product_1')).called(1);
      verifyNever(() => mockDio.get(any()));
    });

    test(
      'getProductById busca produto da API quando cache não está disponível',
      () async {
        // Arrange
        when(
          () => mockCacheService.get('product_1'),
        ).thenAnswer((_) async => null);

        when(
          () => mockDio.get('/products/1'),
        ).thenAnswer((_) async => MockResponse(testProduct));

        when(
          () => mockCacheService.save(
            'product_1',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getProductById(1);

        // Assert
        expect(result, isA<Product>());
        expect(result.id, 1);
        expect(result.title, 'Produto de Teste');
        verify(() => mockCacheService.get('product_1')).called(1);
        verify(() => mockDio.get('/products/1')).called(1);
        verify(
          () => mockCacheService.save(
            'product_1',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).called(1);
      },
    );

    test('getProducts retorna produtos do cache quando disponível', () async {
      // Arrange
      final cachedData = {'products': testProducts};
      when(
        () => mockCacheService.get('products'),
      ).thenAnswer((_) async => cachedData);

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result, isA<List<Product>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
      verify(() => mockCacheService.get('products')).called(1);
      verifyNever(() => mockDio.get(any()));
    });

    test(
      'getProducts busca produtos da API quando cache não está disponível',
      () async {
        // Arrange
        when(
          () => mockCacheService.get('products'),
        ).thenAnswer((_) async => null);

        when(
          () => mockDio.get('/products'),
        ).thenAnswer((_) async => MockResponse(testProducts));

        when(
          () => mockCacheService.save(
            'products',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result, isA<List<Product>>());
        expect(result.length, 2);
        verify(() => mockCacheService.get('products')).called(1);
        verify(() => mockDio.get('/products')).called(1);
        verify(
          () => mockCacheService.save(
            'products',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).called(1);
      },
    );

    test(
      'getProductsByCategory retorna produtos do cache quando disponível',
      () async {
        // Arrange
        final cachedData = {
          'products': [testProduct],
        };
        when(
          () => mockCacheService.get('products_category_categoria_teste'),
        ).thenAnswer((_) async => cachedData);

        // Act
        final result = await repository.getProductsByCategory(
          'categoria_teste',
        );

        // Assert
        expect(result, isA<List<Product>>());
        expect(result.length, 1);
        expect(result[0].id, 1);
        expect(result[0].category, 'categoria_teste');
        verify(
          () => mockCacheService.get('products_category_categoria_teste'),
        ).called(1);
        verifyNever(() => mockDio.get(any()));
      },
    );

    test(
      'getProductsByCategory busca produtos quando cache não está disponível',
      () async {
        // Arrange
        when(
          () => mockCacheService.get('products_category_categoria_teste'),
        ).thenAnswer((_) async => null);

        // Primeiro chamará getProducts para obter todos os produtos
        when(
          () => mockCacheService.get('products'),
        ).thenAnswer((_) async => null);

        when(
          () => mockDio.get('/products'),
        ).thenAnswer((_) async => MockResponse(testProducts));

        when(
          () => mockCacheService.save(
            'products',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockCacheService.save(
            'products_category_categoria_teste',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getProductsByCategory(
          'categoria_teste',
        );

        // Assert
        expect(result, isA<List<Product>>());
        expect(result.length, 1);
        expect(result[0].category, 'categoria_teste');
        verify(
          () => mockCacheService.get('products_category_categoria_teste'),
        ).called(1);
        verify(() => mockCacheService.get('products')).called(1);
        verify(() => mockDio.get('/products')).called(1);
        verify(
          () => mockCacheService.save(
            'products_category_categoria_teste',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).called(1);
      },
    );

    test('getProductsByCategory com forceRefresh ignora cache', () async {
      // Arrange
      // Primeiro chamará getProducts com forceRefresh
      when(
        () => mockCacheService.get('products'),
      ).thenAnswer((_) async => null);

      when(
        () => mockDio.get('/products'),
      ).thenAnswer((_) async => MockResponse(testProducts));

      when(
        () => mockCacheService.save(
          'products',
          any(),
          expiration: any(named: 'expiration'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => mockCacheService.save(
          'products_category_categoria_teste',
          any(),
          expiration: any(named: 'expiration'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.getProductsByCategory(
        'categoria_teste',
        forceRefresh: true,
      );

      // Assert
      expect(result, isA<List<Product>>());
      expect(result.length, 1);
      expect(result[0].category, 'categoria_teste');
      verifyNever(
        () => mockCacheService.get('products_category_categoria_teste'),
      );
      verify(() => mockDio.get('/products')).called(1);
    });

    test(
      'getCategories retorna categorias do cache quando disponível',
      () async {
        // Arrange
        final cachedData = {
          'categories': ['categoria_teste', 'categoria_teste2'],
        };
        when(
          () => mockCacheService.get('categories'),
        ).thenAnswer((_) async => cachedData);

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, 2);
        expect(result.contains('categoria_teste'), isTrue);
        expect(result.contains('categoria_teste2'), isTrue);
        verify(() => mockCacheService.get('categories')).called(1);
        verifyNever(() => mockDio.get(any()));
      },
    );

    test(
      'getCategories busca categorias quando cache não está disponível',
      () async {
        // Arrange
        when(
          () => mockCacheService.get('categories'),
        ).thenAnswer((_) async => null);

        // Primeiro chamará getProducts para obter todos os produtos
        when(
          () => mockCacheService.get('products'),
        ).thenAnswer((_) async => null);

        when(
          () => mockDio.get('/products'),
        ).thenAnswer((_) async => MockResponse(testProducts));

        when(
          () => mockCacheService.save(
            'products',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockCacheService.save(
            'categories',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, 2);
        expect(result.contains('categoria_teste'), isTrue);
        expect(result.contains('categoria_teste2'), isTrue);
        verify(() => mockCacheService.get('categories')).called(1);
        verify(() => mockCacheService.get('products')).called(1);
        verify(() => mockDio.get('/products')).called(1);
        verify(
          () => mockCacheService.save(
            'categories',
            any(),
            expiration: any(named: 'expiration'),
          ),
        ).called(1);
      },
    );

    test('getCategories com forceRefresh ignora cache', () async {
      // Arrange
      // Primeiro chamará getProducts com forceRefresh
      when(
        () => mockCacheService.get('products'),
      ).thenAnswer((_) async => null);

      when(
        () => mockDio.get('/products'),
      ).thenAnswer((_) async => MockResponse(testProducts));

      when(
        () => mockCacheService.save(
          'products',
          any(),
          expiration: any(named: 'expiration'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => mockCacheService.save(
          'categories',
          any(),
          expiration: any(named: 'expiration'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.getCategories(forceRefresh: true);

      // Assert
      expect(result, isA<List<String>>());
      expect(result.length, 2);
      verifyNever(() => mockCacheService.get('categories'));
      verify(() => mockDio.get('/products')).called(1);
    });

    test('saveSelectedProducts salva produtos no cache', () async {
      // Arrange
      final products = testProducts.map((p) => Product.fromJson(p)).toList();
      when(
        () =>
            mockCacheService.save('selected_products', any(), expiration: null),
      ).thenAnswer((_) async {});

      // Act
      await repository.saveSelectedProducts(products);

      // Assert
      verify(
        () =>
            mockCacheService.save('selected_products', any(), expiration: null),
      ).called(1);
    });

    test(
      'getSelectedProducts retorna produtos selecionados do cache',
      () async {
        // Arrange
        final cachedData = {'products': testProducts};
        when(
          () => mockCacheService.get('selected_products'),
        ).thenAnswer((_) async => cachedData);

        // Act
        final result = await repository.getSelectedProducts();

        // Assert
        expect(result, isA<List<Product>>());
        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[1].id, 2);
        verify(() => mockCacheService.get('selected_products')).called(1);
      },
    );

    test(
      'getSelectedProducts retorna lista vazia quando não há cache',
      () async {
        // Arrange
        when(
          () => mockCacheService.get('selected_products'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getSelectedProducts();

        // Assert
        expect(result, isA<List<Product>>());
        expect(result.isEmpty, isTrue);
        verify(() => mockCacheService.get('selected_products')).called(1);
      },
    );

    test(
      'clearSelectedProducts limpa o cache de produtos selecionados',
      () async {
        // Arrange
        when(
          () => mockCacheService.remove('selected_products'),
        ).thenAnswer((_) async {});

        // Act
        await repository.clearSelectedProducts();

        // Assert
        verify(() => mockCacheService.remove('selected_products')).called(1);
      },
    );
  });
}
