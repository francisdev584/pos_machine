import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessIcon extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;

  const SuccessIcon({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
  });

  @override
  State<SuccessIcon> createState() => _SuccessIconState();
}

class _SuccessIconState extends State<SuccessIcon>
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

    // Iniciar animação quando o widget for carregado
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size.w,
        height: widget.size.w,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.green.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          color: widget.iconColor ?? Colors.green.shade600,
          size: widget.iconSize ?? 60.w,
        ),
      ),
    );
  }
}
