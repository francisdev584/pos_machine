import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_machine/features/seller/domain/entities/seller.dart';
import 'package:pos_machine/features/seller/domain/repositories/seller_repository.dart';
import 'package:pos_machine/features/seller/service/cubit/seller_cubit.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

class FakeSeller extends Fake implements Seller {}

void main() {
  late SellerCubit sellerCubit;
  late MockSellerRepository mockRepository;

  final testSellers = [
    const Seller(
      id: 1,
      name: 'João Silva',
      email: 'joao.silva@example.com',
      phone: '(11) 98765-4321',
      address: 'Rua das Flores, 123',
    ),
    const Seller(
      id: 2,
      name: 'Maria Santos',
      email: 'maria.santos@example.com',
      phone: '(11) 91234-5678',
      address: 'Avenida Paulista, 1000',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeSeller());
  });

  setUp(() {
    mockRepository = MockSellerRepository();
    // O método loadInitialData é chamado no construtor do SellerCubit
    when(
      () => mockRepository.getSellers(),
    ).thenAnswer((_) async => testSellers);
    when(
      () => mockRepository.getSelectedSeller(),
    ).thenAnswer((_) async => null);
  });

  group('SellerCubit', () {
    test(
      'deve iniciar com SellerInitial e chamar loadInitialData no construtor',
      () async {
        sellerCubit = SellerCubit(repository: mockRepository);

        // Verifica se os métodos do repositório foram chamados
        verify(() => mockRepository.getSellers()).called(1);

        // Aguarda a conclusão das chamadas assíncronas
        await Future.delayed(Duration.zero);

        // Verifica se o estado final é SellerLoaded
        expect(sellerCubit.state, isA<SellerLoaded>());
        expect((sellerCubit.state as SellerLoaded).sellers, testSellers);
      },
    );

    test(
      'loadSellers deve emitir estados corretos quando bem-sucedido',
      () async {
        // Configura o mock
        when(
          () => mockRepository.getSellers(),
        ).thenAnswer((_) async => testSellers);
        when(
          () => mockRepository.getSelectedSeller(),
        ).thenAnswer((_) async => testSellers[0]);

        // Cria o cubit
        sellerCubit = SellerCubit(repository: mockRepository);

        // Limpa os estados iniciais
        await Future.delayed(Duration.zero);

        // Verifica o estado atual
        expect(sellerCubit.state, isA<SellerLoaded>());

        // Act - chama loadSellers
        sellerCubit.loadSellers();

        // Aguarda a conclusão
        await Future.delayed(Duration.zero);

        // Assert - verifica se loadSellers mudou o estado corretamente
        expect(sellerCubit.state, isA<SellerLoaded>());
        expect((sellerCubit.state as SellerLoaded).sellers, testSellers);
        expect(
          (sellerCubit.state as SellerLoaded).selectedSeller,
          testSellers[0],
        );

        // Verifica se os métodos foram chamados
        verify(
          () => mockRepository.getSellers(),
        ).called(2); // uma no construtor, outra no loadSellers
        verify(() => mockRepository.getSelectedSeller()).called(1);
      },
    );

    test('loadSellers deve emitir SellerError quando falha', () async {
      // Configura o cubit
      sellerCubit = SellerCubit(repository: mockRepository);

      // Limpa os estados iniciais
      await Future.delayed(Duration.zero);

      // Reconfigura o mock para falhar
      when(
        () => mockRepository.getSellers(),
      ).thenAnswer((_) async => testSellers);
      when(
        () => mockRepository.getSelectedSeller(),
      ).thenThrow(Exception('Erro ao carregar vendedor selecionado'));

      // Act - chama loadSellers
      sellerCubit.loadSellers();

      // Aguarda a conclusão
      await Future.delayed(Duration.zero);

      // Assert - verifica se o estado final é SellerError
      expect(sellerCubit.state, isA<SellerError>());
      expect(
        (sellerCubit.state as SellerError).message,
        contains('Erro ao carregar vendedor selecionado'),
      );
    });

    test(
      'selectSeller deve atualizar o estado com o vendedor selecionado',
      () async {
        // Configura o mock
        when(
          () => mockRepository.saveSelectedSeller(any()),
        ).thenAnswer((_) async {});

        // Cria o cubit com estado inicial
        sellerCubit = SellerCubit(repository: mockRepository);

        // Espera o estado inicial
        await Future.delayed(Duration.zero);

        // Define um estado inicial conhecido
        sellerCubit.emit(SellerLoaded(sellers: testSellers));

        // Act - seleciona um vendedor
        await sellerCubit.selectSeller(testSellers[0]);

        // Assert - verifica se o estado foi atualizado
        expect(sellerCubit.state, isA<SellerLoaded>());
        expect(
          (sellerCubit.state as SellerLoaded).selectedSeller,
          testSellers[0],
        );

        // Verifica se o método foi chamado
        verify(
          () => mockRepository.saveSelectedSeller(testSellers[0]),
        ).called(1);
      },
    );

    test('clearSelectedSeller deve limpar o vendedor selecionado', () async {
      // Configura o mock
      when(() => mockRepository.clearSelectedSeller()).thenAnswer((_) async {});

      // Cria o cubit
      sellerCubit = SellerCubit(repository: mockRepository);

      // Espera o estado inicial
      await Future.delayed(Duration.zero);

      // Define um estado inicial com vendedor selecionado
      sellerCubit.emit(
        SellerLoaded(sellers: testSellers, selectedSeller: testSellers[0]),
      );

      // Act - limpa o vendedor selecionado
      await sellerCubit.clearSelectedSeller();

      // Assert - verifica se o estado foi atualizado
      expect(sellerCubit.state, isA<SellerLoaded>());
      expect((sellerCubit.state as SellerLoaded).selectedSeller, isNull);

      // Verifica se o método foi chamado
      verify(() => mockRepository.clearSelectedSeller()).called(1);
    });
  });
}
