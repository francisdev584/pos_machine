import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/product/domain/entities/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const ProductListItem({
    super.key,
    required this.product,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: isDisabled ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(12.w),
            child: Stack(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(
                          isDisabled
                              ? [
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]
                              : [
                                1,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ],
                        ),
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          width: 80.w,
                          height: 80.w,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                width: 80.w,
                                height: 80.w,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 80.w,
                                height: 80.w,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDisabled ? Colors.grey[500] : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  isDisabled
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'R\$ ${product.price.toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color:
                                  isDisabled
                                      ? Colors.grey[400]
                                      : AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isDisabled && !isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white.withAlpha(128),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(204),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Limite atingido',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 8,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : isDisabled
                              ? Colors.grey[300]
                              : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.remove : Icons.add,
                      color:
                          isSelected
                              ? Colors.white
                              : isDisabled
                              ? Colors.grey[500]
                              : AppTheme.primaryColor,
                      size: 20.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
