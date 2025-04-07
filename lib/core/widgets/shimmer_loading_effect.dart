import 'package:flutter/material.dart';

class ShimmerLoadingEffect extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const ShimmerLoadingEffect({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  @override
  State<ShimmerLoadingEffect> createState() => _ShimmerLoadingEffectState();
}

class _ShimmerLoadingEffectState extends State<ShimmerLoadingEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.isCircle
                    ? null
                    : BorderRadius.circular(widget.borderRadius),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFFFFFFF),
                Color(0xFFEEEEEE),
              ],
              stops: [
                _animation.value < 0 ? 0 : _animation.value / 4 + 0.25,
                (_animation.value + 2) / 4,
                _animation.value < 0 ? 1 - _animation.value / 4 - 0.25 : 1,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget para criar linhas de shimmer para listas ou grupos de itens
class ShimmerListLoading extends StatelessWidget {
  final int itemCount;
  final double height;
  final double spacing;
  final double borderRadius;

  const ShimmerListLoading({
    super.key,
    this.itemCount = 5,
    this.height = 80,
    this.spacing = 12,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder:
          (_, __) =>
              ShimmerLoadingEffect(height: height, borderRadius: borderRadius),
    );
  }
}
