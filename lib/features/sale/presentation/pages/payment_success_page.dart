import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/widgets/confetti_animation.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/presentation/widgets/navigation_buttons.dart';
import 'package:pos_machine/features/sale/presentation/widgets/payment_summary_card.dart';
import 'package:pos_machine/features/sale/presentation/widgets/success_icon.dart';

class PaymentSuccessPage extends StatelessWidget {
  final double totalAmount;
  final double amountPaid;
  final double change;
  final Sale sale;

  const PaymentSuccessPage({
    super.key,
    required this.totalAmount,
    required this.amountPaid,
    required this.change,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Pagamento Concluído'),
      ),
      body: Stack(
        children: [
          // Animação de confete
          Positioned.fill(child: ConfettiAnimation(isPlaying: true)),

          Column(
            children: [
              // Ícone e mensagem de sucesso
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SuccessIcon(),
                      SizedBox(height: 24.h),
                      Text(
                        'Pagamento Realizado com Sucesso!',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Venda registrada com ID: ${sale.id ?? '--'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Resumo do pagamento
                      PaymentSummaryCard(
                        totalAmount: totalAmount,
                        amountPaid: amountPaid,
                        change: change,
                      ),
                    ],
                  ),
                ),
              ),

              // Botões de navegação
              NavigationButtons(),
            ],
          ),
        ],
      ),
    );
  }
}
