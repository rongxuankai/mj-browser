import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/ai_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _geminiService = GeminiService();
  final _apiKeyController = TextEditingController();
  bool _isLoading = true;
  bool _hasApiKey = false;
  bool _obscureApiKey = true;
  String _selectedUserAgent = AISettingsService.defaultUserAgent;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    setState(() => _isLoading = true);

    final apiKey = await _geminiService.getApiKey();
    _hasApiKey = apiKey != null && apiKey.isNotEmpty;

    if (_hasApiKey) {
      _apiKeyController.text = apiKey!;
    }

    // 加载 User Agent 设置
    _selectedUserAgent = await AISettingsService.getUserAgent();

    setState(() => _isLoading = false);
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      _showMessage('请输入 API Key', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _geminiService.saveApiKey(apiKey);
      setState(() => _hasApiKey = true);
      _showMessage('API Key 保存成功');
    } catch (e) {
      _showMessage('保存失败: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除保存的 API Key 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _geminiService.removeApiKey();
      _apiKeyController.clear();
      setState(() => _hasApiKey = false);
      _showMessage('API Key 已删除');
    } catch (e) {
      _showMessage('删除失败: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildUserAgentSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Android 移动设备（默认）'),
          subtitle: const Text('适用于移动版网站'),
          value: AISettingsService.androidUA,
          groupValue: _selectedUserAgent,
          onChanged: (value) => _updateUserAgent(value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('iPhone（iOS）'),
          subtitle: const Text('适用于 iOS 版网站'),
          value: AISettingsService.iosUA,
          groupValue: _selectedUserAgent,
          onChanged: (value) => _updateUserAgent(value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('桌面版（Windows）'),
          subtitle: const Text('适用于电脑版网站'),
          value: AISettingsService.desktopUA,
          groupValue: _selectedUserAgent,
          onChanged: (value) => _updateUserAgent(value!),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Future<void> _updateUserAgent(String userAgent) async {
    setState(() {
      _selectedUserAgent = userAgent;
      _isLoading = true;
    });

    try {
      await AISettingsService.setUserAgent(userAgent);
      _showMessage('User Agent 已更新，新打开的页面生效');
    } catch (e) {
      _showMessage('更新失败: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 AI 功能'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '默认 API 配置',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('本应用已内置火山引擎 Kimi AI API，无需额外配置即可使用。'),
              SizedBox(height: 16),
              Text(
                '自定义 API Key（可选）',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('如果您有自己的 API Key，可以在上方输入框中配置。'),
              SizedBox(height: 16),
              Text(
                '功能说明',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• 智能分析网页内容'),
              Text('• 提取关键信息'),
              Text('• 回答页面相关问题'),
              Text('• 提供实用建议'),
              SizedBox(height: 16),
              Text(
                '注意事项：',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              Text('• API 调用需要网络连接'),
              Text('• 请勿分析敏感或私密内容'),
              Text('• AI 回复仅供参考'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // AI 功能配置
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI 分析功能',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '基于 Kimi AI 的网页智能分析（已内置 API）',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline),
                              onPressed: _showHelpDialog,
                              tooltip: '关于 AI 功能',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _apiKeyController,
                          obscureText: _obscureApiKey,
                          decoration: InputDecoration(
                            labelText: 'API Key（可选）',
                            hintText: '已使用默认 API，如需自定义可在此输入',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.vpn_key),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureApiKey
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscureApiKey = !_obscureApiKey);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isLoading ? null : _saveApiKey,
                                icon: const Icon(Icons.save),
                                label: const Text('保存'),
                              ),
                            ),
                            if (_hasApiKey) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _isLoading ? null : _removeApiKey,
                                icon: const Icon(Icons.delete),
                                label: const Text('删除'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_hasApiKey) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'API Key 已配置',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 浏览器设置
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings_applications,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '浏览器设置',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'User Agent（用户代理）',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '选择浏览器标识，影响网站显示的版本',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildUserAgentSelector(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 关于信息
                Card(
                  child: ListTile(
                    leading: Icon(Icons.info, color: colorScheme.primary),
                    title: const Text('关于'),
                    subtitle: const Text('MJ Browser v1.0.0'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MJ Browser',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(Icons.public, size: 48),
                        children: const [
                          Text('一个支持 AI 分析的现代浏览器'),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
