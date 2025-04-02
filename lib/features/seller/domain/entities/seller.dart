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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }

  factory Seller.fromMap(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
    );
  }

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] as int,
      name: '${json['name']['firstname']} ${json['name']['lastname']}',
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address']['street'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, address];
}
