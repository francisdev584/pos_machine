import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/product/domain/entities/product.dart';

class ShoppingCartWidget extends StatelessWidget {
  final List<Product> selectedProducts;
  final Map<Product, int> quantities;
  final Function(Product, int) onQuantityChanged;
  final Function(Product) onRemoveProduct;
  final VoidCallback onCheckout;
  final double total;

  const ShoppingCartWidget({
    super.key,
    required this.selectedProducts,
    required this.quantities,
    required this.onQuantityChanged,
    required this.onRemoveProduct,
    required this.onCheckout,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Carrinho de Compras',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${selectedProducts.length} itens',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              itemCount: selectedProducts.length,
              itemBuilder: (context, index) {
                final product = selectedProducts[index];
                final quantity = quantities[product] ?? 1;
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      product.image,
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    product.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (quantity > 1) {
                            onQuantityChanged(product, quantity - 1);
                          }
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          onQuantityChanged(product, quantity + 1);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onRemoveProduct(product),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: const Text('Finalizar Compra'),
            ),
          ),
        ],
      ),
    );
  }
}
