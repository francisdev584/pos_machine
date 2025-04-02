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

  const ProductLoaded({
    required this.products,
    this.selectedProducts = const [],
  });

  double get total {
    return selectedProducts.fold(0, (sum, product) => sum + product.price);
  }

  @override
  List<Object?> get props => [products, selectedProducts];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
