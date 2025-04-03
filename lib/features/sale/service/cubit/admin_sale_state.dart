part of 'admin_sale_cubit.dart';

abstract class AdminSaleState extends Equatable {
  const AdminSaleState();

  @override
  List<Object?> get props => [];
}

class AdminSaleInitial extends AdminSaleState {}

class AdminSaleLoading extends AdminSaleState {}

class AdminSaleLoaded extends AdminSaleState {
  final List<Sale> sales;

  const AdminSaleLoaded({required this.sales});

  @override
  List<Object?> get props => [sales];
}

class AdminSaleError extends AdminSaleState {
  final String message;

  const AdminSaleError(this.message);

  @override
  List<Object?> get props => [message];
}
