import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/utils/format_utils.dart';
import 'package:pos_machine/features/sale/domain/entities/sale.dart';
import 'package:pos_machine/features/sale/presentation/widgets/animated_change_display.dart';
import 'package:pos_machine/features/sale/presentation/widgets/quick_amount_buttons.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';
import 'package:pos_machine/features/seller/service/cubit/seller_cubit.dart';

class CashPaymentPage extends StatefulWidget {
  final double total;
  final Sale sale;

  const CashPaymentPage({super.key, required this.total, required this.sale});

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  double _change = 0.0;
  double _amountPaid = 0.0;
  bool _isProcessing = false;
  late AnimationController _processAnimController;

  @override
  void initState() {
    super.initState();
    _processAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _processAnimController.dispose();
    super.dispose();
  }

  void _updateAmount(String value) {
    try {
      final amount = double.parse(value);
      setState(() {
        _amountPaid = amount;
        _change = amount - widget.total;
      });
    } catch (e) {
      // Ignorar erros de formatação
    }
  }

  void _setAmountPaid(double amount) {
    setState(() {
      _amountPaid = amount;
      _change = amount - widget.total;
      _amountController.text = FormatUtils.formatCurrency(amount);
    });
  }

  void _startProcessingAnimation() {
    setState(() {
      _isProcessing = true;
    });
    _processAnimController.repeat();
  }

  void _finalizeSale() {
    _startProcessingAnimation();
    Future.delayed(const Duration(milliseconds: 800), () {
      context.read<SaleCubit>().finalizeSale();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleCubit, SaleState>(
      listener: (context, state) {
        if (state is SaleSuccess) {
          _processAnimController.stop();
          context.read<SellerCubit>().clearSelectedSeller();

          // Navegar para a tela de sucesso
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.paymentSuccess,
            (route) => false,
            arguments: {
              'totalAmount': widget.total,
              'amountPaid': _amountPaid,
              'change': _change,
              'sale': widget.sale,
            },
          );
        } else if (state is SaleError) {
          _processAnimController.stop();
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Pagamento em Dinheiro'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total da venda
              Column(
                children: [
                  Text(
                    'Valor Total',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    FormatUtils.formatCurrencyWithSymbol(widget.total),
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Valor Recebido
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor Recebido',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 12.w,
                        ),
                        hintText: '0,00',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20.sp,
                        ),
                        prefixText: 'R\$ ',
                        prefixStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Converter entrada com vírgula para processamento com ponto
                        final processValue = value.replaceAll(',', '.');
                        _updateAmount(processValue);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              AnimatedChangeDisplay(change: _change),
              // Botões de valores rápidos
              QuickAmountButtons(
                totalAmount: widget.total,
                onAmountSelected: _setAmountPaid,
              ),

              const Spacer(),

              // Botão finalizar pagamento
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed:
                        _isProcessing || _change < 0 ? null : _finalizeSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child:
                        _isProcessing
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Processando...',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              'Finalizar Pagamento',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
