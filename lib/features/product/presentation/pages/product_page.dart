import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/product/presentation/widgets/product_list_item.dart';
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
            return const Center(child: CircularProgressIndicator());
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
                  child: TextField(
                    onChanged: (query) {
                      context.read<ProductCubit>().searchProducts(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar produto por nome ou ID',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
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
                          return ProductListItem(
                            key: ValueKey(product.id),
                            product: product,
                            isSelected: isSelected,
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
                    color: Colors.black.withValues(
                      alpha: 26,
                      red: 0,
                      green: 0,
                      blue: 0,
                    ),
                    blurRadius: 0,
                    offset: const Offset(0, -0.5),
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
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            Routes.sale,
                            arguments: state.sale,
                          ),
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
