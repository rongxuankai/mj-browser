import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 星球黑洞动画组件
/// 模仿 Web 端的星球效果，包括黑洞和轨道上的新月形光点
class PlanetAnimation extends StatefulWidget {
  final double size;

  const PlanetAnimation({
    super.key,
    this.size = 160,
  });

  @override
  State<PlanetAnimation> createState() => _PlanetAnimationState();
}

class _PlanetAnimationState extends State<PlanetAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外层光晕
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0),
                ],
                stops: const [0.05, 0.2, 0.7],
              ),
            ),
          ),
          // 黑洞核心（三层环）
          _buildBlackHoleCore(),
          // 轨道和新月形光点
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _OrbitPainter(
                  progress: _controller.value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlackHoleCore() {
    final coreSize = widget.size * 0.4;

    return Container(
      // 第三层环（最外层）
      width: coreSize * 1.4,
      height: coreSize * 1.4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        // 第二层环
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          // 第一层环
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            // 黑洞中心
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              boxShadow: [
                const BoxShadow(
                  color: Colors.black,
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: -5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 绘制轨道和新月形光点
class _OrbitPainter extends CustomPainter {
  final double progress;

  _OrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbitRadius = size.width * 0.35;

    // 绘制 6 个新月形光点，每个延迟不同时间
    for (int i = 0; i < 6; i++) {
      final delay = i / 6.0;
      final adjustedProgress = (progress + delay) % 1.0;
      _drawCrescent(canvas, center, orbitRadius, adjustedProgress);
    }
  }

  void _drawCrescent(
      Canvas canvas, Offset center, double radius, double progress) {
    // 计算透明度：在 18%-75% 之间可见
    double opacity = 0.0;
    if (progress >= 0.18 && progress <= 0.75) {
      if (progress <= 0.25) {
        // 淡入
        opacity = (progress - 0.18) / (0.25 - 0.18);
      } else {
        // 完全可见到淡出
        opacity = 1.0;
      }
    }

    if (opacity <= 0) return;

    // 计算位置：从 25% 到 90% 的轨道位置
    const startDistance = 0.25;
    const endDistance = 0.90;
    final actualDistance =
        startDistance + (endDistance - startDistance) * progress;

    // 轨道角度（从 18% 到 100%）
    final angle = actualDistance * 2 * math.pi;

    // 3D 透视效果：rotateX(75deg)
    // 计算椭圆轨道位置
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle) * 0.25; // 压缩 Y 轴模拟 3D 效果

    // 绘制新月形（简化为椭圆形光点）
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.33)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // 根据位置调整大小（远近透视）
    final scale = 0.7 + 0.3 * math.sin(angle).abs();
    final crescentWidth = 12.0 * scale;
    final crescentHeight = 8.0 * scale;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: crescentWidth,
        height: crescentHeight,
      ),
      paint,
    );

    // 添加额外的发光效果
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: crescentWidth * 2,
        height: crescentHeight * 2,
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
