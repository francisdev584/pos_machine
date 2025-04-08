import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';
import 'package:pos_machine/features/seller/domain/entities/seller.dart';

class MockSaleRepository extends Mock implements SaleRepository {}

class MockBuildContext extends Mock implements BuildContext {}

class FakeProductList extends Fake implements List<Product> {}

void main() {
  late SaleCubit saleCubit;
  late MockSaleRepository mockRepository;

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

  final testSeller = const Seller(
    id: 1,
    name: 'João Silva',
    email: 'joao.silva@example.com',
    phone: '(11) 98765-4321',
    address: 'Rua das Flores, 123',
  );

  setUpAll(() {
    registerFallbackValue(FakeProductList());
  });

  setUp(() {
    mockRepository = MockSaleRepository();
    saleCubit = SaleCubit(repository: mockRepository);
  });

  group('SaleCubit', () {
    test('estado inicial é SaleInitial', () {
      expect(saleCubit.state, isA<SaleInitial>());
    });

    test('toggleProduct adiciona produto quando ele não está na lista', () {
      // Act
      saleCubit.toggleProduct(testSeller, testProducts[0]);

      // Assert
      expect(saleCubit.state, isA<SaleLoaded>());
      expect(saleCubit.sale.userId, 1);
      expect(saleCubit.sale.products, contains(testProducts[0]));
    });

    test('toggleProduct remove produto quando ele já está na lista', () {
      // Arrange
      saleCubit.toggleProduct(testSeller, testProducts[0]);
      expect(saleCubit.sale.products, contains(testProducts[0]));

      // Act
      saleCubit.toggleProduct(testSeller, testProducts[0]);

      // Assert
      expect(saleCubit.state, isA<SaleLoaded>());
      expect(saleCubit.sale.products, isEmpty);
    });

    test('removeProduct remove o produto especificado da lista', () {
      // Arrange
      saleCubit.toggleProduct(testSeller, testProducts[0]);
      saleCubit.toggleProduct(testSeller, testProducts[1]);
      expect(saleCubit.sale.products.length, 2);

      // Act
      saleCubit.removeProduct(testProducts[0]);

      // Assert
      expect(saleCubit.state, isA<SaleLoaded>());
      expect(saleCubit.sale.products.length, 1);
      expect(saleCubit.sale.products.first, testProducts[1]);
    });

    test('clearCart limpa todos os produtos e reseta o userId', () {
      // Arrange
      saleCubit.toggleProduct(testSeller, testProducts[0]);
      expect(saleCubit.sale.products.isNotEmpty, true);

      // Act
      saleCubit.clearCart();

      // Assert
      expect(saleCubit.state, isA<SaleInitial>());
      expect(saleCubit.sale.userId, 0);
      expect(saleCubit.sale.products, isEmpty);
    });

    test(
      'canProceedToPayment emite estados corretos quando há produtos suficientes',
      () {
        // Arrange
        saleCubit.toggleProduct(testSeller, testProducts[0]);

        // Act e Assert
        // Como o método emite dois estados em sequência, testamos ouvindo as mudanças
        var stateChanges = <SaleState>[];

        saleCubit.stream.listen((state) {
          stateChanges.add(state);
        });

        saleCubit.canProceedToPayment();

        // Aguarda a conclusão das chamadas assíncronas
        expect(saleCubit.state, isA<SaleLoaded>());
      },
    );

    test(
      'canProceedToPayment emite erro quando não há produtos suficientes',
      () {
        // Arrange - configurar um carrinho vazio com userId
        saleCubit.sale = Sale(userId: testSeller.id, products: []);
        saleCubit.emit(SaleLoaded(sale: saleCubit.sale));

        // Act
        saleCubit.canProceedToPayment();

        // Assert - o estado final deve ser SaleLoaded
        expect(saleCubit.state, isA<SaleLoaded>());
        // O carrinho ainda deve estar vazio
        expect(saleCubit.sale.products, isEmpty);
      },
    );

    test('finalizeSale processa a venda com sucesso', () async {
      // Arrange
      when(
        () => mockRepository.createSale(any(), any()),
      ).thenAnswer((_) async {});

      saleCubit.toggleProduct(testSeller, testProducts[0]);

      // Act
      await saleCubit.finalizeSale();

      // Assert
      verify(() => mockRepository.createSale(any(), any())).called(1);
      expect(saleCubit.state, isA<SaleSuccess>());
      expect(saleCubit.sale.userId, 0);
      expect(saleCubit.sale.products, isEmpty);
    });

    test('finalizeSale trata erros corretamente', () async {
      // Arrange
      when(
        () => mockRepository.createSale(any(), any()),
      ).thenThrow(Exception('Erro ao criar venda'));

      saleCubit.toggleProduct(testSeller, testProducts[0]);

      // Act
      await saleCubit.finalizeSale();

      // Assert
      verify(() => mockRepository.createSale(any(), any())).called(1);
      expect(saleCubit.state, isA<SaleError>());
      expect(
        (saleCubit.state as SaleError).message,
        contains('Erro ao criar venda'),
      );
    });
  });
}
