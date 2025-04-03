// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:pos_machine/features/product/domain/entities/product.dart';

class Sale extends Equatable {
  final int? id;
  final int userId;
  final List<Product> products;
  const Sale({this.id, required this.userId, required this.products});

  @override
  List<Object?> get props => [id, userId, products];

  Sale copyWith({int? id, int? userId, List<Product>? products}) {
    return Sale(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      products: products ?? this.products,
    );
  }
}
