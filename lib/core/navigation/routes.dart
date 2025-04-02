import 'package:flutter/material.dart';

import 'package:pos_machine/features/home/presentation/pages/home_page.dart';
import 'package:pos_machine/features/seller/presentation/pages/seller_page.dart';

class Routes {
  static const String home = '/home';
  static const String seller = '/seller';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomePage());
      case seller:
        return MaterialPageRoute(builder: (context) => SellerPage());
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
