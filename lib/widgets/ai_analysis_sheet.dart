import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import 'mermaid_viewer.dart';
import 'typewriter_animation.dart';

/// AI 分析任务类型
enum AnalysisTaskType {
  summary('快速总结', Icons.summarize, '快速总结页面核心内容，提取关键要点'),
  mindmap('思维导图', Icons.account_tree, '生成思维导图，展现内容结构'),
  flowchart('流程图', Icons.device_hub, '生成流程图，展示步骤流程'),
  keypoints('关键点', Icons.stars, '提取关键信息点，便于快速浏览'),
  analysis('深度分析', Icons.analytics, '详细分析内容，提供洞察和建议'),
  qa('问答提取', Icons.question_answer, '提取可能的问答对，快速了解'),
  ;

  final String label;
  final IconData icon;
  final String description;

  const AnalysisTaskType(this.label, this.icon, this.description);
}

/// AI 分析底部弹窗
class AIAnalysisSheet extends StatefulWidget {
  final String pageTitle;
  final String pageContent;
  final String pageUrl;

  const AIAnalysisSheet({
    super.key,
    required this.pageTitle,
    required this.pageContent,
    required this.pageUrl,
  });

  @override
  State<AIAnalysisSheet> createState() => _AIAnalysisSheetState();
}

