import 'package:shared_preferences/shared_preferences.dart';

/// AI 设置服务
class AISettingsService {
  static const String _keyApiUrl = 'ai_api_url';
  static const String _keyApiKey = 'ai_api_key';
  static const String _keyModel = 'ai_model';
  static const String _keyUserAgent = 'browser_user_agent';

  // 默认值（开发者可在此配置）
  // 推荐使用火山引擎购买 API：https://console.volcengine.com/
  // 支持的模型：Kimi、Gemini 等主流大语言模型
  static const String defaultApiUrl =
      ''; // 示例：'https://ark.cn-beijing.volces.com/api/v3/chat/completions'
  static const String defaultApiKey = ''; // 在此填入你的 API Key
  static const String defaultModel = ''; // 示例：'kimi-k2-250905'

  // 常用 User Agent 预设
  static const String androidUA =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
  static const String iosUA =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
  static const String desktopUA =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  static const String defaultUserAgent = androidUA; // 默认使用 Android UA

  /// 获取 API URL
  static Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiUrl) ?? defaultApiUrl;
  }

  /// 设置 API URL
  static Future<void> setApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiUrl, url);
  }

  /// 获取 API Key
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey) ?? defaultApiKey;
  }

  /// 设置 API Key
  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, key);
  }

  /// 获取模型名称
  static Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyModel) ?? defaultModel;
  }

  /// 设置模型名称
  static Future<void> setModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyModel, model);
  }

  /// 获取 User Agent
  static Future<String> getUserAgent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserAgent) ?? defaultUserAgent;
  }

  /// 设置 User Agent
  static Future<void> setUserAgent(String userAgent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAgent, userAgent);
  }

  /// 重置为默认值
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiUrl, defaultApiUrl);
    await prefs.setString(_keyApiKey, defaultApiKey);
    await prefs.setString(_keyModel, defaultModel);
    await prefs.setString(_keyUserAgent, defaultUserAgent);
  }
}
