import 'package:flutter/material.dart';

/// 打字机加载动画 - 灵感来自 CSS 动画
class TypewriterAnimation extends StatefulWidget {
  final double size;

  const TypewriterAnimation({
    super.key,
    this.size = 120.0,
  });

  @override
  State<TypewriterAnimation> createState() => _TypewriterAnimationState();
}

class _TypewriterAnimationState extends State<TypewriterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // 从3秒减少到1.5秒，更快更流畅
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 颜色配置
    const blueColor = Color(0xFF5c86ff);
    const blueDarkColor = Color(0xFF1e0325);
    const keyColor = Colors.white;
    final paperColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFeef0fd);
    final textColor =
        isDark ? const Color(0xFF6A6A6A) : const Color(0xFFd3d4ec);
    const toolColor = Color(0xFFfbc56c);

    return SizedBox(
      width: widget.size,
      height: widget.size * 0.6,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          return Transform.translate(
            offset: Offset(0, _getBounce(progress) * widget.size * 0.05),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 滑块 - 最底层
                _buildSlide(blueColor, blueDarkColor, toolColor, progress),

                // 纸张 - 中间层（在键盘上面，在滑块下面）
                _buildPaper(paperColor, textColor, progress),

                // 键盘主体 - 最顶层
                _buildKeyboard(blueColor, blueDarkColor, keyColor, progress),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建键盘
  Widget _buildKeyboard(
      Color blue, Color blueDark, Color keyColor, double progress) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: widget.size,
        height: widget.size * 0.47,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [blue, blueDark],
          ),
        ),
        child: CustomPaint(
          painter: _KeyboardPainter(
            keyColor: keyColor,
            progress: progress,
          ),
        ),
      ),
    );
  }

  /// 构建纸张
  Widget _buildPaper(Color paperColor, Color textColor, double progress) {
    final paperOffset = _getPaperOffset(progress);

    return Positioned(
      bottom: widget.size * 0.47 + (widget.size * 0.05), // 键盘高度 + 向上偏移，让纸张更明显
      left: widget.size * 0.2,
      child: Transform.translate(
        offset: Offset(0, paperOffset * widget.size * 0.38),
        child: Container(
          width: widget.size * 0.33,
          height: widget.size * 0.38,
          decoration: BoxDecoration(
            color: paperColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              // 文字线条
              Positioned(
                left: widget.size * 0.05,
                right: widget.size * 0.05,
                top: widget.size * 0.058,
                child: Column(
                  children: List.generate(
                    4,
                    (index) => Container(
                      margin: EdgeInsets.only(bottom: widget.size * 0.08),
                      height: widget.size * 0.033,
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(2),
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

  /// 构建滑块
  Widget _buildSlide(
      Color blue, Color blueDark, Color toolColor, double progress) {
    final slideOffset = _getSlideOffset(progress);

    return Positioned(
      bottom: widget.size * 0.47 + (widget.size * 0.05),
      left: widget.size * 0.12,
      child: Transform.translate(
        offset: Offset(slideOffset * widget.size * 0.22, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 滑块主体
            Container(
              width: widget.size * 0.77,
              height: widget.size * 0.17,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [blue, blueDark],
                ),
              ),
            ),

            // 左侧小部件
            Positioned(
              right: widget.size * 0.77,
              top: widget.size * 0.033,
              child: Container(
                width: widget.size * 0.05,
                height: widget.size * 0.033,
                decoration: BoxDecoration(
                  color: toolColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 右侧小部件
            Positioned(
              left: widget.size * 0.78,
              top: widget.size * 0.025,
              child: Container(
                width: widget.size * 0.05,
                height: widget.size * 0.117,
                decoration: BoxDecoration(
                  color: toolColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // 竖直小棒
            Positioned(
              left: widget.size * 0.77,
              top: widget.size * 0.05,
              child: Container(
                width: widget.size * 0.017,
                height: widget.size * 0.067,
                color: toolColor,
              ),
            ),

            // 顶部小棒
            Positioned(
              right: widget.size * 0.77 + widget.size * 0.05,
              top: widget.size * 0.017,
              child: Container(
                width: widget.size * 0.033,
                height: widget.size * 0.117,
                decoration: BoxDecoration(
                  color: toolColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取弹跳偏移
  double _getBounce(double progress) {
    if (progress >= 0.85 && progress < 0.89) {
      return -1.0;
    } else if (progress >= 0.89 && progress < 0.92) {
      return -0.8;
    } else if (progress >= 0.95 && progress < 1.0) {
      return 0.5;
    }
    return 0;
  }

  /// 获取滑块偏移 (0到1之间，0是最右，1是最左)
  double _getSlideOffset(double progress) {
    if (progress < 0.08) return 1.0;
    if (progress < 0.20) return 0.43;
    if (progress < 0.40) return 0.43;
    if (progress < 0.50) return 0.0;
    if (progress < 0.65) return 0.0;
    if (progress < 0.75) return -0.29;
    if (progress < 0.80) return -0.29;
    if (progress < 0.90) return -0.86;
    if (progress < 0.95) return -0.86;
    return 1.0;
  }

  /// 获取纸张偏移 (0是最下，1是最上)
  double _getPaperOffset(double progress) {
    if (progress < 0.08) return 1.0;
    if (progress < 0.25) return 0.74;
    if (progress < 0.35) return 0.74;
    if (progress < 0.50) return 0.48;
    if (progress < 0.65) return 0.48;
    if (progress < 0.75) return 0.22;
    if (progress < 0.80) return 0.22;
    if (progress < 0.90) return 0.0;
    if (progress < 0.95) return 0.0;
    if (progress < 0.98) return 0.0;
    return 1.0;
  }
}

/// 键盘按键绘制器
class _KeyboardPainter extends CustomPainter {
  final Color keyColor;
  final double progress;

  _KeyboardPainter({
    required this.keyColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = keyColor
      ..style = PaintingStyle.fill;

    final keyWidth = size.width * 0.092;
    final keyHeight = size.height * 0.071;
    const keyRadius = 2.0;

    // 第一排按键
    final row1Y = size.height * 0.45;
    final row1Keys = [
      size.width * 0.017,
      size.width * 0.125,
      size.width * 0.25,
      size.width * 0.375,
      size.width * 0.5,
      size.width * 0.625,
      size.width * 0.75,
    ];

    // 第二排按键
    final row2Y = size.height * 0.62;
    final row2Keys = [
      size.width * 0.183,
      size.width * 0.308,
      size.width * 0.433,
      size.width * 0.5,
      size.width * 0.567,
      size.width * 0.692,
    ];

    // 获取被按下的键
    final pressedKey = _getPressedKey(progress);

    // 绘制第一排
    for (int i = 0; i < row1Keys.length; i++) {
      final offset = (pressedKey == i) ? 2.0 : 0.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(row1Keys[i], row1Y + offset, keyWidth, keyHeight),
        Radius.circular(keyRadius),
      );
      canvas.drawRRect(rect, paint);
    }

    // 绘制第二排
    for (int i = 0; i < row2Keys.length; i++) {
      final offset = (pressedKey == i + 7) ? 2.0 : 0.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(row2Keys[i], row2Y + offset, keyWidth, keyHeight),
        Radius.circular(keyRadius),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  /// 获取当前被按下的键 (-1表示没有按键)
  int _getPressedKey(double progress) {
    final keyframes = [0.12, 0.24, 0.36, 0.48, 0.60, 0.72, 0.84, 0.90, 0.96];
    final keys = [0, 3, 7, 9, 6, 1, 12, 2, 8];

    for (int i = 0; i < keyframes.length; i++) {
      if (progress >= (keyframes[i] - 0.03) &&
          progress < (keyframes[i] + 0.03)) {
        return keys[i];
      }
    }
    return -1;
  }

  @override
  bool shouldRepaint(covariant _KeyboardPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
