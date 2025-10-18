import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// 二维码分享对话框
class QrShareDialog extends StatefulWidget {
  final String url;
  final String title;

  const QrShareDialog({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<QrShareDialog> createState() => _QrShareDialogState();
}

class _QrShareDialogState extends State<QrShareDialog> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.qr_code_2, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '分享链接',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 二维码
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: widget.url,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // URL 文本
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceVariant
                    : colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                widget.url,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _saveQrCode,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_alt),
                    label: Text(_isSaving ? '保存中...' : '保存图片'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // 复制链接
                      _copyToClipboard(context);
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('复制链接'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 保存二维码图片
  Future<void> _saveQrCode() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 获取 RenderRepaintBoundary
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // 转换为图片
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 创建临时文件
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // 保存到相册
      await Gal.putImage(filePath, album: 'MJ Browser');

      // 删除临时文件
      await file.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 二维码已保存到相册'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 保存失败: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// 复制链接到剪贴板
  void _copyToClipboard(BuildContext context) {
    // 使用 Clipboard API
    final data = ClipboardData(text: widget.url);
    Clipboard.setData(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 链接已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
