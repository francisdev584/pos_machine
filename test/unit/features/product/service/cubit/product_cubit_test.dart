import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/product/domain/repositories/product_repository.dart';
import 'package:pos_machine/features/product/service/cubit/product_cubit.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ProductCubit productCubit;
  late MockProductRepository mockRepository;

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

  final testCategories = ['categoria1', 'categoria2'];

  setUp(() {
    mockRepository = MockProductRepository();
    when(
      () =>
          mockRepository.getProducts(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => testProducts);
    when(
      () => mockRepository.getCategories(
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => testCategories);

    // Configuração para getProductsByCategory
    when(
      () => mockRepository.getProductsByCategory(
        'categoria1',
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => [testProducts[0]]);
  });

  group('ProductCubit', () {
    test('deve carregar produtos e categorias na inicialização', () async {
      // Crie uma nova instância
      productCubit = ProductCubit(repository: mockRepository);

      // Aguarde a conclusão das chamadas assíncronas
      await Future.delayed(const Duration(milliseconds: 100));

      // Verifique se o estado é ProductLoaded
      expect(productCubit.state, isA<ProductLoaded>());

      // Verifique se os produtos e categorias foram carregados
      final state = productCubit.state as ProductLoaded;
      expect(state.products, equals(testProducts));
      expect(state.categories, equals(testCategories));

      // Verifique se os métodos foram chamados
      verify(
        () => mockRepository.getProducts(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).called(1);
      verify(
        () => mockRepository.getCategories(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).called(1);
    });

    blocTest<ProductCubit, ProductState>(
      'loadProducts deve atualizar estado com novos produtos',
      build: () {
        productCubit = ProductCubit(repository: mockRepository);
        return productCubit;
      },
      act: (cubit) async {
        // Aguarde a inicialização e em seguida carregue os produtos
        await Future.delayed(const Duration(milliseconds: 100));

        // Configure o mock para retornar produtos diferentes
        final newProducts = [
          ...testProducts,
          const Product(
            id: 3,
            title: 'Produto 3',
            description: 'Descrição do produto 3',
            price: 30.0,
            image: 'imagem3.jpg',
            category: 'categoria3',
            rating: 4.8,
            ratingCount: 20,
          ),
        ];

        when(
          () => mockRepository.getProducts(forceRefresh: true),
        ).thenAnswer((_) async => newProducts);

        // Recarregue os produtos
        await cubit.loadProducts(forceRefresh: true);
      },
      expect:
          () => [
            isA<ProductLoaded>(),
            isA<ProductLoading>(),
            isA<ProductLoaded>(),
          ],
      verify: (cubit) {
        verify(() => mockRepository.getProducts(forceRefresh: true)).called(1);
      },
    );

    blocTest<ProductCubit, ProductState>(
      'loadProductsByCategory deve filtrar produtos por categoria',
      build: () {
        productCubit = ProductCubit(repository: mockRepository);
        return productCubit;
      },
      act: (cubit) async {
        // Aguarde a inicialização e em seguida filtre por categoria
        await Future.delayed(const Duration(milliseconds: 100));
        await cubit.loadProductsByCategory('categoria1');
      },
      expect:
          () => [
            isA<ProductLoaded>(),
            isA<ProductLoading>(),
            isA<ProductLoaded>(),
          ],
      verify: (cubit) {
        verify(
          () => mockRepository.getProductsByCategory(
            'categoria1',
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).called(1);
      },
    );

    blocTest<ProductCubit, ProductState>(
      'searchProducts deve filtrar produtos por termo de busca',
      build: () {
        productCubit = ProductCubit(repository: mockRepository);
        return productCubit;
      },
      act: (cubit) async {
        // Aguarde a inicialização e em seguida faça a busca
        await Future.delayed(const Duration(milliseconds: 100));
        cubit.searchProducts('Produto 1');
      },
      expect: () => [isA<ProductLoaded>(), isA<ProductLoaded>()],
      verify: (cubit) {
        // Verifique o estado final
        final state = cubit.state as ProductLoaded;
        expect(state.products.length, equals(1));
        expect(state.products.first.title, equals('Produto 1'));
      },
    );

    blocTest<ProductCubit, ProductState>(
      'deve emitir ProductError quando ocorrer um erro',
      build: () {
        productCubit = ProductCubit(repository: mockRepository);
        return productCubit;
      },
      act: (cubit) async {
        // Aguarde a inicialização
        await Future.delayed(const Duration(milliseconds: 100));

        // Configure o mock para lançar uma exceção
        when(
          () => mockRepository.getProducts(forceRefresh: true),
        ).thenThrow(Exception('Erro ao carregar produtos'));

        // Tente recarregar os produtos
        await cubit.loadProducts(forceRefresh: true);
      },
      expect:
          () => [
            isA<ProductLoaded>(),
            isA<ProductLoading>(),
            isA<ProductError>(),
          ],
      verify: (cubit) {
        verify(() => mockRepository.getProducts(forceRefresh: true)).called(1);
      },
    );
  });
}
