part of 'product_cubit.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> selectedProducts;
  final List<String> categories;

  const ProductLoaded({
    required this.products,
    this.selectedProducts = const [],
    required this.categories,
  });

  double get total {
    return selectedProducts.fold(0, (sum, product) => sum + product.price);
  }

  @override
  List<Object?> get props => [products, selectedProducts, categories];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
