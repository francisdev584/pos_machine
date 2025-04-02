import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/di/injection_container.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/seller/presentation/cubit/seller_cubit.dart';
import 'package:pos_machine/features/seller/presentation/widgets/seller_list_item.dart';

class SellerPage extends StatelessWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SellerCubit>()..loadSellers(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Selecionar Vendedor')),
        body: BlocBuilder<SellerCubit, SellerState>(
          builder: (context, state) {
            if (state is SellerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SellerError) {
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
                        context.read<SellerCubit>().loadSellers();
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            } else if (state is SellerLoaded) {
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.sellers.length,
                itemBuilder: (context, index) {
                  final seller = state.sellers[index];
                  return SellerListItem(
                    seller: seller,
                    isSelected: state.selectedSeller?.id == seller.id,
                    onTap: () {
                      context.read<SellerCubit>().selectSeller(seller);
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: BlocBuilder<SellerCubit, SellerState>(
          builder: (context, state) {
            if (state is SellerLoaded && state.selectedSeller != null) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navegar para a página de produtos
                    },
                    child: const Text('Continuar'),
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
