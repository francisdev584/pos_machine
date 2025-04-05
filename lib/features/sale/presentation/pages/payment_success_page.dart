import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/utils/format_utils.dart';
import 'package:pos_machine/core/widgets/confetti_animation.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';

class PaymentSuccessPage extends StatefulWidget {
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
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Iniciar animação quando a tela for carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 60.w,
                          ),
                        ),
                      ),
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
                        'Venda registrada com ID: ${widget.sale.id}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Resumo do pagamento
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Valor Total',
                              FormatUtils.formatCurrencyWithSymbol(
                                widget.totalAmount,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildSummaryRow(
                              'Valor Pago',
                              FormatUtils.formatCurrencyWithSymbol(
                                widget.amountPaid,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Divider(color: Colors.grey.shade300),
                            SizedBox(height: 12.h),
                            _buildSummaryRow(
                              'Troco',
                              FormatUtils.formatCurrencyWithSymbol(
                                widget.change,
                              ),
                              valueStyle: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botão para nova venda
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed:
                            () => Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.seller,
                              (route) => false,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Iniciar Nova Venda',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.home,
                            (route) => false,
                          ),
                      child: Text(
                        'Voltar para a Tela Inicial',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
