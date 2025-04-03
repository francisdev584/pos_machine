import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';
import 'package:pos_machine/features/seller/service/cubit/seller_cubit.dart';

class CashPaymentPage extends StatefulWidget {
  final double total;

  const CashPaymentPage({super.key, required this.total, required Sale sale});

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage> {
  final _amountController = TextEditingController();
  double _change = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateChange(String value) {
    final amountPaid = double.tryParse(value) ?? 0;
    setState(() {
      _change = amountPaid - widget.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleCubit, SaleState>(
      listener: (context, state) {
        if (state is SaleSuccess) {
          context.read<SellerCubit>().clearSelectedSeller();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Venda finalizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.seller, (route) => route.isFirst);
        } else if (state is SaleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Pagamento em Dinheiro'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total da Venda',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor Recebido',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                onChanged: _calculateChange,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Troco', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${_change.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _change < 0 ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    _change < 0
                        ? null
                        : () {
                          final amountPaid = double.parse(
                            _amountController.text,
                          );
                          context.read<SaleCubit>().finalizeSale();
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Finalizar Pagamento',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
