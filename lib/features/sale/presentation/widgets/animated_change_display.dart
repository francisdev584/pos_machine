import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/core/utils/format_utils.dart';

class AnimatedChangeDisplay extends StatefulWidget {
  final double change;

  const AnimatedChangeDisplay({super.key, required this.change});

  @override
  State<AnimatedChangeDisplay> createState() => _AnimatedChangeDisplayState();
}

class _AnimatedChangeDisplayState extends State<AnimatedChangeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _valueAnimation;

  double _previousChange = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _valueAnimation = Tween<double>(
      begin: 0.0,
      end: widget.change,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedChangeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.change != widget.change) {
      _previousChange = oldWidget.change;
      _valueAnimation = Tween<double>(
        begin: _previousChange,
        end: widget.change,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.change >= 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Troco',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      'R\$ ${FormatUtils.formatCurrency(_valueAnimation.value)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            isPositive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              if (!isPositive)
                Text(
                  'Valor insuficiente',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
