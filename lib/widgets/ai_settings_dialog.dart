import 'package:flutter/material.dart';
import '../services/ai_settings_service.dart';

/// AI 设置对话框
class AISettingsDialog extends StatefulWidget {
  const AISettingsDialog({super.key});

  @override
  State<AISettingsDialog> createState() => _AISettingsDialogState();
}

class _AISettingsDialogState extends State<AISettingsDialog> {
  late TextEditingController _apiUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiUrlController = TextEditingController();
    _apiKeyController = TextEditingController();
    _modelController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    final apiUrl = await AISettingsService.getApiUrl();
    final apiKey = await AISettingsService.getApiKey();
    final model = await AISettingsService.getModel();

    setState(() {
      _apiUrlController.text = apiUrl;
      _apiKeyController.text = apiKey;
      _modelController.text = model;
      _isLoading = false;
    });
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    await AISettingsService.setApiUrl(_apiUrlController.text.trim());
    await AISettingsService.setApiKey(_apiKeyController.text.trim());
    await AISettingsService.setModel(_modelController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 设置已保存'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  /// 重置为默认值
  Future<void> _resetToDefaults() async {
    await AISettingsService.resetToDefaults();
    await _loadSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 已恢复默认设置'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('AI 设置'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API URL
                  Text(
                    'API 地址',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiUrlController,
                    decoration: InputDecoration(
                      hintText: 'https://...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // API Key
                  Text(
                    'API 密钥',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      hintText: '输入你的 API Key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility_off, size: 20),
                        onPressed: () {
                          // 切换密码可见性（可选实现）
                        },
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Model
                  Text(
                    '模型名称',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      hintText: 'kimi-k2-250905',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // 提示信息
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '当前使用的是开发测试 API',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        // 重置按钮
        TextButton.icon(
          onPressed: _resetToDefaults,
          icon: const Icon(Icons.restore, size: 18),
          label: const Text('重置'),
        ),
        // 取消按钮
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        // 保存按钮
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
