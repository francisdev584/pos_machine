import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/presentation/widgets/payment_method_button.dart';
import 'package:pos_machine/features/sale/presentation/widgets/sale_summary_item.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';

class SaleSummaryPage extends StatelessWidget {
  final Sale sale;
  const SaleSummaryPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Resumo da Venda'),
      ),
      body: BlocBuilder<SaleCubit, SaleState>(
        builder: (context, state) {
          if (state is SaleLoaded) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    children: [
                      Text(
                        'Total da Venda',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'R\$ ${state.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.sale.products.length,
                    itemBuilder: (context, index) {
                      final product = state.sale.products[index];
                      return SaleSummaryItem(product: product);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.w),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        'Selecione a forma de pagamento',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: PaymentMethodButton(
                              icon: Icons.attach_money,
                              label: 'Dinheiro',
                              isEnabled: true,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.cashPayment,
                                  arguments: {
                                    "total": state.total,
                                    "sale": sale,
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: PaymentMethodButton(
                              icon: Icons.qr_code,
                              label: 'Pix',
                              isEnabled: false,
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: PaymentMethodButton(
                              icon: Icons.credit_card,
                              label: 'Crédito',
                              isEnabled: false,
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: PaymentMethodButton(
                              icon: Icons.credit_card,
                              label: 'Débito',
                              isEnabled: false,
                              onTap: () {},
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
