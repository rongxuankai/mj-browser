import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/browser_provider.dart';
import 'screens/browser_screen.dart';
import 'utils/error_handler.dart';

void main() {
  // 初始化全局错误处理（针对 Android 15 闪退问题）
  ErrorHandler.init();

  runApp(const MJBrowserApp());
}

/// 明鉴浏览器应用
class MJBrowserApp extends StatelessWidget {
  const MJBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrowserProvider(),
      child: MaterialApp(
        title: '明鉴浏览器',
        debugShowCheckedModeBanner: false,

        // Material 3 亮色主题
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),

        // Material 3 暗色主题
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),

        // 跟随系统主题
        themeMode: ThemeMode.system,

        home: const BrowserScreen(),
      ),
    );
  }
}
