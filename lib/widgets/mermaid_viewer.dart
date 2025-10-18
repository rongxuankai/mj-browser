import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Mermaid 图表查看器
class MermaidViewer extends StatelessWidget {
  final String mermaidCode;

  const MermaidViewer({
    super.key,
    required this.mermaidCode,
  });

  @override
  Widget build(BuildContext context) {
    // 清理 Mermaid 代码（移除可能的 markdown 标记）
    String cleanCode = mermaidCode.trim();
    if (cleanCode.startsWith('```mermaid')) {
      cleanCode = cleanCode.substring(10);
    }
    if (cleanCode.startsWith('```')) {
      cleanCode = cleanCode.substring(3);
    }
    if (cleanCode.endsWith('```')) {
      cleanCode = cleanCode.substring(0, cleanCode.length - 3);
    }
    cleanCode = cleanCode.trim();

    // 生成完整的 HTML
    final html = _generateMermaidHTML(cleanCode);

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InAppWebView(
          initialData: InAppWebViewInitialData(data: html),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            transparentBackground: true,
          ),
        ),
      ),
    );
  }

  /// 生成包含 Mermaid 的 HTML
  String _generateMermaidHTML(String mermaidCode) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
    mermaid.initialize({ 
      startOnLoad: true,
      theme: 'default',
      themeVariables: {
        primaryColor: '#6366f1',
        primaryTextColor: '#fff',
        primaryBorderColor: '#4f46e5',
        lineColor: '#94a3b8',
        secondaryColor: '#f0f9ff',
        tertiaryColor: '#f8fafc',
        fontSize: '14px',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      },
      mindmap: {
        padding: 20,
        maxNodeWidth: 200
      }
    });
  </script>
  <style>
    body {
      margin: 0;
      padding: 20px;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      background: #ffffff;
      font-family: system-ui, -apple-system, sans-serif;
    }
    .mermaid {
      max-width: 100%;
      overflow: auto;
    }
    svg {
      max-width: 100%;
      height: auto;
    }
  </style>
</head>
<body>
  <div class="mermaid">
$mermaidCode
  </div>
</body>
</html>
''';
  }
}
