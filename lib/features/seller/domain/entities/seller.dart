import 'package:equatable/equatable.dart';

class Seller extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;

  const Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address']['street'],
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, address];
}
