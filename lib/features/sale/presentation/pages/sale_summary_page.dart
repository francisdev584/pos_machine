import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/sale/presentation/widgets/sale_summary_item.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';

class SaleSummaryPage extends StatelessWidget {
  const SaleSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumo da Venda')),
      body: BlocBuilder<SaleCubit, SaleState>(
        builder: (context, state) {
          if (state is SaleLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return SaleSummaryItem(
                        product: product,
                        onRemove: () {
                          context.read<SaleCubit>().removeProduct(product);
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 26,
                          red: 0,
                          green: 0,
                          blue: 0,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${state.total.toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implementar pagamento em dinheiro
                              },
                              icon: const Icon(Icons.money),
                              label: const Text('Dinheiro'),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implementar pagamento com PIX
                              },
                              icon: const Icon(Icons.qr_code),
                              label: const Text('PIX'),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implementar pagamento com cartão de crédito
                              },
                              icon: const Icon(Icons.credit_card),
                              label: const Text('Crédito'),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implementar pagamento com cartão de débito
                              },
                              icon: const Icon(Icons.credit_card),
                              label: const Text('Débito'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