class _AIAnalysisSheetState extends State<AIAnalysisSheet>
    with SingleTickerProviderStateMixin {
  final _geminiService = GeminiService();
  String _result = '';
  String _mermaidCode = '';
  bool _isLoading = false;
  String? _error;
  AnalysisTaskType? _currentTask;
  final TextEditingController _questionController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 不再自动开始分析
  }

  @override
  void dispose() {
    _questionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// 开始指定任务的分析
  Future<void> _startTask(AnalysisTaskType task) async {
    setState(() {
      _isLoading = true;
      _result = '';
      _mermaidCode = '';
      _error = null;
      _currentTask = task;
    });

    try {
      String result;

      // 根据任务类型调用不同的分析方法
      switch (task) {
        case AnalysisTaskType.summary:
          result = await _geminiService.analyzeContent(
              widget.pageContent, widget.pageUrl);
          break;
        case AnalysisTaskType.mindmap:
          result = await _geminiService.generateMindMap(
              widget.pageContent, widget.pageUrl);
          _mermaidCode = result;
          // 切换到思维导图标签
          if (mounted) _tabController.animateTo(1);
          break;
        case AnalysisTaskType.flowchart:
          result = await _generateFlowchart();
          _mermaidCode = result;
          if (mounted) _tabController.animateTo(1);
          break;
        case AnalysisTaskType.keypoints:
          result = await _extractKeyPoints();
          break;
        case AnalysisTaskType.analysis:
          result = await _deepAnalysis();
          break;
        case AnalysisTaskType.qa:
          result = await _extractQA();
          break;
      }

      if (mounted) {
        setState(() {
          if (task == AnalysisTaskType.mindmap ||
              task == AnalysisTaskType.flowchart) {
            _mermaidCode = result;
          } else {
            _result = result;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// 生成流程图
  Future<String> _generateFlowchart() async {
    String truncatedContent = widget.pageContent.length > 4000
        ? '${widget.pageContent.substring(0, 4000)}...'
        : widget.pageContent;

    final prompt = '''
请分析以下网页内容，生成Mermaid流程图代码：

URL: ${widget.pageUrl}
内容: $truncatedContent

**要求：**
1. 使用 flowchart TD 格式（从上到下）
2. 最多展示主要流程的5-8个步骤
3. 每个节点≤12字
4. 使用清晰的箭头连接表示流程
5. 只返回Mermaid代码，不要其他说明

示例格式：
```mermaid
flowchart TD
    A[开始] --> B[步骤1]
    B --> C{判断}
    C -->|是| D[步骤2]
    C -->|否| E[步骤3]
    D --> F[结束]
    E --> F
```

直接返回代码，不要markdown标记。
''';

    return await _geminiService.chat(prompt,
        systemPrompt: '你是Mermaid图表专家，擅长用流程图呈现流程步骤。');
  }

  /// 提取关键点
  Future<String> _extractKeyPoints() async {
    String truncatedContent = widget.pageContent.length > 5000
        ? '${widget.pageContent.substring(0, 5000)}...'
        : widget.pageContent;

    final prompt = '''
请提取以下网页的关键信息点：

$truncatedContent

**要求：**
1. 提取5-8个核心关键点
2. 每个关键点15-30字
3. 使用清晰的编号和emoji标识
4. 按重要性排序
5. 突出关键数据和结论

格式示例：
⭐ 1. 关键点1描述
⭐ 2. 关键点2描述
...
''';

    return await _geminiService.chat(prompt);
  }

  /// 深度分析
  Future<String> _deepAnalysis() async {
    String truncatedContent = widget.pageContent.length > 6000
        ? '${widget.pageContent.substring(0, 6000)}...'
        : widget.pageContent;

    final prompt = '''
请深度分析以下内容（${widget.pageUrl}）：

$truncatedContent

**要求：**
1. 📖 内容概述（2-3句）
2. 🎯 核心观点（3-5个要点）
3. 💡 深度洞察（专业分析）
4. ⚠️ 注意事项（风险/局限）
5. 🔮 启示建议（实用价值）

分析要深入、专业，但表达清晰易懂。
''';

    return await _geminiService.chat(prompt,
        systemPrompt: '你是专业的内容分析师，擅长深度解读和提炼价值。');
  }

  /// 提取问答对
  Future<String> _extractQA() async {
    String truncatedContent = widget.pageContent.length > 5000
        ? '${widget.pageContent.substring(0, 5000)}...'
        : widget.pageContent;

    final prompt = '''
请基于以下内容，提取或生成5-7个常见问答对：

$truncatedContent

**要求：**
1. 问题要针对核心内容
2. 答案简洁精准（每个≤50字）
3. 覆盖主要知识点
4. 使用Q&A格式

格式示例：
❓ Q1: 问题1？
✅ A1: 答案1

❓ Q2: 问题2？
✅ A2: 答案2
...
''';

    return await _geminiService.chat(prompt);
  }

  /// 快速提问
  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prompt = '''
页面内容：${widget.pageContent.length > 2000 ? '${widget.pageContent.substring(0, 2000)}...' : widget.pageContent}

问题：$question

要求：1-2句话简洁回答，突出关键信息。
''';

      final answer = await _geminiService.chat(prompt);

      if (mounted) {
        setState(() {
          _result = '💬 $question\n\n📝 $answer';
          _isLoading = false;
          _currentTask = null;
        });
        _questionController.clear();
        // 切换到文本分析标签
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          _buildHeader(theme, colorScheme),

          const Divider(height: 1),

          // 标签栏
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.article_outlined), text: '文本结果'),
              Tab(icon: Icon(Icons.account_tree_outlined), text: '图表结果'),
            ],
          ),

          const Divider(height: 1),

          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 文字分析标签页
                _isLoading
                    ? _buildLoadingView(colorScheme, _getLoadingMessage())
                    : _buildAnalysisView(theme),

                // 图表标签页
                _isLoading
                    ? _buildLoadingView(colorScheme, _getLoadingMessage())
                    : _buildDiagramView(theme),
              ],
            ),
          ),

          const Divider(height: 1),

          // 快速提问区域
          _buildQuestionBar(theme, colorScheme),
        ],
      ),
    );
  }

  /// 获取加载消息
  String _getLoadingMessage() {
    if (_currentTask == null) return 'AI 正在分析中...';
    return '正在${_currentTask!.label}...';
  }

  /// 构建标题栏
  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // AI 图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 页面分析',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.pageTitle.isEmpty ? widget.pageUrl : widget.pageTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建加载视图 - 使用打字机动画
  Widget _buildLoadingView(ColorScheme colorScheme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TypewriterAnimation(size: 120),
          const SizedBox(height: 32),
          Text(
            message,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 正在努力工作中...',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分析视图
  Widget _buildAnalysisView(ThemeData theme) {
    // 显示错误信息
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                '分析失败',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _error = null);
                },
                icon: const Icon(Icons.close),
                label: const Text('关闭'),
              ),
            ],
          ),
        ),
      );
    }

    // 显示分析内容
    if (_result.isEmpty) {
      return _buildTaskSelection(theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectableText(
        _result,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          fontSize: 15,
        ),
      ),
    );
  }

  /// 构建任务选择界面
  Widget _buildTaskSelection(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '请选择一种分析任务，AI 将为您智能分析页面内容',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 任务按钮网格
          Text(
            '文本分析任务',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 文本类任务
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AnalysisTaskType.summary,
              AnalysisTaskType.keypoints,
              AnalysisTaskType.analysis,
              AnalysisTaskType.qa,
            ].map((task) => _buildTaskButton(theme, task)).toList(),
          ),

          const SizedBox(height: 24),

          // 图表类任务
          Text(
            '图表生成任务',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AnalysisTaskType.mindmap,
              AnalysisTaskType.flowchart,
            ].map((task) => _buildTaskButton(theme, task)).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建任务按钮
  Widget _buildTaskButton(ThemeData theme, AnalysisTaskType task) {
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _startTask(task),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    task.icon,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图表视图
  Widget _buildDiagramView(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    // 显示错误信息
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                '生成失败',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _error = null);
                },
                icon: const Icon(Icons.close),
                label: const Text('关闭'),
              ),
            ],
          ),
        ),
      );
    }

    // 显示图表
    if (_mermaidCode.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部提示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    color: colorScheme.secondary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '请选择图表任务，AI 将生成可视化图表',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 图表任务按钮
            Text(
              '可用的图表类型',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AnalysisTaskType.mindmap,
                AnalysisTaskType.flowchart,
              ].map((task) => _buildTaskButton(theme, task)).toList(),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MermaidViewer(mermaidCode: _mermaidCode),
    );
  }

  /// 构建提问栏
  Widget _buildQuestionBar(ThemeData theme, ColorScheme colorScheme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: '向 AI 提问关于这个页面的问题...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor:
                      colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _askQuestion(),
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: _isLoading ? null : _askQuestion,
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.send, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
