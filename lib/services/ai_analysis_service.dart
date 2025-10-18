import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_settings_service.dart';

/// AI 分析服务
class AIAnalysisService {
  /// 分析页面内容
  static Future<String> analyzePage({
    required String pageTitle,
    required String pageContent,
    required String pageUrl,
  }) async {
    try {
      // 获取 API 配置
      final apiUrl = await AISettingsService.getApiUrl();
      final apiKey = await AISettingsService.getApiKey();
      final model = await AISettingsService.getModel();

      // 构建提示词
      final userPrompt = _buildPrompt(
        pageTitle: pageTitle,
        pageContent: pageContent,
        pageUrl: pageUrl,
      );

      // 调用 API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': '你是"明鉴浏览器"的内置AI助手，专门负责分析网页内容。'
                  '请用简洁、专业的语言提供分析，包括：'
                  '1. 页面主题概述（1-2句话）'
                  '2. 核心内容要点（3-5条）'
                  '3. 实用建议或见解（可选）'
                  '请使用清晰的分段和列表格式。'
            },
            {
              'role': 'user',
              'content': userPrompt,
            },
          ],
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices']?[0]?['message']?['content'];

        if (content != null && content.isNotEmpty) {
          return content;
        } else {
          return '⚠️ AI 返回了空内容，请重试。';
        }
      } else {
        return '❌ API 调用失败\n'
            '状态码: ${response.statusCode}\n'
            '错误: ${response.body}';
      }
    } catch (e) {
      return '❌ 分析失败: $e';
    }
  }

  /// 构建分析提示词
  static String _buildPrompt({
    required String pageTitle,
    required String pageContent,
    required String pageUrl,
  }) {
    // 限制内容长度，避免超过 token 限制
    String limitedContent = pageContent;
    if (pageContent.length > 3000) {
      limitedContent = '${pageContent.substring(0, 3000)}\n...(内容已截断)';
    }

    return '''请分析以下网页内容：

网址: $pageUrl
标题: $pageTitle

页面内容:
$limitedContent

请提供详细的分析报告。''';
  }

  /// 快速提问
  static Future<String> quickQuestion({
    required String question,
    required String pageContext,
  }) async {
    try {
      final apiUrl = await AISettingsService.getApiUrl();
      final apiKey = await AISettingsService.getApiKey();
      final model = await AISettingsService.getModel();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': '你是"明鉴浏览器"的内置AI助手。基于用户当前浏览的页面内容，简洁地回答问题。',
            },
            {
              'role': 'user',
              'content': '页面内容: $pageContext\n\n问题: $question',
            },
          ],
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices']?[0]?['message']?['content'] ?? '无响应';
      } else {
        return '❌ 请求失败: ${response.statusCode}';
      }
    } catch (e) {
      return '❌ 错误: $e';
    }
  }
}
