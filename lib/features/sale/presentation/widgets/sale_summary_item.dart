import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/product/domain/entities/product.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SaleSummaryItem extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  const SaleSummaryItem({
    super.key,
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      width: 60.w,
                      height: 60.w,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      width: 60.w,
                      height: 60.w,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
