import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';

  // 火山引擎 API 配置（开发者可在此配置默认值）
  // 获取 API：访问火山引擎控制台 https://console.volcengine.com/
  // 支持模型：Kimi、豆包、Gemini 等，根据你购买的服务填写
  static const String _baseUrl =
      ''; // 示例：'https://ark.cn-beijing.volces.com/api/v3/chat/completions'
  static const String _defaultApiKey = ''; // 在此填入你的 API Key
  static const String _model = ''; // 示例：'kimi-k2-250905'

  String? _cachedApiKey;

  /// 获取保存的 API Key（如果没有则使用默认的）
  Future<String?> getApiKey() async {
    if (_cachedApiKey != null) return _cachedApiKey;

    final prefs = await SharedPreferences.getInstance();
    _cachedApiKey = prefs.getString(_apiKeyKey);

    // 如果没有保存的 API Key，使用默认的
    if (_cachedApiKey == null || _cachedApiKey!.isEmpty) {
      _cachedApiKey = _defaultApiKey;
    }

    return _cachedApiKey;
  }

  /// 保存 API Key
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
    _cachedApiKey = apiKey;
  }

  /// 删除 API Key（会回退到默认值）
  Future<void> removeApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
    _cachedApiKey = _defaultApiKey;
  }

  /// 检查是否已配置 API Key
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// 分析网页内容 - 简洁版本，节省token
  Future<String> analyzeContent(String content, String url) async {
    final apiKey = await getApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key 配置错误');
    }

    // 限制内容长度以避免超过 token 限制
    String truncatedContent =
        content.length > 5000 ? '${content.substring(0, 5000)}...' : content;

    final prompt = '''
以"明鉴"之名，请分类分析以下内容（$url）：

$truncatedContent

**要求（极简模式）：**
1. 📊 **内容类型**：1句判断（新闻/文章/商品/技术文档等）
2. 🎯 **核心要点**：3-4个关键信息，每条≤30字
3. ⚠️ **明鉴提示**：可信度/风险/注意事项，1-2条
4. 💡 **实用价值**：对用户的价值，1句话

**格式要求：严格简洁，每部分用emoji标识，便于快速浏览。**
''';

    return await _callAPI(prompt, '你是"明鉴浏览器"的AI助手，专注于快速、准确地分析信息，帮助用户明辨真伪。');
  }

  /// 生成思维导图 - 返回 Mermaid 代码
  Future<String> generateMindMap(String content, String url) async {
    final apiKey = await getApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key 配置错误');
    }

    String truncatedContent =
        content.length > 4000 ? '${content.substring(0, 4000)}...' : content;

    final prompt = '''
请分析以下网页内容，生成Mermaid思维导图代码：

URL: $url
内容: $truncatedContent

**要求：**
1. 使用 mindmap 格式
2. 最多3层结构
3. 每个节点≤10字
4. 突出核心概念和关键信息
5. 只返回Mermaid代码，不要其他说明

示例格式：
```mermaid
mindmap
  root((主题))
    分支1
      子项1
      子项2
    分支2
      子项3
```

直接返回代码，不要markdown标记。
''';

    return await _callAPI(prompt, '你是Mermaid图表专家，擅长用思维导图呈现信息结构。');
  }

  /// 统一的 API 调用方法
  Future<String> _callAPI(String prompt, String systemPrompt) async {
    final apiKey = await getApiKey();

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['choices'] != null &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null) {
          return data['choices'][0]['message']['content'] ?? '未能生成结果';
        }

        throw Exception('API 返回格式异常');
      } else if (response.statusCode == 401) {
        throw Exception('API Key 无效，请检查配置');
      } else if (response.statusCode == 429) {
        throw Exception('API 调用次数超限，请稍后再试');
      } else {
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          throw Exception(
              'API 调用失败: ${errorData['error']?['message'] ?? response.statusCode}');
        } catch (_) {
          throw Exception('API 调用失败: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('网络请求失败: $e');
    }
  }

  /// 简单对话（用于快速提问）- 简洁回复
  Future<String> chat(String message, {String? systemPrompt}) async {
    return await _callAPI(
      message,
      systemPrompt ?? '你是"明鉴浏览器"的AI助手。回答要简洁精准，每个回答控制在100字内。',
    );
  }
}
