part of 'product_cubit.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<String> categories;
  final List<Product> selectedProducts;
  final Map<Product, int> quantities;

  const ProductLoaded({
    required this.products,
    required this.categories,
    required this.selectedProducts,
    this.quantities = const {},
  });

  double get total {
    return selectedProducts.fold(
      0,
      (sum, product) => sum + (product.price * (quantities[product] ?? 1)),
    );
  }

  @override
  List<Object?> get props => [
    products,
    categories,
    selectedProducts,
    quantities,
  ];
}
