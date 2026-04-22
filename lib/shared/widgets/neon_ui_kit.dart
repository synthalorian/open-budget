import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final bool hasGlow;
  final double blur;
  final double opacity;
  final EdgeInsets padding;
  final Color? borderColor;

  NeonCard({
    required this.child,
    this.glowColor,
    this.hasGlow = true,
    this.blur = 12.0,
    this.opacity = 0.6,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? AppColors.primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? effectiveGlowColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: hasGlow ? [
          BoxShadow(
            color: effectiveGlowColor.withValues(alpha: 0.12),
            blurRadius: blur,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeonPulseOrb extends StatefulWidget {
  final double percentUsed;
  final Color baseColor;

  NeonPulseOrb({
    required this.percentUsed,
    required this.baseColor,
    super.key,
  });

  @override
  State<NeonPulseOrb> createState() => _NeonPulseOrbState();
}

class _NeonPulseOrbState extends State<NeonPulseOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Pulse faster if nearing budget limit
    final duration = widget.percentUsed > 0.9 ? 800 : 1500;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orbColor = widget.percentUsed > 1.0 
        ? AppColors.expense 
        : widget.percentUsed > 0.8 
            ? AppColors.warning 
            : widget.baseColor;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orbColor.withValues(alpha: 0.6),
                  orbColor.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: orbColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.percentUsed * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: orbColor,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                  Text(
                    'USED',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: orbColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
