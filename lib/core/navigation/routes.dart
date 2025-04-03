import 'package:flutter/material.dart';

import 'package:pos_machine/features/home/presentation/pages/home_page.dart';
import 'package:pos_machine/features/product/presentation/pages/product_page.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/presentation/pages/cash_payment_page.dart';
import 'package:pos_machine/features/sale/presentation/pages/sale_summary_page.dart';
import 'package:pos_machine/features/seller/domain/entities/seller.dart';
import 'package:pos_machine/features/seller/presentation/pages/seller_page.dart';

class Routes {
  static const String home = '/';
  static const String seller = '/seller';
  static const String product = '/product';
  static const String sale = '/sale';
  static const String cashPayment = '/cashPayment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomePage());
      case seller:
        return settings.arguments != null
            ? MaterialPageRoute(
              builder:
                  (context) => SellerPage(refresh: settings.arguments as bool),
            )
            : MaterialPageRoute(builder: (context) => SellerPage());
      case product:
        return MaterialPageRoute(
          builder:
              (context) => ProductPage(seller: settings.arguments as Seller),
        );
      case sale:
        return MaterialPageRoute(
          builder:
              (context) => SaleSummaryPage(sale: settings.arguments as Sale),
        );
      case cashPayment:
        return MaterialPageRoute(
          builder:
              (context) => CashPaymentPage(
                total:
                    (settings.arguments as Map<String, dynamic>)['total']
                        as double,
                sale:
                    (settings.arguments as Map<String, dynamic>)['sale']
                        as Sale,
              ),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('Rota não encontrada: ${settings.name}'),
                ),
              ),
        );
    }
  }
}
