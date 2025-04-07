import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/product/presentation/widgets/product_list_item.dart';
import 'package:pos_machine/features/product/presentation/widgets/product_loading_shimmer.dart';
import 'package:pos_machine/features/product/service/cubit/product_cubit.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';
import 'package:pos_machine/features/seller/domain/entities/seller.dart';

class ProductPage extends StatelessWidget {
  final Seller seller;
  const ProductPage({super.key, required this.seller});

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
        title: const Text('Produtos'),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const ProductLoadingShimmer();
          } else if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductCubit>().loadProducts();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          } else if (state is ProductLoaded) {
            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (query) {
                          context.read<ProductCubit>().searchProducts(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar produto por nome ou ID',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Contador de produtos
                      BlocBuilder<SaleCubit, SaleState>(
                        builder: (context, saleState) {
                          if (saleState is SaleLoaded) {
                            final itemCount = saleState.sale.products.length;
                            final maxProducts = SaleCubit.maxProducts;
                            final isNearLimit = itemCount >= maxProducts * 0.7;
                            final isAtLimit = itemCount >= maxProducts;

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isAtLimit
                                        ? Colors.red.shade50
                                        : isNearLimit
                                        ? Colors.amber.shade50
                                        : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color:
                                      isAtLimit
                                          ? Colors.red.shade300
                                          : isNearLimit
                                          ? Colors.amber.shade300
                                          : Colors.green.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isAtLimit
                                        ? Icons.error_outline
                                        : isNearLimit
                                        ? Icons.warning_amber_outlined
                                        : Icons.check_circle_outline,
                                    color:
                                        isAtLimit
                                            ? Colors.red
                                            : isNearLimit
                                            ? Colors.amber.shade700
                                            : Colors.green,
                                    size: 20.w,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Produtos selecionados: $itemCount/$maxProducts',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isAtLimit
                                                ? Colors.red
                                                : isNearLimit
                                                ? Colors.amber.shade700
                                                : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return BlocBuilder<SaleCubit, SaleState>(
                        builder: (context, saleState) {
                          final isSelected =
                              saleState is SaleLoaded &&
                              saleState.sale.products.contains(product);

                          // Verificar se atingiu o limite de produtos
                          final isAtMaxLimit =
                              saleState is SaleLoaded &&
                              saleState.sale.products.length >=
                                  SaleCubit.maxProducts;

                          return ProductListItem(
                            key: ValueKey(product.id),
                            product: product,
                            isSelected: isSelected,
                            isDisabled: !isSelected && isAtMaxLimit,
                            onTap: () {
                              context.read<SaleCubit>().toggleProduct(
                                seller,
                                product,
                                context: context,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<SaleCubit, SaleState>(
        builder: (context, state) {
          if (state is SaleLoaded && state.sale.products.isNotEmpty) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de itens: ${state.sale.products.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'R\$ ${state.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.sale,
                          arguments: state.sale,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text(
                        'Ver Carrinho',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
