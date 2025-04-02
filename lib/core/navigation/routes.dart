import 'package:flutter/material.dart';

import 'package:pos_machine/features/home/presentation/pages/home_page.dart';
import 'package:pos_machine/features/product/presentation/pages/product_page.dart';
import 'package:pos_machine/features/sale/presentation/pages/sale_summary_page.dart';
import 'package:pos_machine/features/seller/presentation/pages/seller_page.dart';

class Routes {
  static const String home = '/home';
  static const String seller = '/seller';
  static const String product = '/product';
  static const String sale = '/sale';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomePage());
      case seller:
        return MaterialPageRoute(builder: (context) => SellerPage());
      case product:
        return MaterialPageRoute(builder: (context) => ProductPage());
      case sale:
        return MaterialPageRoute(builder: (context) => SaleSummaryPage());
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
