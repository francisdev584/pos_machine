import 'dart:math';

import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  final bool isPlaying;

  const ConfettiAnimation({super.key, required this.isPlaying});

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _particles = List.generate(
      50,
      (_) => ConfettiParticle(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * -300,
        ),
        color: Color.fromRGBO(
          _random.nextInt(255),
          _random.nextInt(255),
          _random.nextInt(255),
          _random.nextDouble() * 0.8 + 0.2,
        ),
        size: _random.nextDouble() * 10 + 5,
        speed: _random.nextDouble() * 200 + 100,
        rotationSpeed: _random.nextDouble() * 2 * pi,
      ),
    );

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startAnimation();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.reset();
    }
  }

  void _startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class ConfettiParticle {
  Offset position;
  Color color;
  double size;
  double speed;
  double rotationSpeed;
  double rotation = 0;

  ConfettiParticle({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
    required this.rotationSpeed,
  });

  void update(double progress) {
    position = Offset(position.dx, position.dy + speed * progress);
    rotation = rotationSpeed * progress;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      particle.update(progress);
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      paint.color = particle.color;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
