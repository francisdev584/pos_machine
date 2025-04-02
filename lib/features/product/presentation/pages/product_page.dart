import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/di/injection_container.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/product/presentation/cubit/product_cubit.dart';
import 'package:pos_machine/features/product/presentation/widgets/product_list_item.dart';
import 'package:pos_machine/features/product/presentation/widgets/product_search_bar.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductCubit>()..loadProducts(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Produtos')),
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
                  ProductSearchBar(
                    onSearch: (query) {
                      context.read<ProductCubit>().searchProducts(query);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ProductListItem(
                          product: product,
                          isSelected: state.selectedProducts.contains(product),
                          onTap: () {
                            context.read<ProductCubit>().toggleProduct(product);
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

        bottomNavigationBar: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            if (state is ProductLoaded && state.selectedProducts.isNotEmpty) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total: R\$ ${state.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navegar para a página de resumo da venda
                        },
                        child: const Text('Continuar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
