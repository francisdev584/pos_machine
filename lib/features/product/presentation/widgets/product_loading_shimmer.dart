import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/widgets/shimmer_loading_effect.dart';

class ProductLoadingShimmer extends StatelessWidget {
  const ProductLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer para o campo de busca
          Container(
            margin: EdgeInsets.only(top: 16.h, bottom: 12.h),
            child: ShimmerLoadingEffect(
              height: 50.h,
              width: double.infinity,
              borderRadius: 12.r,
            ),
          ),

          // Shimmer para o contador de produtos
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            child: ShimmerLoadingEffect(
              height: 40.h,
              width: double.infinity,
              borderRadius: 8.r,
            ),
          ),

          // Lista de produtos com shimmer
          Expanded(
            child: ShimmerListLoading(
              itemCount: 10,
              height: 90.h,
              borderRadius: 12.r,
              spacing: 12.h,
            ),
          ),
        ],
      ),
    );
  }
}
