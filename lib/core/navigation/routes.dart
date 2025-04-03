import 'package:flutter/material.dart';

import 'package:pos_machine/features/auth/presentation/pages/admin_home_page.dart';
import 'package:pos_machine/features/auth/presentation/pages/admin_login_page.dart';
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
  static const String adminLogin = '/admin-login';
  static const String adminHome = '/admin-Home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomePage());
      case seller:
        return MaterialPageRoute(builder: (context) => SellerPage());
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
      case adminLogin:
        return MaterialPageRoute(builder: (context) => const AdminLoginPage());
      case adminHome:
        return MaterialPageRoute(builder: (context) => const AdminHomePage());

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
