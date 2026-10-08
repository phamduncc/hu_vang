import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class GoldJarWidget extends StatefulWidget {
  final double currentQuantity; // Số chỉ
  final double targetQuantity; // Số chỉ
  final String goalName;
  final VoidCallback? onTap;

  const GoldJarWidget({
    super.key,
    required this.currentQuantity,
    required this.targetQuantity,
    this.goalName = 'Hũ Vàng Tích Lũy',
    this.onTap,
  });

  @override
  State<GoldJarWidget> createState() => _GoldJarWidgetState();
}

class _GoldJarWidgetState extends State<GoldJarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GoldJarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentQuantity != widget.currentQuantity ||
        oldWidget.targetQuantity != widget.targetQuantity) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.targetQuantity > 0 ? widget.targetQuantity : 20.0;
    final progress = (widget.currentQuantity / target).clamp(0.0, 1.0);
    final remaining = max(0.0, target - widget.currentQuantity);
    final percent = (progress * 100).toStringAsFixed(1);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF201E17), Color(0xFF14151C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.goldPrimary.withAlpha(90),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldPrimary.withAlpha(30),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.savings_rounded,
                    color: AppTheme.goldBright,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.goalName.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mục tiêu: ${GoldFormatters.formatChi(target)} (${GoldFormatters.formatLuong(target)})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldPrimary.withAlpha(128)),
                  ),
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                      color: AppTheme.goldBright,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Visual Hũ Vàng & Progress
            Row(
              children: [
                // Animated Custom Gold Jar
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 90,
                      height: 100,
                      child: CustomPaint(
                        painter: GoldJarPainter(
                          fillFraction: progress * _animation.value,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),

                // Detailed metrics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            GoldFormatters.formatChi(widget.currentQuantity),
                            style: const TextStyle(
                              color: AppTheme.goldBright,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '/ ${GoldFormatters.formatChi(target)}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Custom Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, _) {
                            return LinearProgressIndicator(
                              value: progress * _animation.value,
                              minHeight: 10,
                              backgroundColor: const Color(0xFF2A2D3D),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.goldBright,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status info
                      Row(
                        children: [
                          Icon(
                            remaining <= 0
                                ? Icons.check_circle_rounded
                                : Icons.flag_rounded,
                            size: 15,
                            color: remaining <= 0
                                ? AppTheme.profitGreen
                                : AppTheme.goldPrimary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              remaining <= 0
                                  ? '🎉 Đã đạt mục tiêu hũ vàng!'
                                  : 'Còn thiếu ${GoldFormatters.formatChi(remaining)} (${GoldFormatters.formatLuong(remaining)})',
                              style: TextStyle(
                                color: remaining <= 0
                                    ? AppTheme.profitGreen
                                    : const Color(0xFFD1D5DB),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GoldJarPainter extends CustomPainter {
  final double fillFraction; // 0.0 -> 1.0

  GoldJarPainter({required this.fillFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Jar body path
    final jarPath = Path();
    final neckTop = h * 0.18;
    final neckWidth = w * 0.58;
    final shoulderTop = h * 0.30;
    final bottomY = h * 0.95;
    final bottomWidth = w * 0.70;

    jarPath.moveTo((w - neckWidth) / 2, neckTop);
    jarPath.lineTo((w + neckWidth) / 2, neckTop);

    // Right shoulder to belly to base
    jarPath.cubicTo(
      w * 0.82, shoulderTop * 0.8,
      w * 0.94, h * 0.55,
      (w + bottomWidth) / 2, bottomY,
    );

    // Jar base
    jarPath.quadraticBezierTo(
      w / 2, bottomY + 4,
      (w - bottomWidth) / 2, bottomY,
    );

    // Left base to belly to shoulder
    jarPath.cubicTo(
      w * 0.06, h * 0.55,
      w * 0.18, shoulderTop * 0.8,
      (w - neckWidth) / 2, neckTop,
    );
    jarPath.close();

    // 1. Draw Jar Dark Glass Background
    final glassBgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x333A3F55), Color(0x66181B26)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(jarPath, glassBgPaint);

    // 2. Draw Gold Content Fill inside jar (clipped to jarPath)
    if (fillFraction > 0.01) {
      canvas.save();
      canvas.clipPath(jarPath);

      final fillHeight = (bottomY - neckTop) * fillFraction;
      final fillTop = bottomY - fillHeight;

      final goldShader = const LinearGradient(
        colors: [
          Color(0xFFFFF099),
          Color(0xFFFFD700),
          Color(0xFFE5A800),
          Color(0xFFB87800),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, fillTop, w, fillHeight + 10));

      final goldPaint = Paint()..shader = goldShader;

      final wavePath = Path();
      wavePath.moveTo(0, fillTop);
      wavePath.quadraticBezierTo(w * 0.25, fillTop - 3, w * 0.5, fillTop);
      wavePath.quadraticBezierTo(w * 0.75, fillTop + 3, w, fillTop);
      wavePath.lineTo(w, h);
      wavePath.lineTo(0, h);
      wavePath.close();

      canvas.drawPath(wavePath, goldPaint);

      // Gold shimmer sparkles inside
      final coinPaint = Paint()..color = const Color(0xFFFFECC0);
      final random = Random(42);
      for (int i = 0; i < (fillFraction * 12).toInt(); i++) {
        final cx = w * 0.25 + (random.nextDouble() * w * 0.5);
        final cy = fillTop + 8 + (random.nextDouble() * (fillHeight - 12).clamp(0.0, 100.0));
        canvas.drawCircle(Offset(cx, cy), 2.2, coinPaint);
      }

      canvas.restore();
    }

    // 3. Draw Jar Glass Outline & Highlights
    final glassOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = const LinearGradient(
        colors: [
          Color(0xAAF3E5AB),
          Color(0x55D4AF37),
          Color(0x33FFFFFF),
          Color(0x88D4AF37),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(jarPath, glassOutline);

    // 4. Draw Jar Rim & Golden Ribbon
    final rimRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2, neckTop - 2),
        width: neckWidth + 12,
        height: 9,
      ),
      const Radius.circular(5),
    );
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDF70), Color(0xFFD4AF37), Color(0xFFAA7E0A)],
      ).createShader(rimRect.outerRect);
    canvas.drawRRect(rimRect, rimPaint);

    // Red festive tie ribbon
    final ribbonPaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawCircle(Offset(w / 2, neckTop + 5), 4, ribbonPaint);
  }

  @override
  bool shouldRepaint(covariant GoldJarPainter oldDelegate) {
    return oldDelegate.fillFraction != fillFraction;
  }
}
