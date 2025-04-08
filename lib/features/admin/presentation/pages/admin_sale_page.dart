import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/core/utils/ui_error_helper.dart';
import 'package:pos_machine/features/admin/service/cubit/admin_sale_cubit.dart';

class AdminSalePage extends StatefulWidget {
  const AdminSalePage({super.key});

  @override
  State<AdminSalePage> createState() => _AdminSalePageState();
}

class _AdminSalePageState extends State<AdminSalePage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminSaleCubit>().loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Vendas Realizadas'),
      ),
      body: BlocConsumer<AdminSaleCubit, AdminSaleState>(
        listener: (context, state) {
          if (state is AdminSaleError) {
            UIErrorHelper.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AdminSaleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminSaleError) {
            final isNetworkError =
                state.message.contains('conexão') ||
                state.message.contains('internet') ||
                state.message.contains('servidor');

            if (isNetworkError) {
              return NetworkErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<AdminSaleCubit>().loadSales();
                },
              );
            } else {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<AdminSaleCubit>().loadSales();
                },
              );
            }
          }

          if (state is AdminSaleLoaded) {
            if (state.sales.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma venda realizada',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<AdminSaleCubit>().loadSales(),
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.sales.length,
                itemBuilder: (context, index) {
                  final sale = state.sales[index];
                  final total = sale.products.fold<double>(
                    0,
                    (sum, product) => sum + product.price,
                  );

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Cancelar Venda'),
                                  content: const Text(
                                    'Tem certeza que deseja cancelar esta venda?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Não'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<AdminSaleCubit>()
                                            .cancelSale(sale.id!);
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Sim'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Venda #${sale.id}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red[300],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Vendedor ID: ${sale.userId}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'R\$ ${total.toStringAsFixed(2)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
