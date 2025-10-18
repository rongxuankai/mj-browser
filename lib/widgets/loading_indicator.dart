import 'package:flutter/material.dart';

/// 网页加载动画指示器
/// 模仿 Web 端的 Bar + Ball 动画效果
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // 从4秒减少到2秒，更快更灵动
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
    return Center(
      child: SizedBox(
        width: 75,
        height: 100,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // 5 个柱子
                _buildBar(0, 0, _getBarScale1(_controller.value)),
                _buildBar(1, 15, _getBarScale2(_controller.value)),
                _buildBar(2, 30, _getBarScale3(_controller.value)),
                _buildBar(3, 45, _getBarScale4(_controller.value)),
                _buildBar(4, 60, _getBarScale5(_controller.value)),
                // 蓝色小球
                _buildBall(_controller.value),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBar(int index, double left, double scale) {
    return Positioned(
      left: left,
      bottom: 0,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()..scale(1.0, scale),
        child: Container(
          width: 10,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(1, 1),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBall(double progress) {
    final offset = _getBallPosition(progress);

    return Positioned(
      left: offset.dx,
      bottom: offset.dy,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFF2C8FFF),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  // 小球的位置动画
  Offset _getBallPosition(double t) {
    // 根据百分比计算位置
    if (t <= 0.05) {
      return _lerp(const Offset(0, 10), const Offset(8, 24), t / 0.05);
    } else if (t <= 0.10) {
      return _lerp(
          const Offset(8, 24), const Offset(15, 20), (t - 0.05) / 0.05);
    } else if (t <= 0.17) {
      return _lerp(
          const Offset(15, 20), const Offset(23, 34), (t - 0.10) / 0.07);
    } else if (t <= 0.20) {
      return _lerp(
          const Offset(23, 34), const Offset(30, 30), (t - 0.17) / 0.03);
    } else if (t <= 0.27) {
      return _lerp(
          const Offset(30, 30), const Offset(38, 44), (t - 0.20) / 0.07);
    } else if (t <= 0.30) {
      return _lerp(
          const Offset(38, 44), const Offset(45, 40), (t - 0.27) / 0.03);
    } else if (t <= 0.37) {
      return _lerp(
          const Offset(45, 40), const Offset(53, 54), (t - 0.30) / 0.07);
    } else if (t <= 0.40) {
      return _lerp(
          const Offset(53, 54), const Offset(60, 50), (t - 0.37) / 0.03);
    } else if (t <= 0.50) {
      return _lerp(
          const Offset(60, 50), const Offset(60, 10), (t - 0.40) / 0.10);
    } else if (t <= 0.57) {
      return _lerp(
          const Offset(60, 10), const Offset(53, 24), (t - 0.50) / 0.07);
    } else if (t <= 0.60) {
      return _lerp(
          const Offset(53, 24), const Offset(45, 20), (t - 0.57) / 0.03);
    } else if (t <= 0.67) {
      return _lerp(
          const Offset(45, 20), const Offset(37, 34), (t - 0.60) / 0.07);
    } else if (t <= 0.70) {
      return _lerp(
          const Offset(37, 34), const Offset(30, 30), (t - 0.67) / 0.03);
    } else if (t <= 0.77) {
      return _lerp(
          const Offset(30, 30), const Offset(22, 44), (t - 0.70) / 0.07);
    } else if (t <= 0.80) {
      return _lerp(
          const Offset(22, 44), const Offset(15, 40), (t - 0.77) / 0.03);
    } else if (t <= 0.87) {
      return _lerp(
          const Offset(15, 40), const Offset(7, 54), (t - 0.80) / 0.07);
    } else if (t <= 0.90) {
      return _lerp(const Offset(7, 54), const Offset(0, 50), (t - 0.87) / 0.03);
    } else {
      return _lerp(const Offset(0, 50), const Offset(0, 10), (t - 0.90) / 0.10);
    }
  }

  Offset _lerp(Offset a, Offset b, double t) {
    return Offset(
      a.dx + (b.dx - a.dx) * t,
      a.dy + (b.dy - a.dy) * t,
    );
  }

  // 柱子 1 的缩放动画
  double _getBarScale1(double t) {
    if (t <= 0.40) return 0.2;
    if (t <= 0.50) return 0.2 + (1.0 - 0.2) * ((t - 0.40) / 0.10);
    if (t <= 0.90) return 1.0;
    return 1.0 - (1.0 - 0.2) * ((t - 0.90) / 0.10);
  }

  // 柱子 2 的缩放动画
  double _getBarScale2(double t) {
    if (t <= 0.40) return 0.4;
    if (t <= 0.50) return 0.4 + (0.8 - 0.4) * ((t - 0.40) / 0.10);
    if (t <= 0.90) return 0.8;
    return 0.8 - (0.8 - 0.4) * ((t - 0.90) / 0.10);
  }

  // 柱子 3 的缩放动画（固定）
  double _getBarScale3(double t) {
    return 0.6;
  }

  // 柱子 4 的缩放动画
  double _getBarScale4(double t) {
    if (t <= 0.40) return 0.8;
    if (t <= 0.50) return 0.8 - (0.8 - 0.4) * ((t - 0.40) / 0.10);
    if (t <= 0.90) return 0.4;
    return 0.4 + (0.8 - 0.4) * ((t - 0.90) / 0.10);
  }

  // 柱子 5 的缩放动画
  double _getBarScale5(double t) {
    if (t <= 0.40) return 1.0;
    if (t <= 0.50) return 1.0 - (1.0 - 0.2) * ((t - 0.40) / 0.10);
    if (t <= 0.90) return 0.2;
    return 0.2 + (1.0 - 0.2) * ((t - 0.90) / 0.10);
  }
}
