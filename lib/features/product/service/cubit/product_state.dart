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

  const ProductLoaded({required this.products, required this.categories});

  @override
  List<Object?> get props => [products, categories];
}
